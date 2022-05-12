require('keyboard') -- Load Hammerspoon with subset of: https://github.com/jasonrudolph/keyboard

hs.loadSpoon('SendToOmniFocus')
spoon.SendToOmniFocus:bindHotkeys({
    send_to_omnifocus = { {"shift", "ctrl", "alt", "cmd" }, "t" }
})

