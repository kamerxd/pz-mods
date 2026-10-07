local Winter_Soundplayer = require "Winter_Menu/Winter_Soundplayer"
local Winter_UiUtils = require "Winter_Menu/Winter_UiUtils"

local Winter_BottomButtons = ISPanelJoypad:derive("Winter_BottomButtons")

local function Winter_onReloadLua(button)

    Winter_Soundplayer.restartMusic()

    getCore():DelayResetLua(
        "default",
        "reloadLua"
    )

end


local function Winter_onPrivacy(button)

    local width = 600
    local height = 200

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local modal = ISTermsOfServiceUI:new(
        screenWidth / 2 - width / 2,
        screenHeight / 2 - height / 2,
        width,
        height
    )

    modal:initialise()
    modal:addToUIManager()
    modal:setAlwaysOnTop(true)

    -- Keep this disabled for now if ScreenManager
    -- is not part of the new menu yet.
    --
    -- Winter_ScreenManager.open("legal", modal)

    local player = 0

    if player and JoypadState.players[player + 1] then

        modal.prevFocus =
            JoypadState.players[player + 1].focus

        setJoypadFocus(player, modal)

    else

        local joypadData =
            JoypadState.getMainMenuJoypad()

        if joypadData then

            modal.prevFocus = joypadData.focus
            joypadData.focus = modal

            updateJoypadFocus(joypadData)

        end

    end

end


local function Winter_onClickReportBug(button)

    local url =
        "https://theindiestone.com/forums/index.php?/topic/43261-read-here-first-bug-reporting-guideformatting/"

    if isSteamOverlayEnabled() then

        activateSteamOverlayToWebPage(url)

    else

        openUrl(url)

    end

end


function Winter_BottomButtons:new()

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local buttonHeight = screenHeight * 0.018
    local spacing = screenHeight * 0.001

    local width = screenWidth * 0.10
    local height = buttonHeight * 3 + spacing * 2

    local x = 0
    local y = screenHeight - height

    local o = ISPanelJoypad:new(
        x,
        y,
        width,
        height
    )

    setmetatable(o, self)
    self.__index = self

    o.buttonHeight = buttonHeight
    o.spacing = spacing
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }

    o.borderColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }

    return o
end


function Winter_BottomButtons:createChildren()

    local buttonWidth = self:getWidth()

    local buttonHeight = self.buttonHeight
    local spacing = self.spacing


    self.reloadLuaButton = Winter_UiUtils.createButton(
        self,
        0,
        0,
        buttonWidth,
        buttonHeight,
        "RELOAD LUA",
        Winter_onReloadLua
    )

    self.reloadLuaButton.textAlignLeft = true
    self.reloadLuaButton.font = UIFont.Small
    self.reloadLuaButton.textColor = {
        r = 0.2,
        g = 0.8,
        b = 1,
        a = 1
    }


    self.privacyButton = Winter_UiUtils.createButton(
        self,
        0,
        buttonHeight + spacing,
        buttonWidth,
        buttonHeight,
        "LEGAL",
        Winter_onPrivacy
    )

    self.privacyButton.textAlignLeft = true
    self.privacyButton.font = UIFont.Small


    self.reportButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 2,
        buttonWidth,
        buttonHeight,
        "REPORT BUG",
        Winter_onClickReportBug
    )

    self.reportButton.textAlignLeft = true
    self.reportButton.font = UIFont.Small
    self.reportButton.textColor = {
        r = 1,
        g = 0.2,
        b = 0.2,
        a = 1
    }

end

function Winter_BottomButtons:onResolutionChange(oldw, oldh, neww, newh)

    local buttonHeight = newh * 0.018
    local spacing = newh * 0.001

    local width = neww * 0.10
    local height = buttonHeight * 3 + spacing * 2

    local x = 0
    local y = newh - height

    self.buttonHeight = buttonHeight
    self.spacing = spacing

    self:setWidth(width)
    self:setHeight(height)
    self:setX(x)
    self:setY(y)

    self.reloadLuaButton:setWidth(width)
    self.reloadLuaButton:setHeight(buttonHeight)
    self.reloadLuaButton:setX(0)
    self.reloadLuaButton:setY(0)

    self.privacyButton:setWidth(width)
    self.privacyButton:setHeight(buttonHeight)
    self.privacyButton:setX(0)
    self.privacyButton:setY(buttonHeight + spacing)

    self.reportButton:setWidth(width)
    self.reportButton:setHeight(buttonHeight)
    self.reportButton:setX(0)
    self.reportButton:setY((buttonHeight + spacing) * 2)

end

return Winter_BottomButtons