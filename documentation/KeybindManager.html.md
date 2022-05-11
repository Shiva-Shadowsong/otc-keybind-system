# Class (Singleton): KeybindManager

Creates a singleton KeybindManager, who acts as an overseer and performs various operations on its subjects - Profiles, Categories and Keybinds.

Alongside managerial operations over those 3 classes, it also adds some of its own global methods to ease administration of related systems.

## Attributes:

| Attribute | Type | Description |
| -- | -- | -- |
| categories | table with `KeybindCategory` values | Stores references to all existing `KeybindCategory` objects. If you need to know which KeybindCategories are registered in the system, this table should have them all.
| profiles | table with `KeybindProfile` values | Same as above, but for `KeybindProfile` objects.
| capturer |`UIWidget` \[, nil\]| If the KeybindManager spawned any `CapturerWindow` uiwidgets using `:createCapturer`, the reference to that window will be stored in here. Only one should be allowed to exist at a time.
| config | `Config` | Stores a reference to they `Config` object spawned out of the /keybinds.otml file.
| keyComboMode | number | Using `config` to grab this number, it stores the number _KEYCOMBO\_MODE\_REGULAR (1)_ or _KEYCOMBO\_MODE\_ALT (2)_. This number indicates which **Chat Mode** we are currently running.
| autoProfileSwitching | bool | Using `config` to grab this bool, it stores info about whether we currently have the **Profile Auto Switching** option toggled on or off.
| currentProfile | `KeybindProfile` | Stores a reference to the currently used `KeybindProfile`.
| defaultProfile | `KeybindProfile` | Stores a reference to the “Default” profile.
| keybindToWidgetAssociations | `table` with structured values | Uses of `KeybindManager:setAssociationBetween(Keybind,Widget)` store a key `Keybind.categoryName` containing a table of `[Keybind.name] = {UIwidgets...}` pairs as its value(s). If we ever have to destroy and recreate `Keybinds`, this table will let us remember which Keybinds should be reassociated with which widgets. More about _associations_ in `setAssociationBetween` documentation.
| rememberedFocusBindings | `table` with structured values | Uses of `Keybind:setWidgetToBindTo(widget)` store a key `Keybind.categoryName` containing a table of `[Keybind.name] = UIWidget` pairs as its value(s). If we ever have to switch proiles, even when we destroy and recreate `Keybinds`, this table will let us remember which Keybinds (identified by their category and name) should be re-bound to which widgets, otherwise we’d have no way of knowing.
| keybindsMuted | `bool` | If true, keybinds which do not have `resistsMute = true` attr will not do anything when pressed.

## Methods:

