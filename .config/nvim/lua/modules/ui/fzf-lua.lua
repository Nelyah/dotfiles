local M = {}

local default_fzf_opts = {
	["--layout"] = "default",
}

function M.setup()
	local fzf = require("fzf-lua")
	fzf.setup({})

	vim.keymap.set("n", "<leader>i", function()
		fzf.live_grep_native({
			cwd_prompt = false,
			fzf_opts = default_fzf_opts,
		})
	end)
	vim.keymap.set("n", "<leader>o", function()
		fzf.files({
			header = false,
			cwd_prompt = false,
			fzf_opts = default_fzf_opts,
		})
	end)
	vim.keymap.set("n", "<leader>x", function()
		fzf.commands({ fzf_opts = default_fzf_opts })
	end)
	vim.keymap.set("n", "<leader>s", function()
		fzf.blines({ fzf_opts = default_fzf_opts })
	end)
	vim.keymap.set("n", "<c-x>h", function()
		fzf.help_tags({ fzf_opts = default_fzf_opts })
	end)
	vim.keymap.set("n", ",", function()
		fzf.buffers({ fzf_opts = default_fzf_opts })
	end)

	vim.api.nvim_create_user_command("FT", function()
		fzf.filetypes({ fzf_opts = default_fzf_opts })
	end, {})
end

return M
