KeybindCategory

# Class: KeybindCategory

Creates a class KeybindCategory, which is a manageable category and wrapper for a group of `Keybind` objects, acting like a container for them.

The system is designed so that a `Keybind`'s name is an unique identifier for that keybind **within a Category**. Different categories may have a keybind with the same name.

## KeybindCategory Object

### Attributes:

| Attribute | Type | Description |
|--|--|--|
| name | string | The name of the Category. Must be unique. |
| keybinds | table | table with `Keybind` values

### Methods:

-   [create(name)](#createname)
-   [remove()](#remove)
-   [injectAsOption()](#injectasoption)

**Keybind management:**

-   [addKeybind()](#addkeybindkeybind)
-   [getKeybinds()](#getkeybinds)
-   [getKeybindByName(name)](#getkeybindbynamename)
-   [removeKeybindByName(name)](#removekeybindbynamename)

----------

### create(name)

**Method:** create(`string` name)

**Return:** `KeybindCategory`

**Description:**  
Creates an object of this class.

**Example:**

```lua
local cat = KeybindCategory:create("MyNewCategory")

```

----------

### remove()

**Method:** remove()

**Return:** void

**Description:**  
Removes all `Keybind`s from this category’s `keybinds` list, by executing `Keybind:remove()` on each of them, which makes sure that each Keybind is gracefully detached from the system and nothing messes up due to their abrupt removal, then makes the `keybinds` an empty table again.

**Example:**

```lua
local cat = KeybindManager:getCategoryByName("Turning")
cat:remove()

```

----------

### injectAsOption()

**Method:** injectAsOption()

**Return:** void

**Description:**  
If `client_options` is loaded, injects this `Category` into the UI at that module.

**Example:**

```lua
local cat = KeybindCategory:create("Movement")
KeybindManager:addCategory(cat)

cat:injectAsOption()

```

![example](https://i.imgur.com/ey8o48n.png)

----------

### getKeybinds( )

**Method:** getKeybinds()

**Return:** `table` of `Keybind` objects.

**Description:** Returns a table of all `Keybinds` that have been added to this category.

**Example:**

```lua
	local cat = KeybindManager:getCategoryByName("myCategory")
	for _, keybind in pairs(cat:getKeybinds()) do
		print("Keybind [" .. keybind.name .. "] found in this category.")
	end

```

----------

### getKeybindByName(name)

**Method:** hasKeybindByName(`string` name)

**Return:** `Keybind`or `nil`

**Description:** Checks if there is a `Keybind` whose name matches the provided `name` inside this category, and if yes, returns it.

**Example:**

```lua
	local cat = KeybindManager:getCategoryByName("myCategory")
	if cat:getKeybindByName("Walk North") then
		-- Found that keybind in this category.
	end

```

----------

### removeKeybindByName(name)

**Method:** removeKeybindByName(`string` name)

**Return:** `void`

**Description:** Checks if there is a `Keybind` whose name matches the provided `name` inside this category, and if yes, executes `Keybind:remove()` on it.

**Example:**

```lua
	local cat = KeybindManager:getCategoryByName("myCategory")
	cat:removeKeybindByName("Walk North") -- RIP in pepperoni 

```

----------

### addKeybind(Keybind)

**Method:** addKeybind(`Keybind` keybind)

**Return:** `bool`

**Description:** Adds a `Keybind` into this category’s `keybinds` table.

If possible, inserts it at the index which the `Keybind.defaultIndex` attribute suggested _(this helps with sorting default keybinds to always display in the same order in the UI)._

_Use this method as a gate for validating whether Keybinds should be added to the category if you come up with any new rules for that._

**Example:**

```lua
	local kbind = Keybind:create(params~)
	local cat = KeybindManager:getCategoryByName("myCategory")
	cat:addKeybind(kbind)

```
