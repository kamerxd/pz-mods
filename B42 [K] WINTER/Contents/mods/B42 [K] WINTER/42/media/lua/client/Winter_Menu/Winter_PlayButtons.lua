local Winter_UiUtils = require "Winter_Menu/Winter_UiUtils"

local Winter_PlayButtons = ISPanelJoypad:derive("Winter_PlayButtons")

local function Winter_onBack(button)

    local mainMenu = button.parent.mainMenu

    mainMenu:showMainButtons()

end

function Winter_PlayButtons:new()

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local buttonWidth = screenWidth * 0.094
    local buttonHeight = screenHeight * 0.030
    local spacing = screenHeight * 0.001

    local width = buttonWidth
    local height = buttonHeight * 5 + spacing * 4

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


function Winter_PlayButtons:createChildren()

    local buttonWidth = self:getWidth()
    local buttonHeight = self.buttonHeight
    local spacing = self.spacing

    self.continueButton = Winter_UiUtils.createButton(
        self,
        0,
        0,
        buttonWidth,
        buttonHeight,
        "CONTINUE",
        function()
            print("WINTER: CONTINUE")
        end
    )

    self.newGameButton = Winter_UiUtils.createButton(
        self,
        0,
        buttonHeight + spacing,
        buttonWidth,
        buttonHeight,
        "NEW GAME",
        Winter_onNewGame,
        UIFont.Large
    )

    self.loadGameButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 2,
        buttonWidth,
        buttonHeight,
        "LOAD GAME",
        function()
            print("WINTER: LOAD GAME")
        end
    )

    self.multiplayerButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 3,
        buttonWidth,
        buttonHeight,
        "MULTIPLAYER",
        function()
            print("WINTER: MULTIPLAYER")
        end
    )

    self.backButton = Winter_UiUtils.createButton(
        self,
        0,
        (buttonHeight + spacing) * 4,
        buttonWidth,
        buttonHeight,
        "BACK",
        Winter_onBack,
        UIFont.Large
    )


    self.continueButton.font = UIFont.Large
    self.loadGameButton.font = UIFont.Large
    self.multiplayerButton.font = UIFont.Large
end


function Winter_PlayButtons:onResolutionChange(oldw, oldh, neww, newh)

    local buttonWidth = neww * 0.094
    local buttonHeight = newh * 0.030
    local spacing = newh * 0.001

    local width = buttonWidth
    local height = buttonHeight * 5 + spacing * 4

    local x = (neww - width) / 2
    local y = (newh - height) / 2

    self:setWidth(width)
    self:setHeight(height)
    self:setX(x)
    self:setY(y)

    self.continueButton:setWidth(buttonWidth)
    self.continueButton:setHeight(buttonHeight)
    self.continueButton:setX(0)
    self.continueButton:setY(0)

    self.newGameButton:setWidth(buttonWidth)
    self.newGameButton:setHeight(buttonHeight)
    self.newGameButton:setX(0)
    self.newGameButton:setY(buttonHeight + spacing)

    self.loadGameButton:setWidth(buttonWidth)
    self.loadGameButton:setHeight(buttonHeight)
    self.loadGameButton:setX(0)
    self.loadGameButton:setY((buttonHeight + spacing) * 2)

    self.multiplayerButton:setWidth(buttonWidth)
    self.multiplayerButton:setHeight(buttonHeight)
    self.multiplayerButton:setX(0)
    self.multiplayerButton:setY((buttonHeight + spacing) * 3)

    self.backButton:setWidth(buttonWidth)
    self.backButton:setHeight(buttonHeight)
    self.backButton:setX(0)
    self.backButton:setY((buttonHeight + spacing) * 4)

end


return Winter_PlayButtons