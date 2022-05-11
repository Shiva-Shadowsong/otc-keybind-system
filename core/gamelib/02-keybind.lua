
-- ┌───────────────────────────────────────────┐
--                CLASS: Keybind
--└───────────────────────────────────────────┘

-- TODO, when inserting on preferred index, if preferred index is larger than the largest one currently in the table, it will break the Ordered Table. Handle it.

local _D = false -- Enable logging in this script.

-- ►►►► Constructor:

Keybind = {}
function Keybind:create(defaultIndex, category, name, keyCombo, altKeyCombo, callback, ...)
    local kbind = {}
    kbind.category = category
    kbind.name = name
    kbind.keyCombo = "<none>"
    kbind.altKeyCombo = "<none>"
    kbind.callback = callback
    kbind.callbackName = nil
    kbind.args = {...}
    kbind.active = false
    kbind.bindFunction = g_keyboard.bindKeyDown
    kbind.unbindFunction = g_keyboard.unbindKeyDown
    kbind.bindToWidget = nil
    kbind.defaultKeyCombo = "<none>"
    kbind.defaultAltKeyCombo = "<none>"
    kbind.defaultIndex = 1
    kbind.forbiddenWithModifiers = false
    kbind.resistsMute = false

    self.__index = self
    setmetatable(kbind, self)

    if type(defaultIndex) == "number" then
      if defaultIndex > 0 then
        kbind.defaultIndex = defaultIndex
      end
    end

    if type(callback) == "string" then
      if type(KB_CALLBACKS[callback]) ~= "nil" then
        kbind.callbackName = callback
        kbind.callback = KB_CALLBACKS[callback]
      else
        perror("(Keybind:Create) Could not create keybind because the callback provided was a string that could not be converted into a function because no function with that name exists in KB_CALLBACKS. KB_CALLBACKS are case-sensitive in their naming, could that be the issue here?", _D)
        return nil
      end
    end

    if kbind:validate(keyCombo, altKeyCombo) then
      kbind.keyCombo = keyCombo
      kbind.altKeyCombo = altKeyCombo
      kbind:updateWidgets()
      kbind:cache()
      pinfo("(Keybind:Create) Created: [" .. name .. "] (" ..keyCombo .. " | " .. altKeyCombo .. ").", _D)
      return kbind
    end

    return nil
end

-- ►►►►►►►►►►►► Public

function Keybind:validate(regularKey, altKey)
  -- Validate
  if type(regularKey) ~= "string" then
    pinfo("(Keybind:update: validation) Can not update keybind, keyCombo is not a string but: " .. type(regularKey))
    return false
  end
  if type(altKey) ~= "string" then
    pinfo("(Keybind:update: validation) Can not update keybind, keyCombo is not a string but: " .. type(altKey))
    return false
  end

  if self.forbiddenWithModifiers then
    local cantPass = false
    if string.lower(regularKey):find("shift") or string.lower(regularKey):find("ctrl") or string.lower(regularKey):find("alt") then
      regularKey = "<none>"
      displayErrorBox("Warning!", "Keybind [" .. self.name .. "] does not accept modified keyboard keys as input. Do not use the Control, Shift or Alt keys for this keybind. The keybind has been set to <none> until you change it again.")
      cantPass = true
    end

    if string.lower(altKey):find("shift") or string.lower(altKey):find("ctrl") or string.lower(altKey):find("alt") then
      altKey = "<none>"
      displayErrorBox("Warning!", "Keybind [" .. self.name .. "] does not accept modified keyboard keys as input. Do not use the Control, Shift or Alt keys for this keybind. The keybind has been set to <none> until you change it again.")
      cantPass = true
    end

    if cantPass then
      return false
    end
  end

  -- Check if it overrides any other existing combo. (Ignore cases where it is set to "<none>")
  for _, category in pairs(KeybindManager:getCategories()) do
    for _, keybind in pairs(category.keybinds) do
      if not (keybind.name == self.name and keybind.category == self.category) then
        if keybind.keyCombo == regularKey and regularKey ~= "<none>" then
          keybind:update("<none>", keybind.altKeyCombo)
          displayErrorBox("Warning", "While validating [" .. self.name .. "] to use the key combo (" .. regularKey .. "), found another Keybind: [" .. keybind.name .. "] which was already using that combo. It was overwritten.", _D)
        end
        if keybind.altKeyCombo == altKey and altKey ~= "<none>" then
          keybind:update(keybind.keyCombo, "<none>")
          displayErrorBox("Warning", "While validating [" .. self.name .. "] to use the key combo (" .. altKey .. "), found another Keybind: [" .. keybind.name .. "] which was already using that combo. It was overwritten.", _D)
        end
      end
    end
  end

  return true
