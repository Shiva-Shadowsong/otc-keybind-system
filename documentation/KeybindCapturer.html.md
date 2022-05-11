#  KeybindCapturer

**CaptureWindow** extends `MainWindow`.

Use this widget when you need to spawn a window that will capture a key press from the user.  
The Keybind Manager grants a method which can be used for generic Keybind capturing and comes rather preconfigured to spare you the work. If you need to further customize it, or customize a Capturer from scratch, you may do that as well.

#### Example:

```lua
    local capturer = KeybindManager:createCapturer("Press a combination of keys to use as your keybind:", function(capturedKeyCombo)
      print("Captured: " .. capturedKeyCombo)
    end)

```

![Example](https://i.imgur.com/rUIqawe.png)
