-- Default keybindings for launching apps in Hyper Mode
--
-- To launch _your_ most commonly-used apps via Hyper Mode, create a copy of
-- this file, save it as `hyper-apps.lua`, and edit the table below to configure
-- your preferred shortcuts.

function toggle_zoom(toggle1, toggle2)
    return function()
        local zoom = hs.appfinder.appFromName("zoom.us")

        local str_toggle1 = {'Meeting', toggle1}
        local str_toggle2 = {'Meeting', toggle2}

        local toggle1_menu = zoom:findMenuItem(str_toggle1)
        local toggle2_menu = zoom:findMenuItem(str_toggle2)

        if (toggle1_menu) then
            zoom:selectMenuItem(str_toggle1)
        elseif (toggle2_menu) then
            zoom:selectMenuItem(str_toggle2)
        end
    end
end

function toggle_zoom_combined(toggle_off1, toggle_off2, toggle_on1, toggle_on2)
    return function()
        local zoom = hs.appfinder.appFromName("zoom.us")

        local str_toggle_off1 = {'Meeting', toggle_off1}
        local str_toggle_off2 = {'Meeting', toggle_off2}
        local str_toggle_on1 = {'Meeting', toggle_on1}
        local str_toggle_on2 = {'Meeting', toggle_on2}

        local toggle_off1_menu = zoom:findMenuItem(str_toggle_off1)
        local toggle_off2_menu = zoom:findMenuItem(str_toggle_off2)
        local toggle_on1_menu = zoom:findMenuItem(str_toggle_on1)
        local toggle_on2_menu = zoom:findMenuItem(str_toggle_on2)

        if (toggle_off1_menu and toggle_off2_menu) then
            zoom:selectMenuItem(str_toggle_off1)
            zoom:selectMenuItem(str_toggle_off2)
        elseif (toggle_on1_menu and toggle_on2_menu) then
            zoom:selectMenuItem(str_toggle_on1)
            zoom:selectMenuItem(str_toggle_on2)
        end
    end
end

return {
  { 'a', 'Music' },             -- "A" for "Apple Music"
  { 'b', 'Google Chrome' },     -- "B" for "Browser"
  { 'c', 'Slack' },             -- "C for "Chat"
  { 'd', 'Remember The Milk' }, -- "D" for "Do!" ... or "Done!"
  { 'e', 'Atom' },              -- "E" for "Editor"
  { 'f', 'Finder' },            -- "F" for "Finder"
  { 'g', 'Mailplane 3' },       -- "G" for "Gmail"
  { 'n', 'Messages' },
  { 'o', 'Omnifocus' },
  { 's', 'Slack' },             -- "S" for "Slack"
  { 't', 'iTerm' },             -- "T" for "Terminal"
  { 'z', 'Zoom.us' },              -- "Z" for "Zoom"
  { '\\', toggle_zoom('Mute Audio', 'Unmute Audio') },
  { ']', toggle_zoom_combined('Mute Audio', 'Stop Video', 'Unmute Audio', 'Start Video') },
  { '[', toggle_zoom('Stop Video', 'Start Video') },
  { '\'', toggle_zoom('Stop Share', 'Start Share') },
  { ';', toggle_zoom('Exit Minimal View', 'Enter Minimal View') },
}
