# Keybind System
I suggest reading through this QuickStart to get a general idea, then reading documentation of other classes in this order found in the `/documentation` folder:

* [Keybind](/documentation/Keybind.html.md)
* KeybindCategory
* KeybindProfile
* KeybindManager
* KeybindCapturer

# Defaults Configuration
First we should configure the initial setup for the keybind system:
In `/core/constants/keybinds`:

* Set KB_PROFILES_PATH to a desired location. This is where different profiles will be saved.
* KB_CATEGORY_LOAD_ORDER defines the order in which the categories will appear in the Options UI.
* KB_CALLBACKS defines all custom callbacks we intend to allow the keybinds to call. Callbacks are anonymous function filled with whatever functionality you want to be available for keybinding.
* KB_DEFAULTS defines default categories and the keybinds that will come inside of them, and what they do.

# Usage
Find the keybind you wanna use in some script.
Example, we wanna use the `Show Necronia Store` keybind function we've configured in the `Modules` category:

```lua
local keybind = KeybindManager:getKeybindByName("Show Necronia Store", "Modules")
```

Then use:

```lua
  keybind:deactivate()
  -- and
  keybind:activate()
```

To make it active or not. Usually, you will activate the keybind when the module is loaded in `init()`, and deactivate it in `terminate()` if the module is about to perish.

Of course, you will need to make the interface for editing profiles and keybinds available to players in the Options UI or some other module. For this purpose, I can provide my own example, but you will need to adapt it to your own interface, UIWidgets, etc.

⚠️⚠️⚠️:

The method `Keybind:injectAsOption()` is supposed to inject the UI widget interface for editing that Keybind into some other UI Widget container as a child. You will see that the code for this method is specifically crafted around my own interface. You should adapt it to fit yours.

# Dependencies

### Keyboard.lua
It has been edited for optimizations and adaptations to the new keybind system.

### Options.lua

The Keybinds system of course depends a lot on the Options window where the user should set their own preferences, manage profiles, keybinds and more.
Variables and functions used for this are all found in Options.lua, and I suggest you CTRL+F “keybind” in there to browse various references to it to get a grasp on what’s happening there. I added my entire `options.lua` for browsing, so make sure to have a look and make an appropriate port of these features to your client.

Also included are `options.otui` and `keybinds.otui`, which are UI stylings for the Options Window and the Keybinds panel that should appear inside of it.

### CapturerWindow

### KeybindCapturer

Functions for constructing a keybind capturer out of a style are in the KeybindManager. You will need the base style class for this capturer, found in `resources/00-keybind_capturer.otui`.

### NecroniaStyleContainer

There are multiple references to the `NecroniaStyleContainer` in the UI styles. This is just a custom `ScrollablePanel` found in `resources/02-necronia_style_container.otui` if you want to use it.

# References

### Console

Console is one of the existing modules that has a lot of custom keybinds bound in it.
Modules like this one require their own overrides of possibly existing keybinds (e.g. Arrow Up) for their own custom functionalities when they are focused.
It is possible to do this with the Keybind system of course, just by using it normally and ensuring the focus on the special module defines whether its Keybinds will `:activate()` or `:deactivate()`.

I provided my own `Console.lua` as a reference.

Similarly, Terminal is another one.