-   [initialize()](#initialize)
-   [getKeyComboMode()](#getkeycombomode)
-   [toggleAutoProfileSwitching()](#toggleautoprofileswitching)
-   [toggleChatMode()](#togglechatmode)

**Profile Management:**

-   [createProfile(name)](#createprofilename)
-   [createDefaultProfile()](#createdefaultprofile)
-   [getProfileByName(name)](#getprofilebynamename)
-   [addProfile(profile)](#addprofileprofile)
-   [removeProfile(profile)](#removeprofileprofile)

**Categories:**

-   [getCategories()](#getcategories)
-   [hasCategoryByName(name)](#hascategorybynamename)
-   [getCategoryByName(name)](#getcategorybynamename)
-   [addCategory(category)](#addcategorycategory)

**Keybinds**

-   [getKeybindByName(name, categoryname)](#getkeybindbynamename-categoryname)
-   [resetToDefault()](#resettodefault)
-   [rememberFocusBindingFor(Keybind)](#rememberfocusbindingforkeybind)
-   [setAssociationBetween(Keybind, widget)](#setassociationbetweenkeybind-widget)

----------

### initialize()

**Method:** initialize()

**Return:** void

**Description:**  
This method does several things, with the goal of preparing the manager for a smooth boot-up:

-   Ensures that the `/profiles` folder, and `/profiles/keybinds/` aftewards, exist.
-   Creates the “Default” `KeybindProfile`.
-   Detects which profiles should exist based on the contents of the `/profiles/keybinds` folder, and creates `KeybindProfile` for each of them using their .otml file.
-   Checks which one out of those profiles should be loaded, based on cached user info in the `keybinds.otml` config, and tries to load that one. If it fails, it will go to “Default” `keybindProfile`.

**Example:**

```lua
KeybindManager = _keybindManager:create() -- Create singleton.
KeybindManager:initialize() -- Start the engines!

```

----------

### createProfile(name)

**Method**: createProfile(`string` name)

**Return:** `KeybindProfile` \[or `nil`\]

**Description:**

Copies the contents of the current profile’s .otml file, and writes them into a new file by the given `name` in the same folder. Then, uses that file as a source for creation of a new `KeybindProfile` with KeybindProfile:generate(). If the creation of the new profile is successful, returns it, otherwise nil.

**Example:**

```lua
local profile = KeybindManager:createProfile("MyNewProfile")
if profile then
	print("Hello from " .. profile.name .. "!")
end 

```

----------

### createDefaultProfile()

**Method**: createDefaultProfile()

**Return**: void

**Description**: Generate the “Default” profile and otml file. The entire system is designed around the fact that **at least** this profile must exist. The profile can not be deleted except by manual intervention of the user and altering of the files, but even in that case, the system should be able to handle its re-creation (see: [initialize()](#initialize)).

**Example**

```lua
	KeybindManager:createDefaultProfile() -- Creates it and stores it in its own `defaultProfile` attribute.
	
	print(KeybindManager.defaultProfile.name) -- "Default"

```

----------

### getProfileByName(name)

**Method**: getProfileByName(`string` name)

**Return**: `KeybindProfile` or `nil`

**Description**: Iterates through the manager’s own `profiles` table in search of a registered profile by `name`. If found, returns it, if not returns nil.

**Example**

```lua
	local p = KeybindManager:getProfileByName("Default")
	if p then 
		print(p.name) -- "Default"
	end

```

----------

### addProfile(profile)

**Method**: addProfile(`KeybindProfile` profile)

**Return**: `bool`

**Description**: Attempts to register a `KeybindProfile` into the manager’s `profiles` attribute. Only registered profiles are considered valid for use. We can perform validation in this method and avoid registering profiles which fail to pass it. Upon successful registration, it tries to add the profile into the “Profiles” menu in _client_options_ and returns true, else false.

**Example**

```lua
	local prof = KeybindManager:createProfile("RandomNewProf")
	if prof then
		if KeybindManager:registerProfile(prof) then 
			-- Profile registered successfully.
		end
	end

```

----------

### removeProfile(profile)

**Method**: removeProfile(`KeybindProfile` profile)

**Return**: `nil`

**Description**: Attempts to find the provided `KeybindProfile` in the manager’s `profiles` registrar, and if found, it will be removed from there. Usually only used internally during the profile’s total deletion.

**Example**

```lua
	KeybindManager:removeProfile("MyProfile")

```

----------

### getCategories()

**Method**: getCategories()

**Return**: `table` of `KeybindCategory` values.

**Description**: Retrieves the table of registered categories that’s stored in the manager’s `categories` attribute.

**Example**

```lua
	local categories = KeybindManager:getCategories()
	for _, cat in pairs(categories) do
		print("We have a category called " ..cat.name.. ".")
	end

```

----------

### hasCategoryByName(name)

**Method**: hasCategoryByName(`string` name)

**Return**: `bool`

**Description**: Checks where a `KeybindCategory`with a given `name` can be found in the list of registered `categories`.

**Example**

```lua
	if KeybindManager:hasCategoryByName("Movement") then
		print("Category [Movement] exists.")
	end

```

----------

### getCategoryByName(name)

**Method**: getCategoryByName(`string` name)

**Return**: `KeybindCategory` or `nil`

**Description**: Attempts to find the `KeybindCategory` with the provided `name` in the manager’s `categories` registrar, and if found, returns it, otherwise returns `nil`.

**Example**

```lua
	local cat = KeybindManager:getCategoryByName("MyCategory")
	if cat then
		print(cat.name) -- "MyCategory"
	end

```

----------

### addCategory(category)

**Method**: addCategory(`KeybindCategory` category)

**Return**: `void`

**Description**: Attempts to register a `KeybindCategory` into the manager’s `categories` attribute. Only registered categories are considered valid for use. We can perform validation in this method and avoid registering profiles which fail to pass it.

**Example**

```lua
	KeybindManager:addCategory("Necronia Mod")

```

----------

### getKeybindByName(name, categoryName)

**Method**: getKeybindByName(`string` name, `string` categoryName)

**Return**: `Keybind` or `nil`

**Description**: Attempts to find a `Keybind` by name, in a registered category of provided `categoryName`, and returns it if found.

**Example**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	if kb then 
		-- We got the Keybind.
	end 

```

----------

### getKeyComboMode(), getChatMode()

**Method**: getKeyComboMode(), getChatMode()

**Return**: `number`

**Description**: Returns a number representing which chat mode we’re using. `KEYCOMBO_MODE_REGULAR (1)` or `KEYCOMBO_MODE_ALT (2)`, unless something went horribly wrong.

**Example**

```lua
	local mode = KeybindManager:getKeyComboMode()
	if mode == KEYCOMBO_MODE_REGULAR then 
		-- We are using the "Classic" chat mode.
	else
		-- We are using the "Modern" chat mode.
	end

```

----------

### resetToDefaults()

**Method**: resetToDefaults()

**Return**: `void`

**Description**: Resets **ALL** keybind settings in the currently active profile to their known default combos.

**Example**

```lua
	KeybindManager:resetToDefaults()

```

----------

### toggleAutoProfileSwitching()

**Method**: toggleAutoProfileSwitching()

**Return**: `void`

**Description**: Toggles whether “Profile Auto Switch” will be enabled or not and saves the result into the user local cached settings.

![About Profile Auto Switcher](https://i.imgur.com/ArtdYnJ.png)

**Example**

```lua
	KeybindManager:toggleAutoProfileSwitching()

```

----------

### toggleChatMode()

**Method**: toggleChatMode()

**Return**: `void`

**Description**: Toggles whether “Classic” chat mode will be enabled or not and saves the result into the user local cached settings. Doing this triggers `Keybind:updateWidgets()` on all `Keybind`s and automatically flicks the switch in `client_options`.

_What are Chat modes?_  
![About Chat Modes](https://i.imgur.com/aN3q3AM.png)

**Example**

```lua
	KeybindManager:toggleChatMode()

```

----------

### setAssociationBetween(keybind, widget)

**Method:** setAssociationBetween( `object` Keybind, `object` UIWidget)

**Return:** void

**Description:** Tells the manager to remember that `Keybind` (identified by its name and category) is being tracked by `UIWidget`. `UIWidget` may receive updates to its labels if our `Keybind` changes, etc.

This is useful to remember, because when we are switching Keybind profiles, we are effectively destroying all old Keybinds and data we knew about them. If we want the new set of Keybinds to remember some of their old connections to widgets and so on, we store them here and reconnect them after they’re recreated.

In order for this to work, the `UIWidget` **must** implement 2 children, with the IDs: `keyCombo` and `altKeyCombo`. These two children will have modifications done to them if the `Keybind` changes.

**Example:**

```lua
	local myKeybind = Keybind:create(params~)
	local gameHotkey2 = rootWidget:recursiveGetChildById('gameHotkey2')
	 
	KeybindManager:setAssociationBetween(myKeybind, gameHotkey2) -- Now, for example, if myKeybind changes from being bound to `Ctrl+W` to `Shift+W`, gameHotkey2's label will instantly update and show the correct new hotkey.

```

----------

### rememberFocusBindingFor(Keybind)

**Method:** rememberFocusBindingFor( `object` Keybind)

**Return:** void

**Description:** Tells the manager to remember that `Keybind` (identified by its name and category) should be bound to the `UIWidget` stored in the `Keybind.bindToWidget` attribute of that Keybind.

_What this means is: When that Keybind is bound using `:bind`, the key combination will only trigger its callback if `Keybind.bindToWidget` is focused. (e.g. Maybe you want to bind ‘Arrow Up’ to move a scrollbar a bit up, but only if the window with that scrollbar is focused, not in any other case)._

This is useful to remember, because when we are switching Keybind profiles, we are effectively destroying all old Keybinds and data we knew about them. If we want the new set of Keybinds to remember some of their old connections to widgets and so on, we store them here and reconnect them after they’re recreated.

**Example:**

```lua
	local myKeybind = Keybind:create(params~) 
	myKeybind:setWidgetToBindTo(widget) -- Calls KeybindManager:rememberFocusBindingFor(myKeybind).

```

----------