end

function Keybind:update(regularKey, altKey)
  if self.keyCombo ~= regularKey or self.altKeyCombo ~= altKey then

    if not self:validate(regularKey, altKey) then
      return false
    end

    -- Unbind previously used combo by this keybind.
    -- Bind new one.

    if self.keyCombo ~= regularKey then
      if self.active and (KeybindManager.keyComboMode == KEYCOMBO_MODE_REGULAR) then
        self:unbind(KEYCOMBO_MODE_REGULAR)
      end

      self.keyCombo = regularKey

      if self.active and self.keyCombo ~= "<none>" and (KeybindManager.keyComboMode == KEYCOMBO_MODE_REGULAR) then
        self:bind(KEYCOMBO_MODE_REGULAR)
      end
    end

    if self.altKeyCombo  ~= altKey then
      if self.active and (KeybindManager.keyComboMode == KEYCOMBO_MODE_ALT) then
        self:unbind(KEYCOMBO_MODE_ALT)
      end

      self.altKeyCombo = altKey

      if self.active and self.altKeyCombo ~= "<none>" and (KeybindManager.keyComboMode == KEYCOMBO_MODE_ALT) then
        self:bind(KEYCOMBO_MODE_ALT)
      end
    end

    -- Run visual update on all associated widgets.
    self:updateWidgets()
    self:cache()
  end
  return true
end

function Keybind:reset(mode)
  local regKey = self.defaultKeyCombo
  local altKey = self.defaultAltKeyCombo
  if mode == KEYCOMBO_MODE_REGULAR then
    altKey = self.altKeyCombo
  end
  if mode == KEYCOMBO_MODE_ALT then
    regKey = self.keyCombo
  end
  self:update(regKey, altKey)
end

function Keybind:clear(mode)
  if mode == KEYCOMBO_MODE_REGULAR then
    self:update("<none>", self.altKeyCombo)
  elseif mode == KEYCOMBO_MODE_ALT then
    self:update(self.keyCombo,"<none>")
  else
    self:update("<none>","<none>")
  end
end

function Keybind:updateWidgets(removed)
    if not table.exists(KeybindManager.keybindToWidgetAssociations[self.category]) then
      return
    end
    if not table.exists(KeybindManager.keybindToWidgetAssociations[self.category][self.name]) then
      return
    end

    for _, widget in pairs (KeybindManager.keybindToWidgetAssociations[self.category][self.name]) do
      local keyComboLabel = widget:getChildById('keyCombo')
      local altKeyComboLabel = widget:getChildById('altKeyCombo')

      if type(keyComboLabel) == "nil" or type(altKeyComboLabel) == "nil" then
          pwarn("(Keybind:updateWidgets()) Could not update widget of keybind [" .. self.name .. "] - its keyCombo or altKeyCombo child is missing. Tip: It must be a DIRECT child of the widget associated with the keycombo!")
        return
      end

      if keyComboLabel:getText() ~= self.keyCombo then
        keyComboLabel:setText(type(removed) == "nil" and self.keyCombo or "??")
      end
      if altKeyComboLabel:getText() ~= self.altKeyCombo then
        altKeyComboLabel:setText(type(removed) == "nil" and self.altKeyCombo or "??")
      end

      if KeybindManager.keyComboMode == KEYCOMBO_MODE_ALT then
        keyComboLabel:setColor(self.keyCombo ~= "<none>" and "#8F8572" or "#770000")
        altKeyComboLabel:setColor(self.altKeyCombo ~= "<none>" and "#C3C647" or "#CC0000")
      else
        keyComboLabel:setColor(self.keyCombo ~= "<none>" and "#C3C647" or "#CC0000")
        altKeyComboLabel:setColor(self.altKeyCombo ~= "<none>" and "#8F8572" or "#770000")
      end
    end
end

function Keybind:getDefaultKeycombo(mode)
  if mode == KEYCOMBO_MODE_REGULAR then
    return self.defaultKeyCombo
  elseif mode == KEYCOMBO_MODE_ALT then
    return self.defaultAltKeyCombo
  end
end

