local handles = {}

local Job = require("plenary.job")

local registered = false

local register_source = function(json_string)
	if registered then
		return
	end
	registered = true

	local has_cmp, cmp = pcall(require, "cmp")
	if not has_cmp then
		return
	end
	local success, handles_with_names_and_emails = pcall(function()
		return vim.fn.json_decode(json_string)
	end)

	if not success then
		return
	end

	local source = {}

	source.new = function()
		return setmetatable({}, { __index = source })
	end

	source.get_trigger_characters = function()
		return { "@" }
	end

	source.get_keyword_pattern = function()
		-- Add dot to existing keyword characters (\k).
		return [[\%(\k\|\.\)\+]]
	end

	source.complete = function(_, request, callback)
		local input = string.sub(request.context.cursor_before_line, request.offset - 1)
		local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)

		if vim.startswith(input, "@") and (prefix == "@" or vim.endswith(prefix, " @")) then
			local items = {}
			for handle, name_and_email in pairs(handles_with_names_and_emails) do
				table.insert(items, {
					filterText = handle .. " " .. name_and_email,
					label = name_and_email,
					textEdit = {
						newText = name_and_email,
						range = {
							start = {
								line = request.context.cursor.row - 1,
								character = request.context.cursor.col - 1 - #input,
							},
							["end"] = {
								line = request.context.cursor.row - 1,
								character = request.context.cursor.col - 1,
							},
						},
					},
				})
			end
			callback({
				items = items,
				isIncomplete = true,
			})
		else
			callback({ isIncomplete = true })
		end
	end

	cmp.register_source("handles", source.new())
end

handles.setup = function()
	local json_lines = {}

	Job:new({
		command = "jq",
		args = {
			"-s",
			"--compact-output",
			[[
            map (select(keys[] != "jenkins" and keys[] != "terrier-lottery-results-domain"))
            | reduce .[] as $item ({}; . + $item)
        ]],
		},
		writer = Job:new({
			command = "sed",
			args = {
				"-r",
				"-e",
				"/<>/d",
				"-e",
				's/"//g',
				"-e",
				's/^(.*<([^@]+)@.*)$/{"\\2": "\\1"}/',
			},
			writer = Job:new({
				command = "sort",
				args = { "-u" },
				writer = Job:new({
					command = "git",
					args = { "log", "--oneline", "--format=format:%aN <%ae>" },
				}),
			}),
		}),
		on_stdout = function(_, line)
			table.insert(json_lines, line)
		end,
		on_exit = function(_, _)
			local timer = vim.loop.new_timer()
			timer:start(
				0,
				0,
				vim.schedule_wrap(function()
					register_source(json_lines)
				end)
			)
		end,
	}):start()
end

return handles
