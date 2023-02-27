require('keyboard') -- Load Hammerspoon with subset of: https://github.com/jasonrudolph/keyboard

hs.loadSpoon('SendToOmniFocus')

spoon.SendToOmniFocus:registerApplication("Arc", {
    as_scriptfile = hs.spoons.resourcePath("arc-to-omnifocus.applescript"),
    itemname = "tab"
})

spoon.SendToOmniFocus:bindHotkeys({
    send_to_omnifocus = { {"shift", "ctrl", "alt", "cmd" }, "t" }
})

