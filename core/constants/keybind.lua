KEYCOMBO_MODE_REGULAR = 1
KEYCOMBO_MODE_ALT = 2
CHAT_MODE_CLASSIC = KEYCOMBO_MODE_REGULAR
CHAT_MODE_MODERN = KEYCOMBO_MODE_ALT

KB_PROFILES_PATH = "/profiles/keybinds/" -- Relative to the UserDirectory.

KB_CATEGORY_LOAD_ORDER = {
  "Movement", "Turning", "Combat", "Interface", "Modules"
}

KB_CALLBACKS = {
  ["Walk North"]            = function() return North end,
  ["Walk West"]             = function() return West end,
  ["Walk South"]            = function() return South end,
  ["Walk East"]             = function() return East end,
  ["Walk NorthEast"]        = function() return NorthEast end,
  ["Walk NorthWest"]        = function() return NorthWest end,
  ["Walk SouthEast"]        = function() return SouthEast end,
  ["Walk SouthWest"]        = function() return SouthWest end,
  ["Turn North"]            = function() g_game.turn(North) modules.game_playercontrols.changeWalkDir(North) end,
  ["Turn West"]             = function() g_game.turn(West) modules.game_playercontrols.changeWalkDir(West) end,
  ["Turn South"]            = function() g_game.turn(South) modules.game_playercontrols.changeWalkDir(South) end,
  ["Turn East"]             = function() g_game.turn(East) modules.game_playercontrols.changeWalkDir(East) end,
  ["Untarget/Unfollow"]     = function() g_game.cancelAttackAndFollow() end,
  ["Quick Target"]          = function() modules.game_autoattack.chooseAimFromBattleList() end,
  ["Toggle Module Manager"] = function() modules.client_modulemanager.toggle() end,
  ["Show Terminal"]         = function() modules.client_terminal.toggle() end,
  ["Show Battle List"]      = function() modules.game_battle.toggle() end,
  ["Show Bug Reporter"]     = function() modules.game_bugreport.show() end,
  ["Show Player Reporter"]  = function() modules.game_console.openPlayerReportRuleViolationWindow() end,
  ["Show Help"]             = function() modules.game_console.openHelp() end,
  ["Show Inventory"]        = function() modules.game_inventory.toggle() end,
  ["Show Quest Log"]        = function() g_game.requestQuestLog() end,
  ["Show Skills and Stats"] = function() modules.game_skills.toggle() end,
  ["Show Necronia Store"]   = function() modules.game_store.toggle() end,
  ["Show Friend List"]      = function() modules.game_viplist.toggle() end,
  ["Show Quick Loot Settings"] = function() modules.game_quickloot.toggle() end,
  ["Show Rule Violation Manager"] = function() modules.game_ruleviolation.show() end,
  ["Toggle Mount"]          = function() modules.game_playermount.toggleMount() end,
  ["Log Out"]               = function() modules.game_interface.tryLogout(false) end,
  ["Character Select Screen"] = function() modules.client_entergame.EnterGame.openWindow() end,
  ["Full Screen"]           = function() modules.client_options.toggleOption('fullscreen') end,
  ["Chat Tab Close"]        = function() modules.game_console.removeCurrentTab() end,
  ["Chat Channel Manager"]  = function() g_game.requestChannels() end,
  ["Chat History Previous"] = function()
    if modules.game_console.isInChat() then
      modules.game_console.navigateMessageHistory(1)
    end
  end,
  ["Chat History Next"]     = function()
    if modules.game_console.isInChat() then
      modules.game_console.navigateMessageHistory(-1)
    end
  end,
  ["Chat Tab Next"]         = function() modules.game_console.consoleTabBar:selectNextTab() end,
  ["Chat Tab Previous"]     = function() modules.game_console.consoleTabBar:selectPrevTab() end,
  ["Chat Send Message"]     = function() modules.game_console.pressChatSendButton() end,
  ["Chat Clean All"]        = function() modules.game_console.consoleTextEdit:clearText() end,
  ["Chat Mode Switch"]      = function() KeybindManager:toggleChatMode() end,
  ["Minimap Move Left"]     = function() modules.game_console.minimapWidget:move(1,0) end,
  ["Minimap Move Right"]    = function() modules.game_console.minimapWidget:move(-1,0) end,
  ["Minimap Move Up"]       = function() modules.game_console.minimapWidget:move(0,1) end,
  ["Minimap Move Down"]     = function() modules.game_console.minimapWidget:move(0,-1) end,
  ["Minimap Fullscreen"]    = function() modules.game_console.toggleFullMap() end,
  ["Toggle Info Displays"]  = function() modules.client_options.toggleDisplays() end,
  ["Clear Onscreen Messages"] = function() g_map.cleanTexts() modules.game_textmessage.clearMessages() end
}

