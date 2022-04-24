-- Load the package-manager, if installed
hs.loadSpoon("SpoonInstall")

--------------------------------
-- START VIM CONFIG
--------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- vim
vim
  :disableForApp('Code')
  :disableForApp('zoom.us')
  :disableForApp('iTerm')
  :disableForApp('iTerm2')
  :disableForApp('Terminal')

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vim:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
vim:enterWithSequence('jk')

-- if you want to bind a single key to entering vim, remove the
-- :enterWithSequence('jk') line above and uncomment the bindHotKeys line
-- below:
--
-- To customize the hot key you want, see the mods and key parameters at:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind
--
-- vim:bindHotKeys({ enter = { {'ctrl'}, ';' } })

--------------------------------
-- END VIM CONFIG
--------------------------------

--=========================
-- Personal configuration
--=========================

-- Bind Cmd+Ctlr+Alt+M to maximize the front-most application window
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

-- Bind Cmd+Ctlr+Alt+G to toggle Greyscale setting of the Display
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "G", function()
    ToggleGreyscale()
end)

-- This function invokes the Greyscale-toggling workhorse application
function ToggleGreyscale()
    hs.application.launchOrFocus("/Users/gurjeet/dev/ToggleGrayscale(automator-app).app")
end

----------------------------------------
-- WiFi management for personal laptop
----------------------------------------

-- Remember the SSID we're connected to
current_ssid = hs.wifi.currentNetwork()

-- Attempt connection to a specific SSID
function ConnectToWiFi(name)
    -- Get the current SSID name
    current_ssid = hs.wifi.currentNetwork()

    if (current_ssid ~= name)
    then
        print("Trying to connect to ", name)
        -- 2nd param, the password, is required, but can be empty
        hs.wifi.associate(name, " ")
    else
        print("Already connected to ", name)
    end
end

-- Watch for changes in WiFi configuration/SSID
watcher = hs.wifi.watcher.new(function()
    -- This function is called everytime the SSID changes

    print("WiFi watcher's anonymous function() called")
    current_ssid = hs.wifi.currentNetwork()

    -- Repopulate our custom-menu, to enable the 'check' mark next to the
    -- current SSID's name.
    populate_custom_menu()
end)
watcher:start(); -- Start the watcher

function is_current_ssid(name)
    return name == current_ssid
end

----------------------------
-- Create a personal Menu
----------------------------
custom_menu = hs.menubar.new():setTitle("Q"):setTooltip("Configure in ~/init.lua")
function populate_custom_menu()
    print("populate_custom_menu() called.")
    custom_menu:setMenu({
        { title = "JoMarzi"  , fn = function() ConnectToWiFi("JoMarzi")     end, checked = is_current_ssid("JoMarzi")    },
        { title = "xfinity"  , fn = function() ConnectToWiFi("xfinitywifi") end, checked = is_current_ssid("xfinitywifi")},
        { title = "-" }, -- Separator
        { title = "Greyscale"  , fn = ToggleGreyscale },
        { title = "-" }, -- Separator
        { title = "Configure in ~/init.lua", disabled = true },
    })
end
populate_custom_menu()