function Keybind:setDefaultKeycombo(keyCombo, altKeyCombo)
  if type(keyCombo) ~= "string" then
    pwarn("(Keybind:setDefaultKeycombo: validation) Setting empty keyCombo because, keyCombo is not a string but: " .. type(keyCombo), _D)
    self.defaultKeyCombo = "<none>"
  else
    self.defaultKeyCombo = keyCombo
  end

  if type(altKeyCombo) ~= "string" then
    pwarn("(Keybind:setDefaultKeycombo: validation) Setting empty altKeyCombo because, altkeyCombo is not a string but: " .. type(keyCombo), _D)
    self.defaultAltKeyCombo = "<none>"
  else
    self.defaultAltKeyCombo = altKeyCombo
  end
end

function Keybind:setBindMechanisms(bindfunc, unbindfunc)
  if type(bindfunc) == "function" and type(unbindfunc) == "function" then
    self.bindFunction = bindfunc
    self.unbindFunction = unbindfunc
  end
end

function Keybind:setWidgetToBindTo(widget)
  pinfo("[" .. self.name .. "]: Set widget to bind to: " .. (widget and widget:getId() or "nil"), _D)
  self.bindToWidget = widget
  KeybindManager:rememberFocusBindingFor(self)
end

function Keybind:setForbiddenWithModifiers(state)
  self.forbiddenWithModifiers = state
end

function Keybind:setMuteResistance(state)
  self.resistsMute = state
end

function Keybind:activate(mode)
  if not self.active then
    if self.category ~= "" then
      if type(mode) == "nil" then
        self:bind((KeybindManager.keyComboMode == KEYCOMBO_MODE_ALT) and KEYCOMBO_MODE_ALT or KEYCOMBO_MODE_REGULAR)
      else
        self:bind(mode)
      end

      self.active = true
    else
      perror("(Keybind:activate): Can not activate a keybind which is not installed into a KeybindCategory.")
    end
  end
end

function Keybind:deactivate(mode)
  if self.active then
    if type(mode) == "nil" then
      self:unbind((KeybindManager.keyComboMode == KEYCOMBO_MODE_ALT) and KEYCOMBO_MODE_ALT or KEYCOMBO_MODE_REGULAR)
    else
      self:unbind(mode)
    end
    self.active = false
  end
end

-- ►►►►►►►►►►►► Private

function Keybind:remove(decache)
  self:unbind()
  self:updateWidgets(true)
  if decache then
    self:decache(true)
  end
  self = nil
end

function Keybind:decache(save)
  local UserKeybindSettings = KeybindManager.currentProfile:getConfig() -- Load Config object.
  local UserCatDetails = UserKeybindSettings:getNode("categories")
  if UserCatDetails then
    if table.exists(UserCatDetails[self.category]) then
      if table.exists(UserCatDetails[self.category][self.name]) then
        UserCatDetails[self.category][self.name] = nil
        KeybindManager.currentProfile:getConfig():setNode("categories", UserCatDetails)
      end
    end
    if save then
      KeybindManager.currentProfile:getConfig():save()
    end
  end
end

-- Save to the local configuration file.
function Keybind:cache()
  local UserKeybindSettings = KeybindManager.currentProfile:getConfig() -- Load Config object.
  local UserCatDetails = UserKeybindSettings:getNode("categories")

  -- If there are no categories yet at all, then UserCatDetails isn't a table. Make it be.
  if type(UserCatDetails) == "nil" then
    UserCatDetails = {}
  end

  -- If there is no category yet to which this keybind should belong, create a table for it.
  if not table.exists(UserCatDetails[self.category]) then
      UserCatDetails[self.category] = {}
  end

  -- If there is no Category[KEYBINDNAME] field, add it to hold an empty table.
  if not table.exists(UserCatDetails[self.category][self.name]) then
    UserCatDetails[self.category][self.name] = {}
  end
  local UserThisKeybindSetting = UserCatDetails[self.category][self.name]

  -- If neither key is no different than the default key, we can remove the config entry.
  -- We only keep local data about things that are different from defaults.
  -- Otherwise, prepare it to be saved.

  if self.keyCombo == "" then
    UserThisKeybindSetting["keyCombo"] = nil
  else
    UserThisKeybindSetting["keyCombo"] = self.keyCombo
  end

  if self.altKeyCombo == "" then
    UserThisKeybindSetting["altKeyCombo"] = nil
  else
    UserThisKeybindSetting["altKeyCombo"] = self.altKeyCombo
  end

  -- If the table is completely empty after we've made all changes, nullify it so it doesnt waste space in the cache.
  if table.empty(UserThisKeybindSetting) then
    UserCatDetails[self.category][self.name] = nil
    if table.empty(UserCatDetails[self.category]) then
      UserCatDetails[self.category] = nil
    end
  end

  UserKeybindSettings:setNode("categories", UserCatDetails)
  UserKeybindSettings:save()
