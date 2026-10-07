local Winter_UiUtils = require "Winter_Menu/Winter_UiUtils"
local Winter_ModList = require "Winter_Menu/Winter_ModList"

local Winter_Mods = ISPanelJoypad:derive("Winter_Mods")

local UI_BORDER_SPACING = 10
local BUTTON_PADDING = 32 + UI_BORDER_SPACING * 2

local function Winter_onBack(button)
    local mainMenu = button.parent.mainMenu
    mainMenu.mods:setVisible(false)
    mainMenu.mainButtons:setVisible(true)
    mainMenu.bottomButtons:setVisible(true)
end

function Winter_Mods:new()
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    local width = screenWidth * 0.75
    local height = screenHeight * 0.75
    local x = (screenWidth - width) / 2
    local y = (screenHeight - height) / 2
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = {r = 0.06, g = 0.08, b = 0.09, a = 0.88}
    o.borderColor = {r = 0.55, g = 0.65, b = 0.70, a = 0.55}

    return o
end

function Winter_Mods:createChildren()
    local textManager = getTextManager()
    local font = UIFont.Small
    local buttonHeight = textManager:getFontHeight(font) + 6
    local buttonWidth = BUTTON_PADDING + textManager:MeasureStringX(font, "BACK")
    local listY = 55
    local listWidth = self.width / 2 - UI_BORDER_SPACING
    local listHeight = self.height - listY - UI_BORDER_SPACING * 2 - buttonHeight - 1

    self.modList = Winter_ModList:new(UI_BORDER_SPACING, listY, listWidth, listHeight)
    self.modList:initialise()
    self.modList:instantiate()
    self.modList:setup()
    self:addChild(self.modList)

    self.backButton = Winter_UiUtils.createButton(
        self,
        UI_BORDER_SPACING,
        self.height - buttonHeight - UI_BORDER_SPACING,
        buttonWidth,
        buttonHeight,
        "BACK",
        Winter_onBack,
        font
    )

    self.backButton.backgroundColor = {r = 0.28, g = 0.05, b = 0.05, a = 0.75}
    self.backButton.borderColor = {r = 0.65, g = 0.18, b = 0.18, a = 0.7}
    self.backButton.textColor = {r = 0.9, g = 0.75, b = 0.75, a = 1}
    self.backButton.hoverColor = {r = 1, g = 0.85, b = 0.85, a = 1}

    self.titleLabel = ISLabel:new(
        self.width / 2,
        12,
        textManager:getFontHeight(UIFont.Large),
        "SELECT MODS",
        0.82,
        0.85,
        0.86,
        1,
        UIFont.Large,
        true
    )

    self.titleLabel:initialise()
    self.titleLabel:setWidthToName()
    self.titleLabel:setX((self.width - self.titleLabel:getWidth()) / 2)
    self:addChild(self.titleLabel)
end

return Winter_Mods
