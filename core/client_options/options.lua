local defaultOptions = {
  vsync = false,
  showFps = false,
  showPing = false,
  fullscreen = true,
  classicControl = true,
  smartWalk = true,
  dashWalk = false,
  autoChaseOverride = true,
  showStatusMessagesInConsole = true,
  showEventMessagesInConsole = true,
  showInfoMessagesInConsole = true,
  showTimestampsInConsole = true,
  showLevelsInConsole = true,
  showPrivateMessagesInConsole = true,
  showPrivateMessagesOnScreen = true,
  showPetEmotesInConsole = true,
  showLeftPanel = true,
  showRightPanel = true,
  foregroundFrameRate = 61,
  backgroundFrameRate = 201,
  painterEngine = 0,
  enableAudio = true,
  RepOptionShowFactions = true,
  RepOptionShowPersonal = true,
  RepOptionShowNeutrals = false,
  RepOptionShowMinipets = true,
  enableMusicSound = true,
  musicSoundVolume = 100,
  enableLights = true,
  ambientLight = 4,
  displayNames = true,
  displayTitles = true,
  displayHealth = true,
  displayMana = true,
  displaySoul = false,
  displayStamina = false,
  displayClass = true,
  displayText = true,
  displayModernCancelMessages = false,
  titleNotificationDurationScroll = 1,
  largeTitleNotificationDuration = 2,
  subtitleDuration = 1,
  modLootParserLoaded = false,
  modBattleListLoaded = false,
  quicktargetting = false,
  quicktargettingkey = "",
  quicktargetrange = 5,
  quicklooting = false,
  viewMode = 2,
  expBarDisplayType = 1,
  allowMultipleLookWindows = false,
  itemLookFixedPosition = false,
  crosshair = 2,
  highlightTile = true
}

local optionsWindow
local optionsButton
local optionsTabBar
local options = {}
local generalPanel
local consolePanel
local keybindsPanel
local graphicsPanel
local soundPanel
local audioButton
local modLootParserButton

local keybindFullScreen = KeybindManager:getKeybindByName("Full Screen", "Interface")
local keybindInfoDisplays = KeybindManager:getKeybindByName("Toggle Info Displays", "Interface")
local keybindClearMessages = KeybindManager:getKeybindByName("Clear Onscreen Messages", "Interface")
local keybindLogOut = KeybindManager:getKeybindByName("Log Out", "Modules")

local function setupGraphicsEngines()
  local enginesRadioGroup = UIRadioGroup.create()
  local ogl1 = graphicsPanel:getChildById('opengl1')
  local ogl2 = graphicsPanel:getChildById('opengl2')
  local dx9 = graphicsPanel:getChildById('directx9')
  enginesRadioGroup:addWidget(ogl1)
  enginesRadioGroup:addWidget(ogl2)
  enginesRadioGroup:addWidget(dx9)

  if g_window.getPlatformType() == 'WIN32-EGL' then
    enginesRadioGroup:selectWidget(dx9)
    ogl1:setEnabled(false)
    ogl2:setEnabled(false)
    dx9:setEnabled(true)
  else
    ogl1:setEnabled(g_graphics.isPainterEngineAvailable(1))
    ogl2:setEnabled(g_graphics.isPainterEngineAvailable(2))
    dx9:setEnabled(false)
    if g_graphics.getPainterEngine() == 2 then
      enginesRadioGroup:selectWidget(ogl2)
    else
      enginesRadioGroup:selectWidget(ogl1)
    end

    if g_app.getOs() ~= 'windows' then
      dx9:hide()
    end
  end

  enginesRadioGroup.onSelectionChange = function(self, selected)
    if selected == ogl1 then
      setOption('painterEngine', 1)
    elseif selected == ogl2 then
      setOption('painterEngine', 2)
    end
  end

  if not g_graphics.canCacheBackbuffer() then
    graphicsPanel:getChildById('foregroundFrameRate'):disable()
    graphicsPanel:getChildById('foregroundFrameRateLabel'):disable()
  end
end