end

function Keybind:bind(mode)
    local bindCallback = function()
      if KeybindManager.keybindsMuted then
        if not self.resistsMute then
          return
        end
      end
      return self.callback()
    end

    if type(mode) == "number" then
      if mode == KEYCOMBO_MODE_REGULAR then
        if self.keyCombo ~= "<none>" then
          self.bindFunction(tostring(self.keyCombo), bindCallback, self.bindToWidget)
        end
      elseif mode == KEYCOMBO_MODE_ALT then
        if self.altKeyCombo ~= "<none>" then
          self.bindFunction(tostring(self.altKeyCombo), bindCallback, self.bindToWidget)
        end
      end
    else
      if self.keyCombo ~= "<none>" then
        self.bindFunction(tostring(self.keyCombo), bindCallback, self.bindToWidget)
      end
      if self.altkeyCombo ~= "<none>" then
        self.bindFunction(tostring(self.altKeyCombo), bindCallback, self.bindToWidget)
      end
    end

    pinfo("(Keybind:bind(" .. (type(mode) == "number" and mode or "both") .. "): [" .. self.category .. "] -> [" .. self.name .. "] with key combos (" .. self.keyCombo .. " | " .. self.altKeyCombo .. ") to widget: " .. (self.bindToWidget and self.bindToWidget:getId() or "nil") .. "", _D)
end

function Keybind:unbind(mode)
    if type(mode) == "number" then
      if mode == KEYCOMBO_MODE_REGULAR then
          if self.keyCombo ~= "<none>" then
            self.unbindFunction(self.keyCombo, self.bindToWidget)
          end
      elseif mode == KEYCOMBO_MODE_ALT then
        if self.altKeyCombo ~= "<none>" then
          self.unbindFunction(self.altKeyCombo, self.bindToWidget)
        end
      end
    else
      if self.altKeyCombo ~= "<none>" then
        self.unbindFunction(self.altKeyCombo, self.bindToWidget)
      end
      if self.keyCombo ~= "<none>" then
        self.unbindFunction(self.keyCombo, self.bindToWidget)
      end
    end

    pinfo("(Keybind:unbind (" .. (type(mode) == "number" and mode or "both") .. ")): [" .. self.category .. "] -> [" .. self.name .. "]", _D)
end

function Keybind:injectAsOption()
  local module = g_modules.getModule("client_options")
  if module then
    if module:isLoaded() then
      local keybindsPanel = modules.client_options.getKeybindsPanel()
      local container = keybindsPanel:getChildById('content')
      local hotkeyNode = g_ui.createWidget('HotkeyNode', container)
      local middleCompartment = hotkeyNode:getChildById('middleCompartment')
      local rightCompartment = hotkeyNode:getChildById('rightCompartment')

      hotkeyNode:getChildById('leftCompartment'):getChildById('hotkeyName'):setText(self.name)
      KeybindManager:setAssociationBetween(self, middleCompartment)
      self:updateWidgets()

      middleCompartment:getChildById('keyCombo').onClick = function()
        local tip = "Press a combination of keys to use for to trigger [" .. self.name .. "].\nCurrently: " .. self.keyCombo .. "."

        KeybindManager:createCapturer(tip, function(capturedKeyCombo)
          self:update(capturedKeyCombo, self.altKeyCombo)
        end)
      end

      middleCompartment:getChildById('altKeyCombo').onClick = function()
        local tip = "Press a combination of keys to use for to trigger alternative [" .. self.name .. "].\nCurrently: " .. self.altKeyCombo .. "."

        KeybindManager:createCapturer(tip, function(capturedKeyCombo)
          self:update(self.keyCombo, capturedKeyCombo)
        end)
      end

      rightCompartment:getChildById('clearButton').onClick = function()
        self:clear(KeybindManager:getKeyComboMode())
      end
      rightCompartment:getChildById('resetButton').onClick = function()
        self:reset(KeybindManager:getKeyComboMode())
      end
    end
  end
end