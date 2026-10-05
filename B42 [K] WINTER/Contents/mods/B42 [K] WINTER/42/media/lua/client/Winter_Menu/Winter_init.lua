local Winter_MainMenu = require "Winter_Menu/Winter_MainScreen"
local Winter_Soundplayer = require "Winter_Menu/Winter_Soundplayer"

local function Winter_MainMenu_Init()

    local menu = Winter_MainMenu:new()
    menu:initialise()
    menu:addToUIManager()

    menu:setAlwaysOnTop(true)
    menu:bringToTop()

    local SoundManager = getSoundManager()
    SoundManager:setMusicState("Loading")
    Winter_Soundplayer.init()
end

Events.OnMainMenuEnter.Add(Winter_MainMenu_Init)