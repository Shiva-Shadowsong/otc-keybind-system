
-- ┌───────────────────────────────────────────┐
--           CLASS: Keybind Profile
--└───────────────────────────────────────────┘

local _D = false -- Enable logging in this script.

-- ►►►► Constructor:

KeybindProfile = {}

function KeybindProfile:generate(name, config)
  local profile = {}
  self.__index = self
  setmetatable(profile, self)

  profile.name = name
  profile.protected = false
  profile.config = config
  profile.fullpath = KB_PROFILES_PATH .. name .. ".otml"

  if KeybindManager:addProfile(profile) then
    return profile
  end

  return nil
end

-- ►►►►►►►►►►►► Public

function KeybindProfile:getName()
  return self.name
end

function KeybindProfile:getConfig()
  return self.config
end

function KeybindProfile:protect()
  self.protected = true
end

function KeybindProfile:getFullPath()
  return self.fullpath
end

function KeybindProfile:activate(firstActivation)
  if self == KeybindManager.currentProfile then
    pwarn("(KeybindProfile:activate) Profile " .. self.name .. " already active.", _D)
    return
  end
  pinfo("(KeybindProfile:activate) Profile " .. self.name .. " activation begins.", _D)
  -- Purge KeybindManager and prepare for new Profile.
  for _,cat in pairs (KeybindManager:getCategories()) do -- Gracefully remove all existing categories.
    cat:remove()
  end
  KeybindManager.categories = {}

  KeybindManager.currentProfile = self
  KeybindManager.config:set("profile", self.name)

  local UserCategories = self.config:getNode("categories")
  if type(UserCategories) == "nil" then
    UserCategories = {}
  end

  -- Create new categories, by first creating everything from User's cached settings.
  -- We will then attempt to create default categories after that, just in case some of them somehow weren't present in the User cache (e.g. user deleted them manually editing the file, or this is the first time that an empty .otml is being read.)

  pinfo("(KeybindProfile:activate) Creating categories...", _D)
  for userCategoryName, _ in pairs(UserCategories) do
    if not KeybindManager:hasCategoryByName(userCategoryName) then
      KeybindManager:addCategory(KeybindCategory:create(userCategoryName))
    end
  end
  for defaultCatName, defaultCatConfig in pairs (KB_DEFAULTS) do
    if not KeybindManager:hasCategoryByName(defaultCatName) then
      KeybindManager:addCategory(KeybindCategory:create(defaultCatName))
    end
  end

  pinfo("(KeybindProfile:activate) Adding keybinds to categories.", _D)
  local UserKbSettings, UserKbAttribs, DefaultKbSetting, newKeyCombo, newAltKeyCombo, newKeybind
  local compilation = {}
  local existingCategories = table.copy(KeybindManager:getCategories()) -- We will be modifying KeybindManager:getCategories() in the loop, so we can not use it as a reference directly. Looping over a table which is being changed by the loop is a no-no.

  for _, category in pairs(existingCategories) do
    -- Let's first check all existing keybinds, and see what changes we need to make to them to match this profile.
    UserKbSettings = UserCategories[category.name]
    if not table.exists(UserKbSettings) then
      UserKbSettings = {}
    end

    -- Compile a full table of keybind data which we will need to create keybinds out of.
    -- This include data known from the User's cached settings, supplementing for invalid or missing data from the KB_DEFAULTS table.
    -- The data which the compilation potentially knows:
    -- keyCombo: string,      altKeyCombo: string      callback : string      defIndex : number      defKeyCombo : string      defAltKeyCombo : string

    compilation[category.name] = {}

    for UserKbName, UserKbAttribs in pairs (UserKbSettings) do
      compilation[category.name][UserKbName] = {}
      if type(UserKbAttribs.keyCombo) == "string" then
        compilation[category.name][UserKbName].keyCombo = UserKbAttribs.keyCombo
      end
      if type(UserKbAttribs.altKeyCombo) == "string" then
        compilation[category.name][UserKbName].altKeyCombo = UserKbAttribs.altKeyCombo
      end
      if type(UserKbAttribs.callback) == "string" then
        compilation[category.name][UserKbName].callback = UserKbAttribs.callback
      end
    end
  end

  -- Fill the compilation with data that we know is missing, judging by its presence in the KB_DEFAULTS table and absence in the current compilation. Defaults must always exist, whether they be modified by the user or not!

  for defaultCatName, dfCatSett in pairs(KB_DEFAULTS) do
    for defaultKBIndex, defaultKBData in pairs (dfCatSett.content) do
      if type(compilation[defaultCatName][defaultKBData.name]) ~= "table" then
        compilation[defaultCatName][defaultKBData.name] = {}
      end
      local temp = table.copy(defaultKBData)
      table.merge(temp, compilation[defaultCatName][defaultKBData.name])
      compilation[defaultCatName][defaultKBData.name] = table.copy(temp)
      compilation[defaultCatName][defaultKBData.name].defIndex = defaultKBIndex
      compilation[defaultCatName][defaultKBData.name].defKeyCombo = defaultKBData.keyCombo
      compilation[defaultCatName][defaultKBData.name].defAltKeyCombo = defaultKBData.altKeyCombo
    end
  end

  for catName, catContent in pairs(compilation) do
    for kbName, kbSettings in pairs (catContent) do
      if not (KeybindManager:getCategoryByName(catName):getKeybindByName(kbName)) then
        newKeybind = Keybind:create(kbSettings.defIndex, catName, kbName, kbSettings.keyCombo,  kbSettings.altKeyCombo, kbSettings.callback)
        KeybindManager:getCategoryByName(catName):addKeybind(newKeybind)
      else
        newKeybind = KeybindManager:getCategoryByName(catName):getKeybindByName(kbName)
      end

      newKeybind:setDefaultKeycombo(kbSettings.defKeyCombo, kbSettings.defAltKeyCombo)
      newKeybind:setForbiddenWithModifiers(kbSettings.forbiddenWithModifiers and true or false)
      newKeybind:setMuteResistance(kbSettings.resistsMute and true or false)

      if type(kbSettings.bindFunction) ~= "nil" and type(kbSettings.unbindFunction) ~= "nil" then
        newKeybind:setBindMechanisms(kbSettings.bindFunction, kbSettings.unbindFunction)
      end

      if KeybindManager.rememberedFocusBindings[catName] then
        if KeybindManager.rememberedFocusBindings[catName][kbName] then
          newKeybind:setWidgetToBindTo(KeybindManager.rememberedFocusBindings[catName][kbName])
        end
      end

      if not firstActivation then
        newKeybind:activate()
      end
    end
  end

  self:selectAsOption()
  KeybindManager.config:save()
  pinfo("(KeybindProfile:activate) Profile " .. self.name .. " activation done.", _D)
