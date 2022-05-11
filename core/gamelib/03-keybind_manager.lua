
-- ┌───────────────────────────────────────────┐
--      CLASS (Singleton): KeybindManager
--└───────────────────────────────────────────┘

local _D = false -- Enable logging in this script.

-- ►►►► Constructor:

local _keybindManager = {}
function _keybindManager:create()
    local manager = {}
    manager.categories = {}
    manager.profiles = {}
    manager.capturer = nil
    manager.config = g_configs.create("/keybinds.otml") -- .create tries to load it first, if it doesn't find it, then it creates it.
    manager.keyComboMode = manager.config:getNumber("selectedKeyComboMode", KEYCOMBO_MODE_REGULAR)
    manager.autoProfileSwitching = manager.config:getBoolean("autoProfileSwitching", false)
    manager.currentProfile = nil
    manager.defaultProfile = nil
    manager.keybindToWidgetAssociations = {}
    manager.rememberedFocusBindings = {}
    manager.keybindsMuted = false

    self.__index = self
    setmetatable(manager, self)
    return manager
end

-- ►►►► Public:

function _keybindManager:initialize()
  -- Ensure the KB_PROFILES_PATH is a fully available path. We will need to write configs there.
  if not g_resources.directoryExists("/profiles") then
    g_resources.makeDir("/profiles") -- Edge case: User deleted the folder while the game is running, despite init.lua creating it when the game started. This will handle it.
    pwarn("Couldn't find /profiles. Created it.", _D)
  end

  if not g_resources.directoryExists(KB_PROFILES_PATH) then
    g_resources.makeDir("/profiles/keybinds")
    pwarn("Couldn't find /profiles/keybinds. Created it.", _D)
  end

  self:createDefaultProfile()

  -- Detect and load all profiles from the keybinds folder.
  local detectedProfiles = {}
  for _, filename in pairs(g_resources.listDirectoryFiles(KB_PROFILES_PATH)) do
    local f = filename:gsub("%.otml", "")
    table.insert(detectedProfiles, f) -- Cut out "".otml" from their names.
  end

  -- Create Profile objects to have them read for use, for each of the loaded files.
  -- Don't take 'default' into account, it was created by force earlier.
  for _, name in pairs (detectedProfiles) do
    if string.lower(name) ~= "default" then
      local cfg = g_configs.create(KB_PROFILES_PATH .. name .. ".otml")
      if type(cfg) == "userdata" then
        KeybindProfile:generate(name, cfg)
      else
        perror("(Keybind Manager: Initialize) Unable to load profile for " .. name .. ", a proper configuration object could not be initialized based on " .. g_resources.getUserDir() .. KB_PROFILES_PATH .. name .. ".otml. The file may be corrupt or completely empty. If this issue persists, it could be resolved by removing the file. If saving this configuration is important to you, you may submit the file to the staff for an analysis.")
      end
    end
  end

  -- Based on last used profile, activate one of the profiles.
  -- If it fails, load the default profile. Dev must hardcode the default profile to always load properly!
  local profileToLoad = self.config:getString("profile")
  local profile = self:getProfileByName(profileToLoad)
  if type(profile) == "nil" then
    profile = self:getProfileByName("Default")
  end
  profile:activate(true)
end

----- Profile Management ------
function _keybindManager:createProfile(name)
  local contentToCopy, nameTemp
  if g_resources.fileExists(self.currentProfile:getFullPath()) then
    contentToCopy = g_resources.readFileContents(self.currentProfile:getFullPath())
  else
    displayErrorBox("Error", "Could not copy over your current profile. The file likely went missing or corrupt. Copying from the default profile instead.")
    if self.defaultProfile then
      contentToCopy =  g_resources.readFileContents(self.defaultProfile:getFullPath())
    else
      displayErrorBox("Warning", "Unable to locate Default keybind profile. Something has gone terribly wrong. >:(\nWe will create the Default profile again for you. Report this incident to the NecroniaTeam if related errors persist.")
      self:createDefaultProfile()
      return self:createProfile(name)
    end
    return
  end
  -- Create new profile and config file, then fill it with the contents of the current profile file.

  pinfo("Working on creating " .. name .. " profile. Copied from " .. (g_resources.fileExists(self.currentProfile:getFullPath()) and self.currentProfile.name or "DEFAULT"), _D)

  g_configs.create(KB_PROFILES_PATH .. name .. ".otml")
  g_resources.writeFileContents(KB_PROFILES_PATH .. name .. ".otml", contentToCopy)

  local newProfile = KeybindProfile:generate(name, g_configs.get(KB_PROFILES_PATH .. name .. ".otml"))
  if newProfile then
    return newProfile
  end
  return