function init()
  for k,v in pairs(defaultOptions) do
    g_settings.setDefault(k, v)
    options[k] = v
  end

  optionsWindow = g_ui.displayUI('options')
  optionsWindow:hide()
  rootWidget:setAutoRepeatDelay(500)

  optionsTabBar = optionsWindow:getChildById('optionsTabBar')
  optionsTabBar:setContentWidget(optionsWindow:getChildById('optionsTabContent'))

  keybindFullScreen:activate()
  keybindInfoDisplays:activate()
  keybindClearMessages:activate()
  keybindLogOut:activate()

  generalPanel = g_ui.loadUI('game')
  optionsTabBar:addTab(tr('Game'), generalPanel, '/images/optionstab/game')

  graphicsPanel = g_ui.loadUI('graphics')
  optionsTabBar:addTab(tr('Video'), graphicsPanel, '/images/optionstab/graphics')

  audioPanel = g_ui.loadUI('audio')
  optionsTabBar:addTab(tr('Audio'), audioPanel, '/images/optionstab/audio')

  layoutPanel = g_ui.loadUI('layout')
  optionsTabBar:addTab(tr('Layout'), layoutPanel, '/images/optionstab/layout')

  consolePanel = g_ui.loadUI('console')
  optionsTabBar:addTab(tr('Console'), consolePanel, '/images/optionstab/console')

  keybindsPanel = g_ui.loadUI('keybinds')
  optionsTabBar:addTab(tr('Keybinds'), keybindsPanel, '/images/optionstab/keybinds')

  modsPanel = g_ui.loadUI('mods')
  optionsTabBar:addTab(tr('Mods'), modsPanel, '/images/optionstab/mods')

  optionsButton = modules.client_topmenu.addLeftButton('optionsButton', tr('Options'), '/images/topbuttons/options', toggle)
  audioButton = modules.client_topmenu.addLeftButton('audioButton', tr('Audio'), '/images/topbuttons/audio', function() toggleOption('enableAudio') end)


  addEvent(function() setup() end)
end

function terminate()
  keybindFullScreen:deactivate()
  keybindInfoDisplays:deactivate()
  keybindClearMessages:deactivate()
  keybindLogOut:deactivate()

  optionsWindow:destroy()
  optionsButton:destroy()
  audioButton:destroy()
end

function getWindow()
  return optionsWindow
end
function getKeybindsPanel()
  return keybindsPanel
end

function setup()
  setupGraphicsEngines()

  -- load options
  for k,v in pairs(defaultOptions) do
    if type(v) == 'boolean' then
      setOption(k, g_settings.getBoolean(k), true)
    elseif type(v) == 'number' then
      setOption(k, g_settings.getNumber(k), true)
    end
  end

  local optvalue1 = g_settings.getString("quicktargettingkey")
  if optvalue1 == '' then optvalue1 = 'none' end

  configureKeybindsPanel()
end

function toggle()
  if optionsWindow:isVisible() then
    hide()
  else
    show()
  end
end

function show()
  optionsWindow:show()
  optionsWindow:raise()
  optionsWindow:focus()
end

function hide()
  optionsWindow:hide()
end

function toggleDisplays()
  if options['displayNames'] and options['displayTitles'] and options['displayHealth'] then
    setOption('displayTitles', false)
  elseif options['displayNames'] and options['displayTitles'] then
    setOption('displayTitles', false)
  elseif options['displayNames'] and options['displayHealth'] then
    setOption('displayNames', false)
  elseif options['displayTitles'] then
    setOption('displayTitles', false)
  elseif options['displayHealth'] then
    setOption('displayHealth', false)
  else
    if not options['displayNames'] and not options['displayHealth'] then
      if not options['displayTitles'] then
        setOption('displayTitles', true)
      end
      setOption('displayNames', true)
    else
      setOption('displayHealth', true)
    end
  end
end

function toggleOption(key)
  setOption(key, not getOption(key))
end

