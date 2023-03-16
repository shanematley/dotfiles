require('keyboard') -- Load Hammerspoon with subset of: https://github.com/jasonrudolph/keyboard

hs.loadSpoon('SendToOmniFocus')

spoon.SendToOmniFocus:registerApplication("Arc", {
    as_scriptfile = hs.spoons.resourcePath("arc-to-omnifocus.applescript"),
    itemname = "tab"
})

spoon.SendToOmniFocus:bindHotkeys({
    send_to_omnifocus = { {"shift", "ctrl", "alt", "cmd" }, "t" }
})

local originalFrame = nil

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "H", function()
  local zoomWindow = hs.window.find("zoom share statusbar window")
  if zoomWindow then
    if originalFrame then
      zoomWindow:setFrame(originalFrame)
      originalFrame = nil
    else
      originalFrame = zoomWindow:frame()
      local screen = zoomWindow:screen()
      local frame = zoomWindow:frame()
      frame.x = screen:frame().w + 3000
      frame.y = screen:frame().h + 3000
      zoomWindow:setFrame(frame)
    end
  end
end)