end

function _keybindManager:createDefaultProfile()
  self.defaultProfile = KeybindProfile:generate("Default", g_configs.create(KB_PROFILES_PATH .. "default.otml"))
  self.defaultProfile:protect()
end

function _keybindManager:getProfileByName(name)
  for _, v in pairs(self.profiles) do
    if string.lower(v.name) == string.lower(name) then
      return v
    end
  end
end

function _keybindManager:addProfile(profile)
  for _, prof in pairs(self.profiles) do
    if prof.name == profile.name then
      pwarn("(KeybindManager:addProfile) Can not register profile " .. profile.name .. ". Another with the same name exists.", _D)
      return false
    end
  end

  table.insert(self.profiles, profile)
  pinfo("(KeybindManager:addProfile): Profile " .. profile.name .. " registered.")

  profile:injectAsOption()
  return true
end

function _keybindManager:removeProfile(profile)
  local indexFound
  for k,v in pairs (self.profiles) do
    if v.name == profile.name then
      indexFound = k
    end
  end
  if indexFound then
    self.profiles[k] = nil
  end
end

----- Category Management ------

function _keybindManager:getCategories()
  return self.categories
end

function _keybindManager:hasCategoryByName(name)
  for _, category in pairs (self.categories) do
    if name == category.name then
      return true
    end
  end
  return false
end

function _keybindManager:getCategoryByName(name)
  for k,v in pairs (self.categories) do
    if string.lower(name) == string.lower(v.name) then
      return v
    end
  end
  return nil
end

function _keybindManager:addCategory(KeybindCategoryObject)
  -- Preferred index of the category can not be allowed to go out of bounds in order to maintain an Ordered Table.
  local prefIndex = table.find(KB_CATEGORY_LOAD_ORDER, KeybindCategoryObject.name)
  if type(prefIndex) == "number" and not (type(self.categories[prefIndex]) == "table") then
    self.categories[prefIndex] = KeybindCategoryObject
  else
    self.categories[table.size(self.categories) + 1] = KeybindCategoryObject
  end
end

----- Keybind Management ------

function _keybindManager:getKeybindByName(name, categoryname)
  local category = self:getCategoryByName(categoryname)
  if category then
    for _,v in pairs (category.keybinds) do
      if string.lower(name) == string.lower(v.name) then
        return v
      end
    end
    pwarn("(KeybindManager:getKeybindByName("..name.."," ..categoryname..")): Not found.", _D)
  else
    pwarn("(KeybindManager:getKeybindByName("..name.."," ..categoryname..")): Invalid category.", _D)
  end
  pwarn("(KeybindManager:getKeybindByName("..name.."," ..categoryname..")): Returned nil.", _D)
  return nil
end

function _keybindManager:getKeyComboMode()
  return self.keyComboMode
end
_keybindManager.getChatMode = _keybindManager.getKeyComboMode -- Alias

function _keybindManager:resetToDefaults()
  for catIndex, catObject in pairs (self:getCategories()) do
    for kbIndex, kbObject in pairs (catObject:getKeybinds()) do
      kbObject:reset()
    end
  end
end

function _keybindManager:toggleAutoProfileSwitching()
  self.autoProfileSwitching = not(self.autoProfileSwitching)
  self.config:set("autoProfileSwitching", self.autoProfileSwitching)
  self.config:save()
end

function _keybindManager:toggleChatMode()
  local prevMode = self.keyComboMode
  self.keyComboMode = (self.keyComboMode == KEYCOMBO_MODE_REGULAR) and KEYCOMBO_MODE_ALT or KEYCOMBO_MODE_REGULAR
  -- Propagate the change to all categories and the keybinds they hold:
  for catIndex, catObject in pairs (self:getCategories()) do
    for kbIndex, kbObject in pairs (catObject:getKeybinds()) do
      -- Don't unbind and rebind the key if it's using the same exact keyCombo.
      if kbObject.keyCombo ~= kbObject.altKeyCombo then
        kbObject:deactivate(prevMode)
        kbObject:activate(self.keyComboMode)
      end
      kbObject:updateWidgets()
    end
  end

  self.config:set("selectedKeyComboMode", self.keyComboMode)
  self.config:save()

  -- Also deal with other modules that have a significant change due to this function triggering:
  local module = g_modules.getModule("game_console")
  if module then
    if module:isLoaded() then
      if self:getChatMode() == CHAT_MODE_MODERN then
        modules.game_console.disableChat()
      else
        modules.game_console.enableChat()
      end
    end
  end
