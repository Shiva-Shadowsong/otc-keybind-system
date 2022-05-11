-- ┌───────────────────────────────────────────┐
--           CLASS: KeybindCategory
--└───────────────────────────────────────────┘
local _D = false -- Enable logging in this script.

-- ►►►► Constructor:

KeybindCategory = {}
function KeybindCategory:create(name)
  local category = {}
  category.name = name
  category.keybinds = {}

  self.__index = self
  setmetatable(category, self)
  return category
end

-- ►►►►►►►►►►►► Public

function KeybindCategory:getKeybinds()
  return self.keybinds
end

function KeybindCategory:getKeybindByName(name)
  for _, kb in pairs(self.keybinds) do
    if kb.name == name then
      return kb
    end
  end
  return nil
end

function KeybindCategory:removeKeybindByName(name)
  local kb = self:getKeybindByName(name)
  if kb then
    kb:remove()
  end
end

function KeybindCategory:addKeybind(Keybind)
  -- TODO: Possibly add limitation here for keybinds with the same name not to be allowed in the self.keybinds table.
  if type(self.keybinds[Keybind.defaultIndex]) == "nil" then
    self.keybinds[Keybind.defaultIndex] = Keybind
  else
    self.keybinds[table.size(self.keybinds) + 1] = Keybind
    pwarning("(KeybindCategory:addKeybind): Keybind " .. Keybind.name .. " could not be inserted at its preferred index (" .. Keybind.defaultIndex .. ") in the category [" .. self.name .. "] because the index is already taken by another keybind (" .. self.keybinds[Keybind.defaultIndex].name .."). Added in the bottom-most index (" .. table.size(self.keybinds) .. ").", _D)
  end
  return true
end

-- ►►►►►►►►►►►► Private

function KeybindCategory:remove()
  for k,v in pairs (self.keybinds) do
    v:remove()
  end
  self.keybinds = {}
end

function KeybindCategory:injectAsOption()
  local module = g_modules.getModule("client_options")
  if module then
    if module:isLoaded() then
      local kbPanel = modules.client_options.getKeybindsPanel()
      local container = kbPanel:getChildById('content')
      local title = g_ui.createWidget('HotkeyTitle', container)
      title:setText(self.name)
    end
  end
end