function setOption(key, value, force)
  if not force and options[key] == value then return end
  local gameMapPanel = modules.game_interface.getMapPanel()

  if key == 'vsync' then
    g_window.setVerticalSync(value)
  elseif key == 'showFps' then
    modules.client_topmenu.setFpsVisible(value)
  elseif key == 'showPing' then
    modules.client_topmenu.setPingVisible(value)
  elseif key == 'fullscreen' then
    g_window.setFullscreen(value)
  	modules.game_loadingscreens.resizeLoadingScreen()
  elseif key == 'enableAudio' then
    g_sounds.setAudioEnabled(value)
    if value then
      audioButton:setIcon('/images/topbuttons/audio')
    else
      audioButton:setIcon('/images/topbuttons/audio_mute')
    end
  elseif key == 'enableMusicSound' then
    g_sounds.getChannel(SoundChannels.Music):setEnabled(value)
  elseif key == 'musicSoundVolume' then
    g_sounds.getChannel(SoundChannels.Music):setGain(value/100)
    audioPanel:getChildById('musicSoundVolumeLabel'):setText(tr('Music volume: %d', value))
--[[  elseif key == 'zoomScroller' then
    layoutPanel:getChildById('layoutScrPanel2'):getChildById('zoomLabel'):setText(tr('View Distance: %d', value))
	g_settings.set("zoomValue", value)
	modules.game_interface.updateZoomValue(g_settings.getNumber('zoomValue'))
  elseif key == 'visibleDimensionYScroller' then
    layoutPanel:getChildById('layoutScrPanel2'):getChildById('visibleDimensionY'):setText(tr('Visible Dimension Y: %d', value))
	g_settings.set("visibleDimensionY", value)
	modules.game_interface.updateVisibleDimensions(g_settings.getNumber('visibleDimensionX'), g_settings.getNumber('visibleDimensionY'))
  elseif key == 'visibleDimensionXScroller' then
    layoutPanel:getChildById('layoutScrPanel2'):getChildById('visibleDimensionX'):setText(tr('Visible Dimension X: %d', value))
	g_settings.set("visibleDimensionX", value)
	modules.game_interface.updateVisibleDimensions(g_settings.getNumber('visibleDimensionX'), g_settings.getNumber('visibleDimensionY'))
	print("Set dimensions to: " ..g_settings.getNumber('visibleDimensionX').. " | " ..g_settings.getNumber('visibleDimensionY').. ".")
  elseif key == 'limitVisibleRange' then
    gameMapPanel:setLimitVisibleRange(layoutPanel:getChildById('layoutScrPanel2'):getChildById("limitVisibleRange"):isChecked()) ]]--
  elseif key == 'showLeftPanel' then
	  modules.game_interface.totalHideLeftPanel(value)
  elseif key == 'showRightPanel' then
	  modules.game_interface.totalHideRightPanel(value)
  elseif key == 'titleNotificationDurationScroll' then
    if value == 3 then
      generalPanel:getChildById('titleNotificationDuration'):setText(tr('Small Notification Duration: Automatic'))
    else
      generalPanel:getChildById('titleNotificationDuration'):setText(tr('Small Notification Duration: %d seconds', value))
    end
  elseif key == 'largeTitleNotificationDuration' then
    if value == 4 then
      generalPanel:getChildById('largeTitleNotificationDurationLabel'):setText(tr('Large Notification Duration: Automatic'))
    else
      generalPanel:getChildById('largeTitleNotificationDurationLabel'):setText(tr('Large Notification Duration: %d seconds', value))
    end
  elseif key == 'quicktargetrange' then
	  generalPanel:getChildById('extraOptions2'):getChildById('quickTargetRangeLabel'):setText(tr('Detect range: %d sqm', value))
  elseif key == 'subtitleDuration' then
    if value == 7 then
    generalPanel:getChildById('subtitleDurationLabel'):setText(tr('Subtitle Popup Duration: Automatic'))
    else
      generalPanel:getChildById('subtitleDurationLabel'):setText(tr('Subtitle Popup Duration: %d seconds', value))
    end
  elseif key == "modLootParserLoaded" then
    if value == true then
      loadNamedModule("mod_lootparser", "modLootParserButton")
    else
      unloadNamedModule("mod_lootparser", "modLootParserButton")
    end
    updateModuleButton("mod_lootparser", "modLootParserButton")
  elseif key == "modBattleListLoaded" then
    if value == true then
      loadNamedModule("game_battle", "modBattleListButton")
    else
      unloadNamedModule("game_battle", "modBattleListButton")
    end
    updateModuleButton("mod_lootparser", "modLootParserButton")
  elseif key == 'backgroundFrameRate' then
    local text, v = value, value
    if value <= 0 or value >= 201 then text = 'max' v = 0 end
    graphicsPanel:getChildById('backgroundFrameRateLabel'):setText(tr('Game framerate limit: %s', text))
    g_app.setBackgroundPaneMaxFps(v)
  elseif key == 'foregroundFrameRate' then
    local text, v = value, value
    if value <= 0 or value >= 61 then  text = 'max' v = 0 end
    graphicsPanel:getChildById('foregroundFrameRateLabel'):setText(tr('Interface framerate limit: %s', text))
    g_app.setForegroundPaneMaxFps(v)
  elseif key == 'enableLights' then
    gameMapPanel:setDrawLights(0)
    graphicsPanel:getChildById('ambientLight'):setEnabled(0)
    graphicsPanel:getChildById('ambientLightLabel'):setEnabled(0)
  elseif key == 'ambientLight' then
    graphicsPanel:getChildById('ambientLightLabel'):setText(tr('Ambient light: %s%%', 0))
    gameMapPanel:setMinimumAmbientLight(0/100)
    gameMapPanel:setDrawLights( value < 100)
  elseif key == 'painterEngine' then
    g_graphics.selectPainterEngine(2)
  elseif key == 'displayNames' then
    gameMapPanel:setDrawNames(value)
  elseif key == 'displayTitles' then
    gameMapPanel:setDrawTitles(value)
  elseif key == 'displayHealth' then
    gameMapPanel:setDrawHealthBars(value)
  elseif key == 'displayMana' then
    gameMapPanel:setDrawManaBars(value)
  elseif key == 'displaySoul' then
    gameMapPanel:setDrawSoulBars(value)
  elseif key == 'displayClass' then
    gameMapPanel:setDrawClassBars(value)
  elseif key == 'displayStamina' then
    gameMapPanel:setDrawStaminaBars(value)
  elseif key == 'displayText' then
    gameMapPanel:setDrawTexts(value)
  elseif key == 'displayModernCancelMessages' then
  elseif key == 'allowMultipleLookWindows' then
  elseif key == 'itemLookFixedPosition' then
  elseif key == 'highlightTile' then
  elseif key == 'crosshair' then
    local xhair_settings = {
      [1] = "",
      [2] = "/images/crosshair/default.png",
      [3] = "/images/crosshair/full.png",
      [4] = "/images/crosshair/corners.png"
    }
    gameMapPanel:setCrosshair(xhair_settings[value] and xhair_settings[value] or xhair_settings[1])
  end

  -- change value for keybind updates
  for _,panel in pairs(optionsTabBar:getTabsPanel()) do
    local widget = panel:recursiveGetChildById(key)
    if widget then
      if widget:getStyle().__class == 'UICheckBox' then
        widget:setChecked(value)
      elseif widget:getStyle().__class == 'UIScrollBar' then
        widget:setValue(value)
      end
      break
    end
  end

  g_settings.set(key, value)
  options[key] = value