KB_DEFAULTS = {
  ["Movement"] = {
    content = {
      [1] = {
        name = 'Walk North',
        keyCombo = 'Up',
        altKeyCombo = 'W',
        callback = "Walk North",
        bindFunction = g_keyboard.bindWalkKey,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [2] = {
        name = 'Walk West',
        keyCombo = 'Left',
        altKeyCombo = 'A',
        callback = "Walk West",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [3] = {
        name = 'Walk South',
        keyCombo = 'Down',
        altKeyCombo = 'S',
        callback = "Walk South",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [4] = {
        name = 'Walk East',
        keyCombo = 'Right',
        altKeyCombo = 'D',
        callback = "Walk East",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [5] = {
        name = 'Walk NorthEast',
        keyCombo = 'Numpad9',
        altKeyCombo = 'E',
        callback = "Walk NorthEast",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [6] = {
        name = 'Walk NorthWest',
        keyCombo = 'Numpad7',
        altKeyCombo = 'Q',
        callback = "Walk NorthWest",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [7] = {
        name = 'Walk SouthEast',
        keyCombo = 'Numpad3',
        altKeyCombo = 'C',
        callback = "Walk SouthEast",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      },
      [8] = {
        name = 'Walk SouthWest',
        keyCombo = 'Numpad1',
        altKeyCombo = 'Z',
        callback = "Walk SouthWest",
        bindFunction = function(key, dir)
          g_keyboard.bindWalkKey(key, dir)
        end,
        unbindFunction = g_keyboard.unbindWalkKey,
        forbiddenWithModifiers = true
      }
    }
  },
  ["Turning"] = {
    content = {
      [1] = {
        name = "Turn North",
        keyCombo = 'CTRL+Up',
        altKeyCombo = 'SHIFT+W',
        callback = "Turn North"
      },
      [2] = {
        name = "Turn West",
        keyCombo = 'CTRL+Left',
        altKeyCombo = 'SHIFT+A',
        callback = "Turn West"
      },
      [3] = {
        name = "Turn South",
        keyCombo = 'CTRL+Down',
        altKeyCombo = 'SHIFT+S',
        callback = "Turn South"
      },
      [4] = {
        name = "Turn East",
        keyCombo = 'CTRL+Right',
        altKeyCombo = 'SHIFT+D',
        callback = "Turn East"
      }
    }
  },
  ["Combat"] = {
    content = {
      [1] = {
        name = "Untarget/Unfollow",
        keyCombo = 'ESCAPE',
        altKeyCombo = 'ESCAPE',
        callback = "Untarget/Unfollow"
      },
      [2] = {
        name = "Quick Target",
        keyCombo = 'TAB' ,
        altKeyCombo = 'TAB',
        callback = "Quick Target"
      }
    }
  },
  ["Modules"] = {
    content = {
      [1] = {
        name = 'Toggle Module Manager',
        keyCombo = 'CTRL+SHIFT+V',
        altKeyCombo = 'CTRL+SHIFT+V',
        callback = "Toggle Module Manager",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress
      },
      [2] = {
        name = "Show Terminal",
        keyCombo = 'CTRL+SHIFT+T',
        altKeyCombo = 'CTRL+SHIFT+T',
        callback = "Show Terminal"
      },
      [3] = {
        name = "Show Battle List",
        keyCombo = 'Ctrl+B',
        altKeyCombo = 'Ctrl+B',
        callback = "Show Battle List"
      },
      [4] = {
        name = "Show Bug Reporter",
        keyCombo = 'Ctrl+Shift+Z',
        altKeyCombo = 'Ctrl+Shift+Z',
        callback = "Show Bug Reporter"
      },
      [5] = {
        name = "Show Player Reporter",
        keyCombo = 'Ctrl+R',
        altKeyCombo = 'Ctrl+R',
        callback = "Show Player Reporter"
      },
      [6] = {
        name = "Show Help",
        keyCombo = 'Ctrl+H',
        altKeyCombo = 'Ctrl+H',
        callback = "Show Help"
      },
      [7] = {
        name = "Show Inventory",
        keyCombo = 'Ctrl+I',
        altKeyCombo = 'Ctrl+I',
        callback = "Show Inventory"
      },
      [8] = {
        name = "Show Quest Log",
        keyCombo = 'Ctrl+J',
        altKeyCombo = 'Ctrl+J',
        callback = "Show Quest Log"
      },
      [9] = {
        name = "Show Quick Loot Settings",
        keyCombo = 'Ctrl+D',
        altKeyCombo = 'Ctrl+D',
        callback = "Show Quick Loot Settings"
      },
      [10] = {
        name = "Show Skills and Stats",
        keyCombo = 'Ctrl+S',
        altKeyCombo = 'Ctrl+S',
        callback = "Show Skills and Stats"
      },
      [11] = {
        name = "Show Necronia Store",
        keyCombo = 'Ctrl+U',
        altKeyCombo = 'Ctrl+U',
        callback = "Show Necronia Store"
      },
      [12] = {
        name = "Show Friend List",
        keyCombo = 'Ctrl+P',
        altKeyCombo = 'Ctrl+P',
        callback = "Show Friend List"
      },
      [13] = {
        name = "Show Rule Violation Manager",
        keyCombo = 'Ctrl+Y',
        altKeyCombo = 'Ctrl+Y',
        callback = "Show Rule Violation Manager"
      },
      [14] = {
        name = 'Toggle Mount',
        keyCombo = 'CTRL+M',
        altKeyCombo = 'CTRL+M',
        callback = "Toggle Mount"
      },
      [15] = {
        name = 'Log Out',
        keyCombo = 'CTRL+Q',
        altKeyCombo = 'CTRL+Q',
        callback = "Log Out"
      }
    }
  },

  ["Interface"] = {
    content = {
      [1] = {
        name = "Character Select Screen",
        keyCombo = 'Ctrl+G',
        altKeyCombo = 'Ctrl+G',
        callback = "Character Select Screen"
      },
      [2] = {
        name = "Full Screen",
        keyCombo = 'Ctrl+Shift+F',
        altKeyCombo = 'Ctrl+Shift+F',
        callback = "Full Screen",
        resistsMute = true
      },
      [3] = {
        name = "Chat Tab Close",
        keyCombo = 'Ctrl+E',
        altKeyCombo = 'Ctrl+E',
        callback = "Chat Tab Close",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [4] = {
        name = "Chat Channel Manager",
        keyCombo = 'Ctrl+O',
        altKeyCombo = 'Ctrl+O',
        callback = "Chat Channel Manager",
        resistsMute = true
      },
      [5] = {
        name = "Chat History Previous",
        keyCombo = 'Shift+Up',
        altKeyCombo = 'Shift+Up',
        callback = "Chat History Previous",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [6] = {
        name = "Chat History Next",
        keyCombo = 'Shift+Down',
        altKeyCombo = 'Shift+Down',
        callback = "Chat History Next",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [7] = {
        name = "Chat Tab Next",
        keyCombo = 'Ctrl+Tab',
        altKeyCombo = 'Ctrl+Tab',
        callback = "Chat Tab Next",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [8] = {
        name = "Chat Tab Previous",
        keyCombo = 'Ctrl+Shift+Tab',
        altKeyCombo = 'Ctrl+Shift+Tab',
        callback = "Chat Tab Previous",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [9] = {
        name = "Chat Send Message",
        keyCombo = 'Enter',
        altKeyCombo = 'Enter',
        callback = "Chat Send Message",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [10] = {
        name = "Chat Clean All",
        keyCombo = 'Ctrl+A',
        altKeyCombo = 'CTRL+A',
        callback = "Chat Clean All",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress,
        resistsMute = true
      },
      [11] = {
        name = "Chat Mode Switch",
        keyCombo = 'Ctrl+F',
        altKeyCombo = 'Ctrl+F',
        callback = "Chat Mode Switch",
        bindFunction = g_keyboard.bindKeyDown,
        unbindFunction = g_keyboard.unbindKeyDown,
        resistsMute = true
      },
      [12] = {
        name = "Minimap Move Left",
        keyCombo = 'Alt+Left',
        altKeyCombo = 'Alt+Left',
        callback = "Minimap Move Left",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress
      },
      [13] = {
        name = "Minimap Move Right",
        keyCombo = 'Alt+Right',
        altKeyCombo = 'Alt+Right',
        callback = "Minimap Move Right",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress
      },
      [14] = {
        name = "Minimap Move Up",
        keyCombo = 'Alt+Up',
         altKeyCombo = 'Alt+Up',
         callback = "Minimap Move Up",
         bindFunction = g_keyboard.bindKeyPress,
         unbindFunction = g_keyboard.unbindKeyPress
        },
      [15] = {
        name = "Minimap Move Down",
        keyCombo = 'Alt+Down',
        altKeyCombo = 'Alt+Down',
        callback = "Minimap Move Down",
        bindFunction = g_keyboard.bindKeyPress,
        unbindFunction = g_keyboard.unbindKeyPress
      },
      [16] = {
        name = "Minimap Fullscreen",
        keyCombo = 'Ctrl+Shift+M',
        altKeyCombo = 'Ctrl+Shift+M',
        callback = "Minimap Fullscreen"
      },
      [17] = {
        name = "Toggle Info Displays",
        keyCombo = 'CTRL+N',
        altKeyCombo = 'CTRL+N',
        callback = "Toggle Info Displays"
      },
      [18] = {
        name = 'Clear Onscreen Messages',
        keyCombo = 'CTRL+W',
        altKeyCombo = 'CTRL+W',
        callback = "Clear Onscreen Messages"
      }
    }
  }
}