local M = {}

M.Kind = { Current = 1, Base = 2, Separator = 3, Incoming = 4, Eof = 5 }

local patterns = {
	["<"] = { kind = M.Kind.Current, pattern = "^(<+)(.*)$" },
	["|"] = { kind = M.Kind.Base, pattern = "^(|+)(.*)$" },
	["="] = { kind = M.Kind.Separator, pattern = "^(=+)(.*)$" },
	[">"] = { kind = M.Kind.Incoming, pattern = "^(>+)(.*)$" },
}

function M.is_candidate(prefix)
	return patterns[prefix] ~= nil
end

function M.lex(line, row)
	local marker = patterns[line:sub(1, 1)]
	if not marker then
		return nil
	end
	local run, suffix = line:match(marker.pattern)
	if #run < 7 then
		return nil
	end
	if suffix ~= "" and not suffix:match("^%s") then
		return nil
	end
	if marker.kind == M.Kind.Separator and not suffix:match("^%s*$") then
		return nil
	end
	return { kind = marker.kind, row = row, width = #run }
end

function M.parse(tokens)
	local conflicts, rejected = {}, {}
	local current
	for _, token in ipairs(tokens) do
		if token.kind == M.Kind.Current and (not current or token.width == current.first.width) then
			if current then
				rejected[#rejected + 1] = current
			end
			current = { first = token }
		elseif current and (token.kind == M.Kind.Eof or token.width == current.first.width) then
			if token.kind == M.Kind.Base
				and not current.base and not current.separator then
				current.base = token
			elseif token.kind == M.Kind.Separator
				and not current.separator then
				current.separator = token
			elseif token.kind == M.Kind.Incoming
				and current.separator then
				current.last = token
				conflicts[#conflicts + 1] = current
				current = nil
			else
				rejected[#rejected + 1] = current
				current = nil
			end
		end
	end
	return conflicts, rejected
end

return M