end

function _keybindManager:rememberFocusBindingFor(Keybind)
  if type(self.rememberedFocusBindings[Keybind.category]) ~= "table" then
    self.rememberedFocusBindings[Keybind.category] = {}
  end
  self.rememberedFocusBindings[Keybind.category][Keybind.name] = Keybind.bindToWidget
end


function _keybindManager:setAssociationBetween(Keybind, widget)
  if type(widget:recursiveGetChildById('keyCombo')) == "nil" or type(widget:recursiveGetChildById('altKeyCombo')) == "nil" then
    perror("(KeybindManager:setAssociationBetween("..Keybind.name .. " | "..widget:getId().. ")) Can not associate because the widget is missing a direct child with ID 'keyCombo' OR 'altKeyCombo'. Needs both.", _D)
    return
  end

  if type(self.keybindToWidgetAssociations[Keybind.category]) ~= "table" then
    self.keybindToWidgetAssociations[Keybind.category] = {}
  end
  if type(self.keybindToWidgetAssociations[Keybind.category][Keybind.name]) ~= "table" then
    self.keybindToWidgetAssociations[Keybind.category][Keybind.name] = {}
  end

  local widgets = self.keybindToWidgetAssociations[Keybind.category][Keybind.name]
  widgets[table.size(widgets) + 1] = widget
end

-- ►►►► Private:
--[[

KeybindManager:createCapturer("Hi", "Context", function(capturedKeyCombo)

end)

]]
function _keybindManager:createCapturer(context, callbackConfirm, callbackCancel)
  -- Define default callbacks and validate inputted ones
  local function defaultCancel()
    self.capturer:destroy()
    self.capturer = nil
  end

  local function defaultConfirm()
    defaultCancel()
  end

  if type(callbackConfirm) ~= "function" then
    callbackConfirm = defaultConfirm
  end

  if type(callbackCancel) ~= "function" then
    callbackCancel = defaultCancel
  end

  -- Kill previously existing capturer, if exists. Should only have one.
  if self.capturer then
    defaultCancel()
  end

  -- Create new capturer
  self.capturer = g_ui.createWidget('CapturerWindow', rootWidget)

  -- Change context text
  self.capturer:getChildById('context'):setText(context)

  self.capturer:grabKeyboard()

  -- Change Context Text
  local capturePreview = self.capturer:getChildById('capturePreview')
  capturePreview:resizeToText()

  -- Define Capture function.
  local function capture(thisWindow, keyCode, keyboardModifiers)
    local keyCombo = g_keyboard.determineKeyComboDescription(keyCode, keyboardModifiers)
    if keyCombo == 'Escape' then -- We can not bind onEscape to the main window because grabKeyboard overrides it, so this hack still lets us ignore Esc and close the window with it.
      callbackCancel()
      return
    end

    capturePreview:setText(keyCombo)
    capturePreview.keyCombo = keyCombo
    capturePreview:resizeToText()
    thisWindow:getChildById('confirmButton'):enable()
    thisWindow:getChildById('confirmButton').onClick = nil
    thisWindow:getChildById('confirmButton').onClick = function()
      callbackConfirm(keyCombo)
      self.capturer:destroy()
      self.capturer = nil
    end
    return true
  end

  -- Bind events to UI elements
  self.capturer:getChildById('confirmButton'):disable()
  self.capturer:getChildById('cancelButton').onClick = defaultCancel
  self.capturer.onKeyDown = capture

  self.capturer:raise()
  return self.capturer

  --[[
    KeybindManager:createCapturer("Press a combination of keys to use as your keybind:", function(capturedKeyCombo)
      print("Captured: " .. capturedKeyCombo)
    end)
  ]]
end

-- ►►►► Create singleton:
KeybindManager = _keybindManager:create()
KeybindManager:initialize()

