local M = {}

local SQ = 0x27 -- U+0027 APORSTROPHE
local DQ = 0x22 -- U+0022 QUOTATION MARK
local SP = 0x20 -- U+0020 SPACE
local HT = 0x09 -- U+0009 CHARACTER TABULATION
local LF = 0x0A -- U+000A LINE FEED (LF)
local CR = 0x0D -- U+000D CARRIAGE RETURN (CR)
local BS = 0x5C -- U+005C REVERSE SOLIDUS

function M.split(s)
  local token
  local state
  local escape = false
  local result = {}
  for i = 1, #s do
    local c = s:byte(i)
    local v = string.char(c)
    if state == SQ then
      if c == SQ then
        state = nil
      else
        token[#token + 1] = v
      end
    elseif state == DQ then
      if escape then
        if c == DQ or c == BS then
          token[#token + 1] = v
        else
          token[#token + 1] = "\\"
          token[#token + 1] = v
        end
        escape = false
      else
        if c == DQ then
          state = nil
        elseif c == BS then
          escape = true
        else
          token[#token + 1] = v
        end
      end
    else
      if escape then
        token[#token + 1] = v
        escape = false
      else
        if c == SP or c == HT or c == LF or c == CR then
          if token ~= nil then
            result[#result + 1] = table.concat(token)
            token = nil
          end
        else
          if token == nil then
            token = {}
          end
          if c == SQ then
            state = SQ
          elseif c == DQ then
            state = DQ
          elseif c == BS then
            escape = true
          else
            token[#token + 1] = v
          end
        end
      end
    end
  end

  if state ~= nil then
    error "no closing quotation"
  end
  if escape then
    error "no escaped character"
  end

  if token ~= nil then
    result[#result + 1] = table.concat(token)
  end
  return result
end

return M
