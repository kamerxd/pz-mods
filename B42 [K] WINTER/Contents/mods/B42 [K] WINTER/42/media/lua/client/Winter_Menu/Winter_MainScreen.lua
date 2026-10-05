local Winter_Video = require "Winter_Menu/Winter_Video"
local Winter_MainButtons = require "Winter_Menu/Winter_MainButtons"
local Winter_BottomButtons = require "Winter_Menu/Winter_BottomButtons"
local Winter_PlayButtons = require "Winter_Menu/Winter_PlayButtons"

local Winter_MainMenu = ISPanelJoypad:derive("Winter_MainMenu")
Winter_MainMenu.Instance = nil

local function Winter_onKeyPressed(key)
    if key ~= Keyboard.KEY_ESCAPE then
        return
    end

    local menu = Winter_MainMenu.Instance

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

    Winter_MainMenu.Instance = o
    o.video = Winter_Video:new()

    return o
end

function Winter_MainMenu:createChildren()

    self.mainButtons = Winter_MainButtons:new()
    self.mainButtons:initialise()
    self:addChild(self.mainButtons)

    self.playButtons = Winter_PlayButtons:new()
    self.playButtons:initialise()
    self:addChild(self.playButtons)

    self.bottomButtons = Winter_BottomButtons:new()
    self.bottomButtons:initialise()
    self:addChild(self.bottomButtons)


    self.mainButtons.mainMenu = self
    self.playButtons.mainMenu = self

    self.playButtons:setVisible(false)

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

function Winter_MainMenu:render()

end

function Winter_MainMenu:showMainButtons()

    self.playButtons:setVisible(false)
    self.mainButtons:setVisible(true)
end

Events.OnKeyPressed.Add(Winter_onKeyPressed)


return Winter_MainMenu