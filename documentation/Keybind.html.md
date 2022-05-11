Keybind

# Class: Keybind

Creates a class Keybind, which produces objects that coordinate which key on the keyboard activates which function, and how the changes related to those keybinds propagate to other widgets.

## KeybindCategory Object

### Attributes:

| Attribute | Type | Description |
| -- | -- | -- |
| name | string | The name of the Keybind. Will be exepected to be unique within its parent category. Case-sensitive.
| category | string | Name of the category into which we want to insert this Keybind.
| keyCombo | string | Holds the key combination associated with this keybind. By default, it is “<none>”, a hardcoded string value which signifies to the system that this keybind isn’t using any key combo.
| altKeyCombo | string | Same as above, the only difference being - keyCombo is used in `Classic Chat` mode and altKeyCombo is used in `Modern Chat` mode.
| callback | function | Contains a function which the keybind, when activated, will call when its key combo is pressed.
| callbackName | string | Contains a string that corresponds to a key from the KB_CALLBACKS global table, letting us know which keybind callback we want this keybind to use for this key in case this Keybind can not resolve its `callback` attribute as a function. This may happen if the Keybind had to be destroyed and is being recreated under different circumstances where the parent module which initially provided a callback for it would _require a reload_ in order to do so again.
| args | `...` | VarArg to be provided to the `callback`.
| active | bool | Lets us know whether this keybind is currently activated or not. Whether a keybind is active or not, broadly lets us know if it is currently bound to the keyboard and is being used by the user.
| bindFunction | function | Tells the keybind which function to use to bind the key combo(s) during [bind()](#bind). There are different ways to bind a key, including but not limited to `g_keyboard.bindKeyDown`, `g_keyboard.bindKeyUp`, `g_keyboard.bindKeyPress`, all of which exhibit different behavior.
| unbindFunction | function | Tells the keybind which function to use to unbind the key combo(s) during [unbind()](#unbind).
| bindToWidget | `UIWidget` or `nil` | During [bind()](#bind), this key combo will be bound only to work while the provided `UIWidget` is focused. If left as nil, the default value is `gameRootPanel`.
| defaultKeyCombo | string | A fallback key combo which is applied to this keybind in case the user requests to reset it to default values, or in other similar cases.
| defaultAltKeyCombo | string | Same as above, just for the altKeyCombo.
| defaultIndex | number | When this keybind is being inserted into some table, we can use this number to tell the table to preferrably insert the Keybind into its index of the same number. (e.g. we want to specify that “Walk North” should always be first in a list of Walk keys.)
| forbiddenWithModifiers | bool | Default: false. If set to true, this keybind will refuse to [update()](#update) if one of its keyCombos contain keyboard modifiers (Shift, Ctrl, Alt).
| resistsMute | bool | Default: false. When the keybind manager is muted, unless this attribute is set to true, this keybind won’t do anything.

### Methods:

-   [create (defaultIndex, category, name, keyCombo, altKeyCombo, callback, …)](#createdefaultindex-category-name-keycombo-altkeycombo-callback)
-   [validate (keyCombo, altKeyCombo)](#validatekeycombo-altkeycombo)
-   [activate (\[mode\])](#activatemode)
-   [deactivate (\[mode\])](#deactivatemode)
-   [update (regularKey, altKey)](#updateregularkey-altkey)
-   [reset (\[mode\])](#resetmode)
-   [clear (\[mode\])](#clearmode)
-   [remove (decache)](#removedecache)
-   [cache()](#cache)
-   [decache()](#decache)
-   [bind(\[mode\])](#bindmode)
-   [unbind(\[mode\])](#unbindmode)
-   [updateWidgets (\[removed\])](#updatewidgetsremoved)
-   [getDefaultKeycombo (mode)](#getdefaultkeycombo)
-   [setDefaultKeycombo (keyCombo, altKeyCombo)](#setdefaultkeycombokeycombo-altkeycombo)
-   [setBindMechanisms(bindFunfction, unbindFunction)](#setbindmechanismsbindfunction-unbindfunction)
-   [setWidgetToBindTo(widget)](#setwidgettobindtowidget)
-   [setForbiddenWithModifiers(state)](#setforbiddenwithmodifiersstate)
-   [setMuteResistance(state)](#setmuteresistancestate)
-   [injectAsOption()](#injectasoption)

----------

----------

### create(defaultIndex, category, name, keyCombo, altKeyCombo, callback, …)

**Params:**

-   defaultIndex - `number` : When we are sorting this `Keybind` into some table, if it’s an ordered table, this Keybind would prefer to be indexed at this position in the table. Default: 1 _(Tables which are sorting this should be implemented to automatically make space if the preferred defaultIndex can not be filled)._ Can not be lower than 1.
-   category - `string` : Name of the `KeybindCategory` which will be using this Keybind.
-   name - `string` : Name of this keybind.
-   keyCombo - `string` : Which combination of keys should activate this keybind in Classic chat mode.
-   altKeyCombo - `string` : Which combination of keys should actviate this keybind in Modern chat mode.
-   callback - `function`OR `string` : A function which should run when this keyCombo is active and pressed. If provided with a string, it will try to resolve it to a function by looking up what _KB_CALLBACKS\[thatString\]_ equals to.
-   `...` \- `VarArg` : Additional arguments to be passed to the `callback`.

**Return:** this `Keybind` object.

**Description:** Creates a `Keybind` object using the provided data. Once it is created, if everything went well, it is returned and you may use additional configuration methods on it before you [activate()](#activatemode) it. Run activate once that’s done.

**Example:**

```lua
	local kb = Keybind:create(1,  "Movement",  "Walk North",  "Up",  "W",  "Walk Up")
	if kb then 
		print("Keybind created.")
	end

```

----------

### validate(keyCombo, altKeyCombo)

**Params:**

-   keyCombo - `string` : Which keyCombo string should we validate
-   altKeyCombo - `string` : Which altKeyCombostring should we validate

**Return:** bool

**Description:** Checks if a keyCombo and altKeyCombo are valid combos that can be used for this keybind. Additionally, if it finds them on any other existing keycombo, it resets that other keycombo to (overwrites it).

**Example:**

```lua
	local kb = Keybind:create(1,  "Movement",  "Walk North",  "Up",  "W",  "Walk Up")
	kb:validate(kb.keyCombo, kb.altKeyCombo)

```

----------

### activate(mode)

**Params:**

-   mode - `number` (optional) : You can specify which key from the Keybind to activate and use (e.g. To use only keyCombo - pass `KEYBIND_MODE_REGULAR` here). If left as `nil`, it defaults to activating the mode which is currently used (as remembered by _KeybindManager.keyComboMode_).

**Return:** void

**Description:** Marks this Keybind as active, [Binds](#bindmode) the specified keyCombo to the keyboard. Meant to be used as a public way to bind, while the actual [bind()](#bindmode) method is an internal way to specifically do only that and nothing else.

**Example:**

```lua
	local kb = Keybind:create(1,  "Movement",  "Walk North",  "Up",  "W",  "Walk Up")
	kb:activate()

```

----------

### deactivate(mode)

**Params:**

-   mode - `number` (optional) : You can specify which key from the Keybind to deactivate and stop using _(e.g. To stop oly keyCombo - pass `KEYBIND_MODE_REGULAR` here)_. If left as `nil`, it defaults to deactivating the mode which is currently used (as remembered by _KeybindManager.keyComboMode_.

**Return:** void

**Description:** Marks this Keybind as active, [Binds](#bindmode) the specified keyCombo to the keyboard. Meant to be used as a public way to bind, while the actual [bind()](#bindmode) method is an internal way to specifically do only that and nothing else.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:deactivate()

```

----------

### update(regularKey, altKey)

**Params:**

-   regularKey - `string`: New keyCombo to use for this keybind.
-   altKey - `string` : New altKeyCombo to use for this keybind.

**Return:** bool

**Description:** Swaps the currently known keyCombo and altKeyCombo for whatever you provide here. If the settings fail to [validate (keyCombo, altKeyCombo)](#validatekeycombo-altkeycombo), it will return false. If the new combo(s) which were provided in here are the same as **any** key combo used in the entire keybind system -> that other one will be set to “” so that this keybind can use the provided combos. Basically, the other one(s) will be overwritten.

The string `\<none\>` represents, in the system, a keybind which is not assigned to any key. Use that string to update a keybind to essentially be useless with that specific key.

If you want one of the keys to keep using whatever is already set up for that combo, just pass that combo again and it will be detected and ignored.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:update("W", kb.altKeyCombo) -- Keep using the same altKeyCombo, but update the keyCombo to 'W'.

```

----------

### reset(mode)

**Params:**

-   mode - `number` : Specifies which key out of the two to reset back to its default setting.

**Return:** void

**Description:** Resets a keybind’s specified keycombo to its default setting.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:reset(CHAT_MODE_MODERN)

```

----------

### clear(mode)

**Params:**

-   mode - `number` (optional) : Specifies which key out of the two to clear out.

**Return:** void

**Description:** Sets a keybind’s specified keycombo to `\<none\>`. If not specified by the optional parameter, it will do it to both of them.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:clear(CHAT_MODE_MODERN)

```

----------

### remove(decache)

**Params:**

-   decache - `bool` (optional) : If set to true, remove will also run [decache()](#decachesave) on the keybind after removing it.

**Return:** void

**Description:**  
Unbinds the keybind, tells all of its associated widgets that it is removed and to update accordingly, and, if specified, also removes it from the cache of the currently loaded `KeybindProfile`'s config.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:remove(CHAT_MODE_MODERN)

```

----------

### decache(save)

**Params:**

-   save- `bool` (optional) : If set to true, after the key is decached, the change will instantly be saved in the cache config file.

**Return:** void

**Description:**  
Decaches the key from the current `KeybindProfile`'s settings.

The reason why this the `save` param is optional is because there are some operations (e.g. _Remove all keybinds_) where it is more efficient to just remove them all via a loop, and then run :save() on the cache once, instead of having this method doing it after every successful single keybind decaching.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:decache()

```

----------

### bind(mode)

**Params:**

-   mode - `number` (optional) : Specifies which key out of the two to bind to keyboard.

**Return:** void

**Description:**  
Using this keybind’s `bindFunction` attribute, binds the specified keyCombo to this keybind’s `callback`, which will also be passed this keybind’s `args`. If the mode parameter is not specified, it will do it for both keyCombo and altKeyCombo.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:bind()

```

----------

### unbind(mode)

**Params:**

-   mode - `number` (optional) : Specifies which key out of the two to unbind from the keyboard.

**Return:** void

**Description:**  
Using this keybind’s `unbindFunction` attribute, unbinds the specified keyCombo from this keybind’s `callback`. If the mode parameter is not specified, it will do it for both keyCombo and altKeyCombo.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:unbind()

```

----------

### updateWidgets(removed)

**Params:**

-   removed - `bool` (optional) : Specifies whether this key is in the process of being removed.

**Return:** void

**Description:**  
Changes the color and text on every associated widget’s “keyCombo” and “altKeyCombo” ID’d child to match the `keyCombo` and `altKeyCombo` of this Keybind. If this Keybind is in the process of being removed, it will set the text “??” instead. This is meant only for internal use by other methods of this object, like [update()](#updateregularkeyaltkey). Meant for internal use only.

**Example:**

```lua
	None

```

----------

### getDefaultKeycombo(mode)

**Params:**

-   mode - `number` : For which keybind mode?

**Return:** string

**Description:**  
Returns a string containing the keyCombo which this Keybind should use as a default fallback. Keep in mind that if this is not an explicitly defined combo using [setDefaultKeycombo](#setdefaultkeycombokeycombo-altkeycombo), it will return “<none>”.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	local def = kb:getDefaultKeycombo(KEYCOMBO_MODE_REGULAR)
    print("Default is: " .. def) -- prints ("Up").

```

----------

### setDefaultKeyCombo(keyCombo, altKeyCombo)

**Params:**

-   keyCombo - `string` : Which default do you want for the keyCombo?
-   altKeyCombo - `string` : Which default do you want for the altKeyCombo?

**Return:** void

**Description:**  
Configures what the default keycombo and altkeycombo fallback string for this Keybind should be.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	local def = kb:getDefaultKeycombo(KEYCOMBO_MODE_REGULAR)
    print("Default is: " .. def) -- prints ("Up").

```

----------

### setBindMechanisms(bindFunction, unbindFunction)

**Params:**

-   bindFunction- `function` : Function which will be used to bind this keybind’s keycombo to the keyboard.
-   unbindFunction- `function` : Function which will be used to bind this keybind’s altkeycombo to the keyboard.

**Return:** void

**Description:**  
Defines which functions should be used to bind/unbind this key’s keycombo to the keyboard. If never altered, `g_keyboard.bindKeyDown` will be the default. Some other options include `g_keyboard.bindKeyUp` or `g_keyboard.bindKeyPress`. You can also define a custom function. This custom function will receive 3 parameters: `keyCombo`, `callback`, and `bindToWidget` attribs of this Keybind.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:setBindMechanisms(g_keyboard.bindKeyUp, g_keyboard.unbindKeyUp)

```

----------

### setBindMechanisms(bindFunction, unbindFunction)

**Params:**

-   bindFunction- `function` : Function which will be used to bind this keybind’s keycombo to the keyboard.
-   unbindFunction- `function` : Function which will be used to bind this keybind’s altkeycombo to the keyboard.

**Return:** void

**Description:**  
Defines which functions should be used to bind/unbind this key’s keycombo to the keyboard. If never altered, `g_keyboard.bindKeyDown` will be the default. Some other options include `g_keyboard.bindKeyUp` or `g_keyboard.bindKeyPress`. You can also define a custom function. This custom function will receive 3 parameters: `keyCombo`, `callback`, and `bindToWidget` attribs of this Keybind.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:setBindMechanisms(g_keyboard.bindKeyUp, g_keyboard.unbindKeyUp)

```

----------

### setForbiddenWithModifiers(state)

**Params:**

-   state- `bool`

**Return:** void

**Description:**  
Set whether this Keybind should be forbidden from having keybinds that contain `Shift`, `Alt` or `Ctrl`.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:setForbiddenWithModifiers(true)

```

----------

### setMuteResistance(state)

**Params:**

-   state- `bool`

**Return:** void

**Description:**  
Set whether this Keybind will resist the Keybind Manager being muted. If so, it will execute even in that case, otherwise not (default).

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Chat Send Message", "Interface")
	kb:setMuteResistance(true)

```

----------

### injectAsOption()

**Return:** void

**Description:**  
Injects this Keybind as a node in the `client_options` UI if that module is loaded.

![Sample](https://i.imgur.com/BxhTJds.png)

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:injectAsOption()

```

----------

### setWidgetToBindTo(widget)

**Params:** `UIWidget` : Widget which this keybind should bind its actions to.

**Return:** void

**Description:**  
Lets the KeybindManager know that the provided `widget` should be the one that needs to be focused in order for this Keybind to work when it is bound. By default, it is `gameRootPanel`.

**Example:**

```lua
	local kb = KeybindManager:getKeybindByName("Walk North", "Movement")
	kb:setWidgetToBindTo(gameMapPanel)

```
