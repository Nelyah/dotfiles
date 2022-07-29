local M = {}

local registered = false

M.setup = function(handle_file)
  if registered then
    return
  end
  registered = true

  local has_cmp, cmp = pcall(require, 'cmp')
  if not has_cmp then
    return
  end

  local source = {}

  source.new = function()
    return setmetatable({}, {__index = source})
  end

  source.get_keyword_pattern = function()
    -- Add dot to existing keyword characters (\k).
    return [[\%(\k\|\.\)\+]]
  end

  source.complete = function(_, request, callback)
    local input = string.sub(request.context.cursor_before_line, request.offset - 1)
    -- local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)

    local gitcommit_keywords = {
        'Addresses:',
        'Co-Authored-By:',
        'Resolves:',
        'Approved-by:',
        'Reviewed-by:',
        'Signed-off-by:',
    }

    if request.context.cursor.col <= 2 then
      local items = {}
      for _, keyword in ipairs(gitcommit_keywords) do
        table.insert(items, {
            filterText = keyword,
            label = keyword,
            textEdit = {
              newText = keyword,
              range = {
                start = {
                  line = request.context.cursor.row - 1,
                  character = request.context.cursor.col - 1 - #input,
                },
                ['end'] = {
                  line = request.context.cursor.row - 1,
                  character = request.context.cursor.col - 1,
                },
              },
            },
          }
        )
      end
      callback {
        items = items,
        isIncomplete = true,
      }
    else
      callback({isIncomplete = true})
    end
  end

  cmp.register_source('gitcommit_keywords', source.new())

end

return M