end

function getOption(key)
  return options[key]
end

function addTab(name, panel, icon)
  optionsTabBar:addTab(name, panel, icon)
end

function addButton(name, func, icon)
  optionsTabBar:addButton(name, func, icon)
end

function clickModuleLoaderButton(name, buttonid)
  local module = g_modules.getModule(name)
	local button = modsPanel:getChildById("modContentPanel"):getChildById(buttonid)

	if button:getText() == "Disable" then
		unloadNamedModule(name)
	else
		loadNamedModule(name)
	end
	updateModuleButton(name, buttonid)
end

function unloadNamedModule(name)
    local module = g_modules.getModule(name)
	if module then
		module:unload()
		g_settings.set("modLootParserLoaded", false)
		g_settings.set("modBattleListLoaded", false)
		options["modLootParserLoaded"] = false
		options["modBattleListLoaded"] = false
	end
end

function loadNamedModule(name)
    local module = g_modules.getModule(name)
	if module then
		module:reload()
		g_settings.set("modLootParserLoaded", true)
		g_settings.set("modBattleListLoaded", true)
		options["modLootParserLoaded"] = true
		options["modBattleListLoaded"] = true
	end
end

function updateModuleButton(name, buttonid)
	local button = modsPanel:getChildById("modContentPanel"):getChildById(buttonid)
	 local module = g_modules.getModule(name)
	if module:isLoaded() then
		button:setText("Disable")
	else
		button:setText("Enable")
	end
