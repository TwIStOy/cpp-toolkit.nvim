---@class CppClass
---@field name string
---@field template CppTemplate|nil
---@field is_specialization boolean
---@field as_name fun(self: CppClass): string

---@class CppTemplate
---@field parameters CppTemplateParameter[]

---@class CppTemplateParameter
---@field text string
---@field identifier string|nil

---@class CppFunctionReturnType
---@field text string

---@class CppFunctionSignature
---@field classes CppClass[]|nil
---@field template CppTemplate|nil
---@field return_type ReturnTypeInfo
---@field body string
---@field qualifiers string[]
