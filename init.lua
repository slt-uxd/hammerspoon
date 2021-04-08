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

-- Tokens for key modifier combinations 
sc    = {"shift","cmd"}
cc    = {"ctrl","cmd"}
ac    = {"alt","cmd"}
sac   = {"shift","alt","cmd"}
cac   = {"ctrl","alt","cmd"}
scac  = {"shift","ctrl","alt","cmd"}

Install:andUse("KSheet", {
                 hotkeys = {
                   toggle = { cac , "/" }
                 }
})

-- Re-mapping keyboard shortcuts
-- This is based on Ellit Waite's init.lua file from 
-- https://github.com/elliotwaite/hammerspoon-config

-- ************************* START *****************************

-- Remapping FIGMA keyboard shortcuts
figmaHotkeys = {
-- WORKS Assign [cmd + 1] to set zoom to 100%
  hs.hotkey.new('cmd', '1', function() hs.eventtap.keyStroke('shift', '0', 0) end),
-- FAILS Assign [shift+cmd + 1] to set zoom to fit all frames
  hs.hotkey.new('cmd+shift', '1', function() hs.eventtap.keyStroke('shift', '1', 0) end),
-- FAILS Assign [ctrl + 1] to pick fill color
  hs.hotkey.new('ctrl', '1', function() hs.eventtap.keyStroke('ctrl', 'c', 0) end),
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
  -- If this script is initialized with a Brave window already in
  -- focus, enable the Brave hotkeys.
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


