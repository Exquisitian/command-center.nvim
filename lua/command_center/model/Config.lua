local Component = require("command_center.model.Component")

---@class Config
---@field components {[integer]: Component} the components to be rendered in the propmt
---@field sort_by {[integer] : Component } the default ordering of commands in the prompt
---@field separator string the separator between each component in the prompt
---@field auto_replace_desc_with_cmd boolean automatically replace empty desc with cmd
---@field telescope {[string]: any} | nil
---@field prompt_title string the title of the prompt
local Config = {}
Config.__mt = { __index = Config }

---Return default configuration
---@return Config the defualt config
function Config:new()
  return setmetatable({
    components = {
      Component.DESC,
      Component.KEYS,
      Component.CMD,
      Component.CAT,
    },

    sort_by = {
      Component.DESC,
      Component.KEYS,
      Component.CMD,
      Component.CAT,
    },

    separator = " ",
    auto_replace_desc_with_cmd = true,
    prompt_title = "Command Center",

    telescope = {
      integrate = false,
      theme = require("telescope._extensions.command_center.theme"),
    },
  }, Config.__mt)
end

---Update config
---@param config Config
---@return Config updated config
function Config:update(config)
  self.components = config.components or self.components
  self.sort_by = config.sort_by or self.sort_by
  self.separator = config.separator or self.separator
  self.auto_replace_desc_with_cmd = config.auto_replace_desc_with_cmd or self.auto_replace_desc_with_cmd
  self.prompt_title = config.prompt_title or self.prompt_title

  if config.telescope and config.telescope.integrate then
    self.telescope.integrate = true
    self.theme = config.theme or self.theme
  end

  return self
end

return Config
