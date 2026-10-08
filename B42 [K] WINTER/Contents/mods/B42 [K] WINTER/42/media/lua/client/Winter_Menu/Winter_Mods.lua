local Winter_UiUtils = require "Winter_Menu/Winter_UiUtils"
local Winter_ModList = require "Winter_Menu/Winter_ModList"
local Winter_ModInfo = require "Winter_Menu/Winter_ModInfo"

local Winter_Mods = ISPanelJoypad:derive("Winter_Mods")

local TEXT_MANAGER = getTextManager()
local UI_BORDER_SPACING = 10
local FONT_HGT_SMALL = TEXT_MANAGER:getFontHeight(UIFont.Small)
local FONT_HGT_LARGE = TEXT_MANAGER:getFontHeight(UIFont.Large)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local BUTTON_PADDING = 32 + UI_BORDER_SPACING * 2
local LIST_Y = 55

local PANEL_BACKGROUND = {r = 0.06, g = 0.08, b = 0.09, a = 0.88}
local PANEL_BORDER = {r = 0.55, g = 0.65, b = 0.70, a = 0.55}

local BACKGROUND = {r = 0.28, g = 0.05, b = 0.05, a = 0.75}
local BACK_BORDER = {r = 0.65, g = 0.18, b = 0.18, a = 0.7}
local BACK_TEXT = {r = 0.9, g = 0.75, b = 0.75, a = 1}
local BACK_HOVER = {r = 1, g = 0.85, b = 0.85, a = 1}

local TITLE_COLOR = {r = 0.82, g = 0.85, b = 0.86, a = 1}

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

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_Mods:createChildren()
    local font = UIFont.Small
    local buttonHeight = BUTTON_HGT
    local buttonWidth = BUTTON_PADDING + TEXT_MANAGER:MeasureStringX(font, "BACK")
    local listWidth = self.width / 2 - UI_BORDER_SPACING
    local listHeight = self.height - LIST_Y - UI_BORDER_SPACING * 2 - buttonHeight - 1

    self.modList = Winter_ModList:new(
        UI_BORDER_SPACING,
        LIST_Y,
        listWidth,
        listHeight
    )
    self.modList:initialise()
    self.modList:instantiate()
    self.modList:setup()
    self:addChild(self.modList)

    local infoX = self.modList:getRight() + UI_BORDER_SPACING
    local infoWidth = self.width - infoX - UI_BORDER_SPACING

    self.modInfo = Winter_ModInfo:new(
        infoX,
        LIST_Y,
        infoWidth,
        listHeight
    )
    self.modInfo:initialise()
    self.modInfo:instantiate()
    self:addChild(self.modInfo)

    if #self.modList.items > 0 then
        self.modList.selected = 1
        self.modInfo:updateView(self.modList.items[1].item.modData.modInfo)
    end

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

    self.backButton.backgroundColor = BACKGROUND
    self.backButton.borderColor = BACK_BORDER
    self.backButton.textColor = BACK_TEXT
    self.backButton.hoverColor = BACK_HOVER

    self.titleLabel = ISLabel:new(
        self.width / 2,
        12,
        FONT_HGT_LARGE,
        "SELECT MODS",
        TITLE_COLOR.r,
        TITLE_COLOR.g,
        TITLE_COLOR.b,
        TITLE_COLOR.a,
        UIFont.Large,
        true
    )
    self.titleLabel:initialise()
    self.titleLabel:setWidthToName()
    self.titleLabel:setX((self.width - self.titleLabel:getWidth()) / 2)
    self:addChild(self.titleLabel)
end

return Winter_Mods