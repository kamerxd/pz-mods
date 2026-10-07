local Winter_Video = require "Winter_Menu/Winter_Video"
local Winter_MainButtons = require "Winter_Menu/Winter_MainButtons"
local Winter_BottomButtons = require "Winter_Menu/Winter_BottomButtons"
local Winter_PlayButtons = require "Winter_Menu/Winter_PlayButtons"
local Winter_Mods = require "Winter_Menu/Winter_Mods"

local Winter_MainMenu = ISPanelJoypad:derive("Winter_MainMenu")
Winter_MainMenu.instance = nil

local function Winter_onKeyPressed(key)
    if key ~= Keyboard.KEY_ESCAPE then
        return
    end

    local menu = Winter_MainMenu.instance

    if not menu then
        return
    end

    if menu.playButtons and menu.playButtons:isVisible() then
        menu:showMainButtons()
    end

end

function Winter_MainMenu:new()

    local width = getCore():getScreenWidth()
    local height = getCore():getScreenHeight()

    local o = ISPanelJoypad:new(
        0,
        0,
        width,
        height
    )

    setmetatable(o, self)
    self.__index = self

    Winter_MainMenu.instance = o
    o.video = Winter_Video:new()

    return o
end

function Winter_MainMenu:createChildren()

    self.mainButtons = Winter_MainButtons:new()
    self.mainButtons:initialise()
    self:addChild(self.mainButtons)
    self.mainButtons.mainMenu = self

    self.playButtons = Winter_PlayButtons:new()
    self.playButtons:initialise()
    self:addChild(self.playButtons)
    self.playButtons.mainMenu = self
    self.playButtons:setVisible(false)

    self.bottomButtons = Winter_BottomButtons:new()
    self.bottomButtons:initialise()
    self:addChild(self.bottomButtons)

    self.mods = Winter_Mods:new()
    self.mods:initialise()
    self:addChild(self.mods)
    self.mods.mainMenu = self
    self.mods:setVisible(false)

end

function Winter_MainMenu:prerender()

    self.video:prerender()

    self.video:render(
        self,
        self:getWidth(),
        self:getHeight()
    )

    local eight_shades_of_grey = 0.20

    self:drawRect(
        0,
        0,
        self:getWidth(),
        self:getHeight(),
        eight_shades_of_grey,
        0,
        0,
        0
    )

    local barHeight = self:getHeight() * 0.10

    -- Top bar
    self:drawRect(
        0,
        0,
        self:getWidth(),
        barHeight,
        1,
        0,
        0,
        0
    )

    -- Bottom bar
    self:drawRect(
        0,
        self:getHeight() - barHeight,
        self:getWidth(),
        barHeight,
        1,
        0,
        0,
        0
    )

end

-- function Winter_MainMenu:render()

-- end

function Winter_MainMenu:showMainButtons()

    self.playButtons:setVisible(false)
    self.mainButtons:setVisible(true)
end

local function Winter_onResolutionChange(oldw, oldh, neww, newh)

    local menu = Winter_MainMenu.instance

    if not menu then
        return
    end

    menu:setWidth(neww)
    menu:setHeight(newh)
    menu:setX(0)
    menu:setY(0)

    if menu.mainButtons then
        menu.mainButtons:onResolutionChange(oldw, oldh, neww, newh)
    end

    if menu.playButtons then
        menu.playButtons:onResolutionChange(oldw, oldh, neww, newh)
    end

    if menu.bottomButtons then
        menu.bottomButtons:onResolutionChange(oldw, oldh, neww, newh)
    end

end

Events.OnResolutionChange.Add(Winter_onResolutionChange)
Events.OnKeyPressed.Add(Winter_onKeyPressed)

return Winter_MainMenu