end

function KeybindProfile:delete()
  if self.protected then
    displayErrorBox("Error", "This profile can not be deleted.")
    return false
  end

  if g_resources.fileExists(KB_PROFILES_PATH .. self.name .. ".otml") then
    g_resources.deleteFile(KB_PROFILES_PATH .. self.name .. ".otml")
    if KeybindManager.profile == self then
      KeybindManager:getProfileByName("Default"):activate()
    end
    KeybindManager:removeProfile(self)
    displayInfoBox("Success", "Profile deleted. Switched to Default.")
  else
    displayErrorBox("Error", "No file matching this profile's name was found. Can not delete.")
    return false
  end

  self = nil
  return true
end


-- ►►►►►►►►►►►► Private
  function KeybindProfile:selectAsOption()
    local module = g_modules.getModule("client_options")
    if module then
      if module:isLoaded() then
        local kbPanel = modules.client_options.getKeybindsPanel()
        if kbPanel then
          local profilePicker = kbPanel:getChildById('profilesPanel'):getChildById('profilePicker')
          profilePicker:disable()
          profilePicker:setCurrentOption(self:getName())
          profilePicker:enable()
        end
      end
    end
  end

  function KeybindProfile:injectAsOption()
    local module = g_modules.getModule("client_options")
    if module then
      if module:isLoaded() then
        local kbPanel = modules.client_options.getKeybindsPanel()
        if kbPanel then
          local profilePicker = kbPanel:getChildById('profilesPanel'):getChildById('profilePicker')
          profilePicker:addOption(self:getName(), self:getName())
        end
      end
    end
  end