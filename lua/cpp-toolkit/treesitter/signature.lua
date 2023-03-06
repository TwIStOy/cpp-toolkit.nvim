local M = {}

local SignatureBase = {
  return_type = nil,
  name = nil,
  class = nil,
  parameters = nil,
  specifiers = nil,
  template = nil,
}



---comment
---@param node tsnode
function M.extract_signature_from_node(node)
  local signature = {
    return_type = nil,
    name = nil,
    class = nil,
    parameters = nil,
    specifiers = nil,
    template = nil,
  }

end

return M
