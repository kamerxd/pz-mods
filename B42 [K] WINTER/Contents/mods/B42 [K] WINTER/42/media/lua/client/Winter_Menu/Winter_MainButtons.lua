local Winter_UiUtils = require "Winter_Menu/Winter_UiUtils"

local Winter_MainButtons = ISPanelJoypad:derive("Winter_MainButtons")

local function Winter_onPlay(button)

    local mainMenu = button.parent.mainMenu

    mainMenu.mainButtons:setVisible(false)
    mainMenu.playButtons:setVisible(true)

end

local function Winter_onOptions(button)

    local mainMenu = button.parent.mainMenu

    mainMenu.mainButtons:setVisible(false)
    mainMenu.bottomButtons:setVisible(false)

    local mainScreen = MainScreen.instance
    local options = mainScreen.mainOptions

    if not options.winterCloseHooked then

        local vanillaClose = options.close

        options.close = function(self)

            vanillaClose(self)

            self:removeFromUIManager()
            mainScreen:addChild(self)
            self:setAlwaysOnTop(false)

            mainMenu.mainButtons:setVisible(true)
            mainMenu.bottomButtons:setVisible(true)

        end

        options.winterCloseHooked = true

    end

    options:detachFromParent()
    options:addToUIManager()

    local joypadData = JoypadState.getMainMenuJoypad()

    options:toUI()
    options:setVisible(true, joypadData)

    options:setAlwaysOnTop(true)
    options:bringToTop()

end

local function Winter_onMods(button)

    local mainMenu = button.parent.mainMenu
    local mainScreen = MainScreen.instance
    local mods = mainScreen.modSelect

    mainMenu.mainButtons:setVisible(false)
    mainMenu.bottomButtons:setVisible(false)

    mods:setNewGame()

    mods:detachFromParent()
    mods:addToUIManager()

    local joypadData = JoypadState.getMainMenuJoypad()

    mods:setVisible(true, joypadData)
    mods.model:reloadMods()

    ModSelector.showNagPanel()

    mods.returnToUI = mainMenu

    if not mods.winterAcceptHooked then

        local vanillaOnAccept = mods.onAccept

        mods.onAccept = function(self)

            vanillaOnAccept(self)

            self:removeFromUIManager()
            mainScreen:addChild(self)

            self:setAlwaysOnTop(false)

            mainMenu.mainButtons:setVisible(true)
            mainMenu.bottomButtons:setVisible(true)

        end

        mods.winterAcceptHooked = true

    end

    mods:setAlwaysOnTop(true)
    mods:bringToTop()

end

local function Winter_onQuit(button)

    if isQuitCooldown() then
        return
    end

    getCore():quitToDesktop()

end

function Winter_MainButtons:new()

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local buttonWidth = screenWidth * 0.094
    local buttonHeight = screenHeight * 0.030
    local spacing = screenHeight * 0.001

    local width = buttonWidth
    local height = buttonHeight * 4 + spacing * 3

    local x = (screenWidth - width) / 2
    local y = (screenHeight - height) / 2

    local o = ISPanelJoypad:new(
        x,
        y,
        width,
        height
    )

    setmetatable(o, self)
    self.__index = self

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

    o.buttonHeight = buttonHeight
    o.spacing = spacing
    
    return o
end


function Winter_MainButtons:createChildren()

    local buttonWidth = self:getWidth()
    local buttonHeight = self.buttonHeight
    local spacing = self.spacing

    self.playButton = Winter_UiUtils.createButton(
        self,
        0,
        0,
        buttonWidth,
        buttonHeight,
        "PLAY",
        Winter_onPlay,
        UIFont.Large
    )

    self.optionsButton = Winter_UiUtils.createButton(
        self,
        0,
        buttonHeight + spacing,
        buttonWidth,
        buttonHeight,
        "OPTIONS",
        Winter_onOptions,
        UIFont.Large
    )

    self.modsButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 2,
        buttonWidth,
        buttonHeight,
        "MODS",
        Winter_onMods,
        UIFont.Large
    )

    self.quitButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 3,
        buttonWidth,
        buttonHeight,
        "QUIT",
        Winter_onQuit,
        UIFont.Large
    )

    local modInfo = getModInfoByID("kamer_winter")
    local modVersion = "?"
    if modInfo then modVersion = modInfo:getModVersion() end

    local gameVersion = getGameVersion()
    local versionText = "Winter " .. modVersion .. " | B" .. gameVersion
    self.versionText = versionText   

    local font = UIFont.Small
    local textManager = getTextManager()

    local versionWidth =
        textManager:MeasureStringX(font, versionText)

    local versionHeight =
        textManager:MeasureStringY(font, versionText)

    local versionY =
        (buttonHeight + spacing) * 4 + 4

    self.versionLabel = ISLabel:new(
        (self:getWidth() - versionWidth) / 2,
        versionY,
        versionHeight,
        versionText,
        1,
        1,
        1,
        0.6,
        font,
        true
    )

    self.versionLabel:initialise()
    self:addChild(self.versionLabel)
end


function Winter_MainButtons:onResolutionChange(oldw, oldh, neww, newh)

    local buttonWidth = neww * 0.094
    local buttonHeight = newh * 0.030
    local spacing = newh * 0.001

    local width = buttonWidth
    local height = buttonHeight * 4 + spacing * 3

    local x = (neww - width) / 2
    local y = (newh - height) / 2

    self:setWidth(width)
    self:setHeight(height)
    self:setX(x)
    self:setY(y)

    self.playButton:setWidth(buttonWidth)
    self.playButton:setHeight(buttonHeight)
    self.playButton:setX(0)
    self.playButton:setY(0)

    self.optionsButton:setWidth(buttonWidth)
    self.optionsButton:setHeight(buttonHeight)
    self.optionsButton:setX(0)
    self.optionsButton:setY(buttonHeight + spacing)

    self.modsButton:setWidth(buttonWidth)
    self.modsButton:setHeight(buttonHeight)
    self.modsButton:setX(0)
    self.modsButton:setY((buttonHeight + spacing) * 2)

    self.quitButton:setWidth(buttonWidth)
    self.quitButton:setHeight(buttonHeight)
    self.quitButton:setX(0)
    self.quitButton:setY((buttonHeight + spacing) * 3)

    local versionWidth =
        getTextManager():MeasureStringX(
            UIFont.Small,
            self.versionText
        )

    self.versionLabel:setWidth(versionWidth)
    self.versionLabel:setX(
        (self:getWidth() - versionWidth) / 2
    )

    self.versionLabel:setY(
        (buttonHeight + spacing) * 4 + 4
    )

end


return Winter_MainButtons