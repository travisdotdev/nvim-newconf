return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = function()
        -- System stats
        local function term_cmd(cmd)
            return vim.trim(vim.fn.system(cmd))
        end

        local function gen_graph(percent, width)
            percent = math.max(0, math.min(tonumber(percent) or 0, 100))
            width = width or 20
            local filled = math.floor((percent / 100) * width + 0.5)
            return '[' .. string.rep('=', filled) .. string.rep('-', width - filled) .. ']'
        end

        -- Try fastfetch first (one call gets everything)
        local ff = nil
        if term_cmd 'command -v fastfetch' ~= '' then
            local json = term_cmd 'fastfetch -s CPUUsage:Memory:Disk --format json'
            local ok, data = pcall(vim.json.decode, json)
            if ok and data then
                ff = {}
                for _, item in ipairs(data) do
                    if item.type == 'CPUUsage' and item.result then
                        local sum = 0
                        for _, v in ipairs(item.result) do
                            sum = sum + v
                        end
                        ff.cpu = math.floor(sum / #item.result + 0.5)
                    elseif item.type == 'Memory' and item.result then
                        ff.ram_used = math.floor(tonumber(item.result.used) / 1024 ^ 3 * 10) / 10
                        ff.ram_total = math.floor(tonumber(item.result.total) / 1024 ^ 3 * 10) / 10
                    elseif item.type == 'Disk' and item.result and item.result[1] then
                        ff.disk_used = math.floor(tonumber(item.result[1].bytes.used) / 1000 ^ 3 + 0.5)
                        ff.disk_total = math.floor(tonumber(item.result[1].bytes.total) / 1000 ^ 3 + 0.5)
                    end
                end
            end
        end

        -- CPU (only reliable as a % when fastfetch is available)
        local cpu = (ff and ff.cpu) or 0

        -- RAM
        local ram_used, ram_total
        if ff and ff.ram_used then
            ram_used, ram_total = ff.ram_used, ff.ram_total
        else
            local out = term_cmd "free -m | awk '/Mem:/ {print $3, $2}'"
            local u, t = out:match '(%d+)%s+(%d+)'
            ram_used = math.floor((tonumber(u) or 0) / 1024 * 10) / 10
            ram_total = math.floor((tonumber(t) or 1) / 1024 * 10) / 10
        end
        local ram_pct = ram_total > 0 and (ram_used / ram_total * 100) or 0

        -- Disk
        local disk_used, disk_total
        if ff and ff.disk_used then
            disk_used, disk_total = ff.disk_used, ff.disk_total
        else
            local mount = vim.fn.has 'mac' == 1 and '/System/Volumes/Data' or '/'
            local flag = vim.fn.has 'mac' == 1 and '-H' or '-h'
            local out = term_cmd('df ' .. flag .. ' ' .. mount .. " | awk 'NR==2 {print $3, $2}'")
            local u, t = out:match '([%d%.]+)[GMKTB]?%s+([%d%.]+)[GMKTB]?'
            disk_used = math.floor((tonumber(u) or 0) + 0.5)
            disk_total = math.floor((tonumber(t) or 1) + 0.5)
        end
        local disk_pct = disk_total > 0 and (disk_used / disk_total * 100) or 0

        local stats = table.concat({
            '╭────────┬─────────────────────────────────────────╮',
            string.format('│ CPU    │ %-16s %s │', cpu .. '%', ' ' .. gen_graph(cpu)),
            string.format('│ RAM    │ %-16s %s │', ram_used .. '/' .. ram_total .. ' GB', ' ' .. gen_graph(ram_pct)),
            string.format('│ DISK   │ %-16s %s │', disk_used .. '/' .. disk_total .. ' GB', ' ' .. gen_graph(disk_pct)),
            '╰────────┴─────────────────────────────────────────╯',
        }, '\n')

        -- Header
        local headers = {
            [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],

            [[
    _   __                _
   / | / /__  ____ _   __(_)___ ___
  /  |/ / _ \/ __ \ | / / / __ `__ \
 / /|  /  __/ /_/ / |/ / / / / / / /
/_/ |_/\___/\____/|___/_/_/ /_/ /_/]],

            [[
┌┐┌┌─┐┌─┐┬  ┬┬┌┬┐
│││├┤ │ │└┐┌┘││││
┘└┘└─┘└─┘ └┘ ┴┴ ┴]],
        }

        math.randomseed(os.time())
        local header = headers[math.random(#headers)] .. '\n\n' .. stats

        -- Plugin config
        return {
            bigfile = { enabled = true },
            dashboard = {
                enabled = true,
                preset = {
                    header = header,
                    ---@type snacks.dashboard.Item[]
                    keys = {
                        { icon = ' ', key = 'f', desc = 'Find File', action = ':Telescope find_files' },
                        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
                        { icon = ' ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
                        { icon = ' ', key = 'g', desc = 'Find Text', action = ':Telescope live_grep' },
                        { icon = ' ', key = 'c', desc = 'Config', action = ':e ~/.config/nvim/init.lua' },
                        { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
                        { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
                        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
                    },
                },
                sections = {
                    { section = 'header' },
                    { section = 'keys',   gap = 1,    padding = 1 },
                    { section = 'startup' },
                    { pane = 2,           icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
                    { pane = 2,           icon = ' ', title = 'Projects',     section = 'projects',     indent = 2, padding = 1 },
                    {
                        pane = 2,
                        icon = ' ',
                        title = 'Git Status',
                        section = 'terminal',
                        enabled = function()
                            return Snacks.git.get_root() ~= nil
                        end,
                        cmd = 'git status --short --branch --renames',
                        height = 5,
                        padding = 1,
                        indent = 3,
                        win = {
                            winhighlight = 'Normal:Normal,NormalNC:Normal,NormalFloat:Normal',
                        },
                    },
                },
            },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
            styles = {
                notification = {
                    wo = { wrap = true },
                },
            },
        }
    end,
    keys = {
        {
            '<leader>.',
            function()
                Snacks.scratch()
            end,
            desc = 'Toggle Scratch Buffer',
        },
        {
            '<leader>S',
            function()
                Snacks.scratch.select()
            end,
            desc = 'Select Scratch Buffer',
        },
        {
            '<leader>n',
            function()
                Snacks.notifier.show_history()
            end,
            desc = 'Notification History',
        },
        {
            '<leader>bd',
            function()
                Snacks.bufdelete()
            end,
            desc = 'Delete Buffer',
        },
        {
            '<leader>cR',
            function()
                Snacks.rename.rename_file()
            end,
            desc = 'Rename File',
        },
        {
            '<leader>gB',
            function()
                Snacks.gitbrowse()
            end,
            desc = 'Git Browse',
        },
        {
            '<leader>gb',
            function()
                Snacks.git.blame_line()
            end,
            desc = 'Git Blame Line',
        },
        {
            '<leader>gf',
            function()
                Snacks.lazygit.log_file()
            end,
            desc = 'Lazygit Current File History',
        },
        {
            '<leader>gg',
            function()
                Snacks.lazygit()
            end,
            desc = 'Lazygit',
        },
        {
            '<leader>gl',
            function()
                Snacks.lazygit.log()
            end,
            desc = 'Lazygit Log (cwd)',
        },
        {
            ']]',
            function()
                Snacks.words.jump(vim.v.count1)
            end,
            desc = 'Next Reference',
        },
        {
            '[[',
            function()
                Snacks.words.jump(-vim.v.count1)
            end,
            desc = 'Prev Reference',
        },
        {
            '<leader>ad',
            function()
                Snacks.dashboard()
            end,
            desc = 'Open d[A]shboard',
        },
    },
    init = function()
        vim.api.nvim_create_autocmd('User', {
            pattern = 'VeryLazy',
            callback = function()
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd

                ---@diagnostic disable-next-line: duplicate-set-field
                vim.notify = function(msg, level, opts)
                    return Snacks.notifier.notify(msg, level, opts)
                end
            end,
        })
    end,
}
