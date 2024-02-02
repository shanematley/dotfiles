-- Default keybindings for launching apps in Hyper Mode
--
-- To launch _your_ most commonly-used apps via Hyper Mode, create a copy of
-- this file, save it as `hyper-apps.lua`, and edit the table below to configure
-- your preferred shortcuts.

-- Set to debug or info. Can change this in Hammerspoon console by running: hyper_debug_logs_enable or hyper_debug_logs_disable
local hyper_log = hs.logger.new('hyper','info')

function hyper_debug_logs_enable()
    hyper_log.setLogLevel('debug')
end

function hyper_debug_logs_disable()
    hyper_log.setLogLevel('info')
end

function find_menu(zoom, menu_paths)
    hyper_log.df("Looking for menu item in the following menu paths %s", hs.inspect(menu_paths));
    for _, menu_path in ipairs(menu_paths) do
        local m = zoom:findMenuItem(menu_path)
        if m then
            hyper_log.d('Found menu item ' .. hs.inspect(menu_path));
            -- Append path to the existing enabled and ticked entries
            m.path = menu_path
            return m
        end
    end
    hyper_log.df("Didn't find any menu items from menu paths provided: %s", hs.inspect(menu_paths));
    return nil
end

function toggle_zoom(toggle1, toggle2)
    return function()
        local zoom = hs.appfinder.appFromName("zoom.us")
        if (not zoom) then
            hyper_log.e('Failed to find zoom.us');
            return
        end

        local toggle1_menu = find_menu(zoom, toggle1)
        local toggle2_menu = find_menu(zoom, toggle2)

        if (toggle1_menu) then
            hyper_log.df('Selecting menu item %s', hs.inspect(toggle1_menu.path));
            zoom:selectMenuItem(toggle1_menu.path)
        elseif (toggle2_menu) then
            hyper_log.df('Selecting menu item %s', hs.inspect(toggle2_menu.path));
            zoom:selectMenuItem(toggle2_menu.path)
        end
    end
end

function toggle_zoom_combined(toggle_off1, toggle_off2, toggle_on1, toggle_on2)
    return function()
        local zoom = hs.appfinder.appFromName("zoom.us")
        if (not zoom) then
            hyper_log.e('Failed to find zoom.us');
            return
        end

        local toggle_off1_menu = find_menu(zoom, toggle_off1)
        local toggle_off2_menu = find_menu(zoom, toggle_off2)
        local toggle_on1_menu = find_menu(zoom, toggle_on1)
        local toggle_on2_menu = find_menu(zoom, toggle_on2)

        if (toggle_off1_menu and toggle_off2_menu) then
            hyper_log.df('Selecting menu items %s and %s', hs.inspect(toggle_off1_menu.path), hs.inspect(toggle_off2_menu.path));
            zoom:selectMenuItem(toggle_off1_menu.path)
            zoom:selectMenuItem(toggle_off2_menu.path)
        elseif (toggle_on1_menu and toggle_on2_menu) then
            hyper_log.df('Selecting menu items %s and %s', hs.inspect(toggle_on1_menu.path), hs.inspect(toggle_on2_menu.path));
            zoom:selectMenuItem(toggle_on1_menu.path)
            zoom:selectMenuItem(toggle_on2_menu.path)
        end
    end
end

-- modifier_key: e.g. {"cmd"} alternatively use nil to not affect modifiers. Modifiers
--   include: "fn", "ctrl", "alt", "cmd", "shift"
-- key: e.g. "v"
function make_send_key_to_application(app_name, modifier_key, key)
    return function()
        local found_app = hs.appfinder.appFromName(app_name)
        if not found_app then
            hyper_log.ef('Failed to find %s', app_name);
            return
        end

        hyper_log.df('Sending key stroke %s-%s to %s', hs.inspect(modifier_key), key, app_name);
        hs.eventtap.keyStroke(modifier_key, key, nil, found_app)
    end
end

local zoom_mute =               {{'Meeting', 'Mute Audio'},   {'Meeting', 'Mute audio'}}
local zoom_unmute =             {{'Meeting', 'Unmute Audio'}, {'Meeting', 'Unmute audio'}}
local zoom_stop_video =         {{'Meeting', 'Stop Video'}}
local zoom_start_video =        {{'Meeting', 'Start Video'}}
local zoom_stop_share =         {{'Meeting', 'Stop Share'}}
local zoom_start_share =        {{'Meeting', 'Start Share'}}
local zoom_exit_minimal_view =  {{'Meeting', 'Exit Minimal View'}, {'Meeting', 'Exit minimal view'}}
local zoom_enter_minimal_view = {{'Meeting', 'Enter Minimal View'}, {'Meeting', 'Enter minimal view'}}

hyper_log.i('hyper loaded. Call `hyper_debug_logs_enable` in console to view debug logging.')

return {
  { '`', 'Alacritty' },
  { 'a', 'Music' },             -- "A" for "Apple Music"
  { 'b', 'Arc' },               -- "B" for "Browser"
  { 'f', 'Finder' },            -- "F" for "Finder"
  { 'n', 'Notes' },
  { 'o', 'Omnifocus' },
  { 'r', 'Reminders' },
  { 'p', make_send_key_to_application('zoom.us', {'alt'}, 'y') },
  { 'v', 'Messages' },
  { '4', 'Banktivity' },
  { '\\', toggle_zoom(zoom_mute, zoom_unmute) },
  { ']',  toggle_zoom_combined(zoom_mute, zoom_stop_video, zoom_unmute, zoom_start_video) },
  { '[',  toggle_zoom(zoom_stop_video, zoom_start_video) },
  { '\'', toggle_zoom(zoom_stop_share, zoom_start_share) },
  { ';',  toggle_zoom(zoom_exit_minimal_view,zoom_enter_minimal_view) },
}