end

function setViewModeName(name, desc)
  layoutPanel:getChildById("layoutScrPanel2"):getChildById("viewModeName"):setText(name)
  layoutPanel:getChildById("layoutScrPanel2"):getChildById("viewModeDescription"):setText(desc)
end

function togglePetEmotes()
    if not g_game.isOnline() then
        displayErrorBox("Error", "You need to be logged in.")
    else
        g_game.talk("!petemotes")
    end
end

--------------------------------------
-------- Keybinds Panel -------------

function configureKeybindsPanel()
  local container = keybindsPanel:getChildById('content')

  for k,v in pairs(container:getChildren()) do
    if v:getId() ~= "permanentHeading" then
      v:destroy()
    end
  end

  local categories = KeybindManager:getCategories()

  for categoryIndex, categoryObject in pairs(categories) do
    categoryObject:injectAsOption()

    for keybindIndex, keybindObject in pairs (categoryObject.keybinds) do
      keybindObject:injectAsOption()
    end
  end

  ------ Configure profile presets combo box:
  local profilesPanel = keybindsPanel:getChildById('profilesPanel')
  local profilePicker = profilesPanel:getChildById('profilePicker')

  for _, profile in pairs(KeybindManager.profiles) do
    profilePicker:addOption(profile:getName(), profile:getName())
  end

  profilePicker:setCurrentOption(KeybindManager.currentProfile:getName())
  profilePicker.onOptionChange = function(self)
    KeybindManager:getProfileByName(self:getCurrentOption().text):activate()
  end

  profilesPanel:getChildById('createProfile').onClick = function()
    local capturer = g_ui.createWidget('TextInputCaptureWindow', rootWidget)
    capturer:getChildById('context'):setText('Enter a name for your new profile.')

    local cancelButton = capturer:getChildById('cancelButton')
    cancelButton.onClick = function()
      capturer:destroy()
    end

    local confirmButton = capturer:getChildById('confirmButton')
    confirmButton:setText("Create")
    confirmButton.onClick = function(self)
      local text = self:getParent():getChildById('textCapture'):getText()
      local prof = KeybindManager:createProfile(text)
      if prof then
        prof:activate()
      end
      capturer:destroy()
    end
  end

  profilesPanel:getChildById('deleteProfile').onClick = function()
    local prof = KeybindManager:getProfileByName(profilePicker:getCurrentOption().text)
    if prof then
      local currentOpt = profilePicker:getCurrentOption().text -- prof:delete will change this, so we need to grab it now before it's changed.
      profilePicker:disable()
      if prof:delete() then
        profilePicker:removeOption(currentOpt)
      end
      profilePicker:enable()
    else
      perror("Can not delete profile, unable to retrieve it from the registry.")
    end
  end

  --- Configure Chat Mode Panel
  local tryAutoSwitchCheckbox = profilesPanel:getChildById('tryAutoSwitchCheckbox')
  local modePanel = keybindsPanel:getChildById('modePanel')
  local helpbtn = modePanel:getChildById('modePanelHelp')
  local useChatMode = modePanel:getChildById('useChatMode')
  local useNoChatMode = modePanel:getChildById('useNoChatMode')

  -- Tooltip
  local helptooltip = {
    type = 1,
    image_size = "32 32",
    image = "/images/game/icons/small/keyboard",
    header_color = "#c7ab41",
    text_color = "#b3af9c",
    text_two_color = "#b3af9c",

    header = "Chat Modes",
    text = "\nThey determine whether the [Enter] key will be used to activate the chat console or not, and each use their own set of keybinds",
    subheader = "Modes:",

    text_two = "\208 Classic: --------------\nChat is always active. We recommend using F1-F12, Arrows and Numpads for binds, as everything else will be registered as input to the chat console.\n\n\208 Modern: -------------- \nChat is inactive. Press [Enter] to start typing. We recommend this mode if you want to use all parts of your keyboard for binds (e.g. WASD for walking, 1-9 for abilities, etc.)"
  }

  local autoSwitchTooltip = {
    type = 1,
    image_size = "32 32",
    image = "/images/game/icons/small/keyboard",
    header_color = "#c7ab41",
    text_color = "#b3af9c",
    text_two_color = "#b3af9c",
    header = "Auto Profile Switcher",
    text = "\nWhen logging into a character, we will try to automatically switch to a profile that matches the character's name (e.g. 'John Smith'), or its class name (e.g. 'Defender').",
    text_two = "If neither are found, you will keep using the same profile that was loaded."
  }

  addEvent(function()
    helpbtn:setExTooltip(helptooltip)
    tryAutoSwitchCheckbox:setExTooltip(autoSwitchTooltip)
    tryAutoSwitchCheckbox:setChecked(KeybindManager.autoProfileSwitching)
    tryAutoSwitchCheckbox.onCheckChange = function()
      KeybindManager.toggleAutoProfileSwitching(KeybindManager)
    end
  end)

  -- Configure the Classic / Modern radio:
  local ChatModeRadio = UIRadioGroup.create()
  ChatModeRadio:addWidget(useChatMode)
  ChatModeRadio:addWidget(useNoChatMode)
  -- Before Radio group reacts to input, manually check the box which we are using by detecting it from our User settings.
  if KeybindManager:getChatMode() == CHAT_MODE_CLASSIC then
    ChatModeRadio:selectWidget(useChatMode)
  else
    ChatModeRadio:selectWidget(useNoChatMode)
  end

  connect(ChatModeRadio, { onSelectionChange = function(radioGroup, selectedWidget)
    KeybindManager:toggleChatMode()
  end})

  -- Configure the search box
  local searchPanel = keybindsPanel:getChildById('searchPanel')
  local searchBox = searchPanel:getChildById('searchBox')
  searchPanel:getChildById('clearSearchButton').onClick = function()
    searchBox:setText('')
  end

  local resetAllBtn = container:recursiveGetChildById('resetAllButton')
  resetAllBtn.onClick = function()
    KeybindManager:resetToDefaults()
  end

