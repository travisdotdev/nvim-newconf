require('telescope').setup({})
require('gitsigns').setup()
require('which-key').setup({})
require('nvim-autopairs').setup({})
require('toggleterm').setup({
    size = 15,
    open_mapping = '<leader>tf',
    direction = 'horizontal',
	shade_terminals = false,
})
require('lualine').setup({
	options = {
		theme = 'tokyonight',
		icons_enabled = true,
	}
})
require('neo-tree').setup({
	filesystem = {
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = false,
		},
		window = {
			mappings = {
				['\\'] = 'close_window',
			},
		},
	},
})
require('snacks').setup({
    bigfile = { enabled = true },
    dashboard = {
        enabled = true,
        preset = {
            header = (function()
				local headers = {
[[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
[[
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
				return headers[math.random(#headers)]
			end)(),
			keys = {
                { icon = ' ', key = 'f', desc = 'Find File',    action = ':Telescope find_files' },
                { icon = ' ', key = 'n', desc = 'New File',     action = ':ene | startinsert' },
                { icon = ' ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
                { icon = ' ', key = 'g', desc = 'Find Text',    action = ':Telescope live_grep' },
                { icon = ' ', key = 'c', desc = 'Config',       action = ':e ~/.config/nvim-new/init.lua' },
                { icon = ' ', key = 'q', desc = 'Quit',         action = ':qa' },
            },
        },
        sections = {
            { section = 'header' },
            { section = 'keys',      gap = 1, padding = 1 },
            { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
            { pane = 2, icon = ' ', title = 'Projects',     section = 'projects',     indent = 2, padding = 1 },
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
})

