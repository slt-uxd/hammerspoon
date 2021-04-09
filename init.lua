-- SLT HammerSpoon Test Init File


-- Spoon installer from www.zzamboni.org, to use the KSheet spoon
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.repos.zzspoons = {
  url = "https://github.com/zzamboni/zzSpoons",
  desc = "zzamboni's spoon repository",
}
spoon.SpoonInstall.use_syncinstall = true
Install=spoon.SpoonInstall

-- KSheet Spoon: Press ctrl+alt+cmd+/ to displays list of hotkeys for active app
Install:andUse("KSheet", {
                 hotkeys = {
                   toggle = { {"ctrl","alt","cmd"} , "/" }
                 }
})

-- Re-mapping keyboard shortcuts
-- This is based on Elliot Waite's init.lua file from 
-- https://github.com/elliotwaite/hammerspoon-config

-- ************************* START *****************************

-- These constants are used in the code below to allow hotkeys to be
-- assigned using side-specific modifier keys.
ORDERED_KEY_CODES = {58, 61, 55, 54, 59, 62, 56, 60}
KEY_CODE_TO_KEY_STR = {
  [58] = 'leftAlt',
  [61] = 'rightAlt',
  [55] = 'leftCmd',
  [54] = 'rightCmd',
  [59] = 'leftCtrl',
  [62] = 'rightCtrl',
  [56] = 'leftShift',
  [60] = 'rightShift',
}
KEY_CODE_TO_MOD_TYPE = {
  [58] = 'alt',
  [61] = 'alt',
  [55] = 'cmd',
  [54] = 'cmd',
  [59] = 'ctrl',
  [62] = 'ctrl',
  [56] = 'shift',
  [60] = 'shift',
}
KEY_CODE_TO_SIBLING_KEY_CODE = {
  [58] = 61,
  [61] = 58,
  [55] = 54,
  [54] = 55,
  [59] = 62,
  [62] = 59,
  [56] = 60,
  [60] = 56,
}

-- SIDE_SPECIFIC_HOTKEYS:
--     This table is used to setup my side-specific hotkeys, the format
--     of each entry is: {fromMods, fromKey, toMods, toKey}
--
--      Note: If you are trying to map from one key to that same key
--      with a different modifier (e.g. rightCmd+a -> ctrl+a), this
--      method won't work, but you can use the workaround mentioned
--      here: https://github.com/elliotwaite/hammerspoon-config/issues/1
--
--     fromMods (string):
--         Any of the following strings, joined by plus signs ('+'). If
--         multiple are used, they must be listed in the same order as
--         they appear in this list (alphabetical by modifier name, and
--         then left before right):
--             leftAlt
--             rightAlt
--             leftCmd
--             rightCmd
--             leftCtrl
--             rightCtrl
--             leftShift
--             rightSfhit
--
--     fromKey (string):
--         Any single-character string, or the name of a keyboard key.
--         The list keyboard key names can be found here:
--         https://www.hammerspoon.org/docs/hs.keycodes.html#map
--
--     toMods (string):
--         Any of the following strings, joined by plus signs ('+').
--         Unlike `fromMods`, the order of these does not matter:
--             alt
--             cmd
--             ctrl
--             shift
--             fn
--
--     toKey (string):
--         Same format as `fromKey`.
--
SIDE_SPECIFIC_HOTKEYS = {
-- Empty for now
}

hotkeyGroups = {}
for _, hotkeyVals in ipairs(SIDE_SPECIFIC_HOTKEYS) do
  local fromMods, fromKey, toMods, toKey = table.unpack(hotkeyVals)
  local toKeyStroke = function()
    hs.eventtap.keyStroke(toMods, toKey, 0)
  end
  local hotkey = hs.hotkey.new(fromMods, fromKey, toKeyStroke, nil, toKeyStroke)
  if hotkeyGroups[fromMods] == nil then
    hotkeyGroups[fromMods] = {}
  end
  table.insert(hotkeyGroups[fromMods], hotkey)
end

function updateEnabledHotkeys()
  if curHotkeyGroup ~= nil then
    for _, hotkey in ipairs(curHotkeyGroup) do
      hotkey:disable()
    end
  end

  local curModKeysStr = ''
  for _, keyCode in ipairs(ORDERED_KEY_CODES) do
    if modStates[keyCode] then
      if curModKeysStr ~= '' then
        curModKeysStr = curModKeysStr .. '+'
      end
      curModKeysStr = curModKeysStr .. KEY_CODE_TO_KEY_STR[keyCode]
    end
  end

  curHotkeyGroup = hotkeyGroups[curModKeysStr]
  if curHotkeyGroup ~= nil then
    for _, hotkey in ipairs(curHotkeyGroup) do
      hotkey:enable()
    end
  end
