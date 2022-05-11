# Class: KeybindProfile

Creates a class `KeybindProfile`, which represents a wrapper for our currently configured [KeybindCategories](Keybind-Category), the [Keybinds](Keybind) within them, and the specific key combo settings used for those keybinds as dictated by the “profile.otml” config file’s contents of this profile.

The system of KeybindProfile naming **is case-sensitive** and expects **unique** names for KeybindProfiles. The system also creates a `name.otml` config file.

Furthermore, the _Auto Profile Switcher_ uses the names (case-insensitive) of Profiles to try and satisfy its condition if auto-switching is turned on.  

![how it works](https://i.imgur.com/BiCPTbl.png)

When KeybindManager:initialize() is called (the method which initializes the entire Keybind system and is executed while libs are loading), it will **mandate** for a `KeybindProfile` called “Default” to exist, and [protect()](#protect) it as well.

## KeybindProfile Object

### Attributes:

| Attribute | Type | Description |
| -- | -- | -- |
| name | string | The name of the Profile. Must be unique (case-sensitive).
| protected | bool | Is this profile protected from deletion? By default, only ever true on the “Default” profile.
|config|`Config`|Refers to the Config object obtained by loading the `name`.otml file of this profile.
|fullpath|string|Holds a string that directs to the location of the .otml file of this Profile relative to the writeDirectory.

### Methods:

-   [activate(firstActivation)](#activatefirstactivation)
-   [protect()](#protect)
-   [delete()](#delete)
-   [selectAsOption()](#selectasoption)
-   [injectAsOption()](#injectasoption)

**Getters**  
They just return what’s stored in that attribute. See above.

-   [getName()](#getname)
-   [getConfig()](#getconfig)
-   [getFullPath()](#getfullpath)

----------

### activate(firstActivation)

**Method:** activate(firstActivation)  
**Params:**

-   firstActivation- `bool` (optional) : Is this the first time (any) profile is being activated in the client? `True` only in KeybindManager:init() pretty much.

**Return:** `void`

**Description:**  
This method does several things with the goal of disposing of/unloading the previously used profile, and loading in the current one on which we’re calling this method. There may be data that needs to be persist between profiles, usually kept in the [Keybind Manager](Keybind-Manager).

However, this method also handles the case where we are starting completely from scratch, and not switching from another profile. This happens, for example, when we just ran the game.

Thus, it executes these actions in this order:

-   Remove all existing `KeybindCategories` from the manager. (Since they contain `Keybinds`, those `Keybinds` will be gone too).
-   Cache the info that we are now using this profile.
-   Create categories needed by this profile.
-   Create keybinds needed by this profile.
-   Update the UI responsible for showing us which profile we’re using.

While creating categories and keybinds, the following order is followed:

Check .otml for a list of Categories that this Profile requires.

Ensure that all Default categories were created.

Check .otml for a list of Keybinds  
that should go into these categories

Refer to Default keybind settings for any missing data  
which we may need to construct these keybinds,  
and ensure all of these Defaults are loaded.

**Example:**

```lua
	local prof = KeybindManager.defaultProfile
	prof:activate()

```

----------

### protect()

**Method**: protect()

**Return:** `bool`

**Description:** Sets the `protected = true` attribute on the profile, denying [delete()](#delete) from working on it.

**Example:**

```lua
	local prof = KeybindManager.currentProfile
	prof:protect()

```

----------

### delete()

**Method**: delete()

**Return:** `bool`

**Description:**  
Deletes the profile, switching to “Default” if the deleted profile was the currently active one. This removes it from the keybind manager, as well as removing the .otml config associated with this profile. Returns bool whether succesful or not.

This will fail if used on profiles which have the `protected = true` attribute.

**Example:**

```lua
	local prof = KeybindManager.currentProfile
	prof:delete()

```

----------

### selectAsOption()

**Method**: selectAsOption()

**Return:** `void`

**Description:**  
Selects this profile as the currently selected option in the `client_options` keybinds GUI, here:

![sample](https://i.imgur.com/pN9yW5p.png)

**Example:**

```lua
	local prof = KeybindManager.currentProfile
	prof:selectAsOption()

```

----------

### injectAsOption()

**Method**: injectAsOption()

**Return:** `void`

**Description:**  
Injects this profile as an available option to choose in the `client_options` keybinds GUI, here:

![sample](https://i.imgur.com/b3W14qM.png)

**Example:**

```lua
	local prof = KeybindManager.currentProfile
	prof:injectAsOption()

```