end

alreadyHiddenKeybindNodes = {}
function keybindsSearchboxChange(searchBar)
  local container = keybindsPanel:getChildById('content')
  local insertedNodes = container:getChildren()
  local labelToSearch

  -- If we are not searching for anything anymore, or saercBar has only 1 character, reveal everything.
  if searchBar:getText() == '' or searchBar:getText():len() < 2 then
    for k,v in pairs (alreadyHiddenKeybindNodes) do
      v:setHeight(v.origHeight)
    end
    alreadyHiddenKeybindNodes = {}
    return true
  end

  for k,v in pairs (insertedNodes) do
    -- Hide all titles.
    if v:getStyleName() == "HotkeyTitle" and v:getHeight() > 0 then
      v.origHeight = v:getHeight()
      v:setHeight(0)
      alreadyHiddenKeybindNodes[v:getId()] = v
    end
    -- Hide only specific hotkeys.
    if v:getStyleName() == "HotkeyNode" then
      labelToSearch = ""
      labelToSearch = labelToSearch .. v:getChildById('leftCompartment'):getChildById('hotkeyName'):getText()
      labelToSearch = labelToSearch .. v:getChildById('middleCompartment'):getChildById('keyCombo'):getText()
      labelToSearch = labelToSearch .. v:getChildById('middleCompartment'):getChildById('altKeyCombo'):getText()

      -- If we don't find that the hotkey node mentions the searched term, minify it to 0 height, otherwise, restore it if it was minified.

      if not string.find(string.lower(labelToSearch), string.lower(searchBar:getText())) then
        if v:getHeight() > 0 then
          v.origHeight = v:getHeight()
          v:setHeight(0)
          alreadyHiddenKeybindNodes[v:getId()] = v
        end
      else
        if alreadyHiddenKeybindNodes[v:getId()] then
          v:setHeight(v.origHeight)
          alreadyHiddenKeybindNodes[v:getId()] = nil
        end
      end
    end
  end
end