end

modStates = {}
for _, keyCode in ipairs(ORDERED_KEY_CODES) do
  modStates[keyCode] = false
end

modKeyWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
  local keyCode = event:getKeyCode()
  if modStates[keyCode] ~= nil then
    if event:getFlags()[KEY_CODE_TO_MOD_TYPE[keyCode]] then
      -- If a mod key of this type is currently pressed, we can't
      -- determine if this event was a key-up or key-down event, so we
      -- just toggle the `modState` value corresponding to the event's
      -- key code.
      modStates[keyCode] = not modStates[keyCode]
    else
      -- If no mod keys of this type are pressed, we know that this was
      -- a key-up event, so we set the `modState` value corresponding to
      -- this key code to false. We also set the `modState` value
      -- corresponding to its sibling key code (e.g. the sibling of left
      -- shift is right shift) to false to ensure that the state for
      -- that key is correct as well. This code makes the `modState`
      -- self correcting. If it ever gets in an incorrect state, which
      -- could happend if some other code triggers multiple key-down
      -- events for a single modifier key, the state will self correct
      -- once all modifier keys of that type are released.
      modStates[keyCode] = false
      modStates[KEY_CODE_TO_SIBLING_KEY_CODE[keyCode]] = false
    end
    updateEnabledHotkeys()
  end
end):start()


-- Remapping FIGMA keyboard shortcuts

figmaHotkeys = {

-- Assign [cmd + `] to zoom to selection
  hs.hotkey.new('leftCmd', '`', function() hs.eventtap.keyStroke('shift', '2', 0) end),

-- Assign [cmd + 1] to zoom to 100%
  hs.hotkey.new('leftCmd', '1', function() hs.eventtap.keyStroke('shift', '0', 0) end),

-- Assign [cmd + 2] to zoom out
  hs.hotkey.new('leftCmd', '2', function() hs.eventtap.keyStroke(nil, '-', 0) end),

-- Assign [cmd + 3] to zoom in
  hs.hotkey.new('leftCmd', '3', function() hs.eventtap.keyStroke(nil, '=', 0) end),

-- Assign [shift+cmd + ]] to zoom to next frame
  hs.hotkey.new('leftCmd+leftShift', ']', function() hs.eventtap.keyStroke(nil, 'n', 0) end),

-- Assign [shift+cmd + ]] to zoom to previous frame
  hs.hotkey.new('leftCmd+leftShift', '[', function() hs.eventtap.keyStroke('shift', 'n', 0) end),

-- Assign [cmd + 4] to align v center
  hs.hotkey.new('leftCmd', '4', function() hs.eventtap.keyStroke('alt', 'v', 0) end),

-- Assign [alt+cmd + l] to open library panel
  hs.hotkey.new('leftAlt+leftCmd', 'l', function() hs.eventtap.keyStroke('alt+cmd', 'o', 0) end),

-- Assign [alt+cmd + d] to detach instance
  hs.hotkey.new('leftAlt+leftCmd', 'd', function() hs.eventtap.keyStroke('alt+cmd', 'b', 0) end),

-- Assign [capslock] to toggle locking *** NOT WORKING ***
  hs.hotkey.new(nil, 'capslock', function() hs.eventtap.keyStroke('shift+cmd', 'l', 0) end),

}

function enableFigmaHotkeys()
  for _, hotkey in ipairs(figmaHotkeys) do
    hotkey:enable()
  end
end

function disableFigmaHotkeys()
  for _, hotkey in ipairs(figmaHotkeys) do
    hotkey:disable()
  end
end

figmaWindowFilter = hs.window.filter.new('Figma')
figmaWindowFilter:subscribe(hs.window.filter.windowFocused, enableFigmaHotkeys)
figmaWindowFilter:subscribe(hs.window.filter.windowUnfocused, disableFigmaHotkeys)

if hs.window.focusedWindow() and hs.window.focusedWindow():application():name() == 'Figma' then
  -- If this script is initialized with a Figma window already in
  -- focus, enable the Figma hotkeys.
  enableFigmaHotkeys()
end

-- ************************* END *****************************

-- Note: the below caused an error; unable to load spoon (relating to function 'xpcall')
-- This code automatically realoads this hammer configutation file
-- whenever a file in the ~/.hammerspoon directory is changed, and shows
-- the alert, "Config reloaded," whenever it does. I enable this code
-- while debugging.
-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()
-- hs.alert.show('Config reloaded')


