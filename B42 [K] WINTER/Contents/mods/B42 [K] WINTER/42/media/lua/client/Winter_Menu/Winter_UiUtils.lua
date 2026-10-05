local Winter_UiUtils = {}
local Winter_TextButton = ISPanelJoypad:derive("Winter_TextButton")

function Winter_TextButton:new(x, y, width, height, text, callback, font)
    local o = ISPanelJoypad:new(
        x,
        y,
        width,
        height
    )

    setmetatable(o, self)
    self.__index = self

    o.text = text
    o.callback = callback

    o.font = font or UIFont.Medium

    o.textColor = {
        r = 0.75,
        g = 0.75,
        b = 0.75,
        a = 1
    }

    o.hoverColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1
    }

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

    o.sounds = {
        activate = "UIActivateButton"
    }

    return o
end

function Winter_TextButton:render()

    local textManager = getTextManager()

    local textWidth = textManager:MeasureStringX(
        self.font,
        self.text
    )

    local textHeight = textManager:MeasureStringY(
        self.font,
        self.text
    )

    local x

    if self.textAlignLeft then
        x = 0
    else
        x = (self:getWidth() - textWidth) / 2
    end

    local y = (self:getHeight() - textHeight) / 2

    local hovered = self:isMouseOver()

    local color = hovered
        and self.hoverColor
        or self.textColor

    local outline = 1

    for ox = -outline, outline do
        for oy = -outline, outline do

            if ox ~= 0 or oy ~= 0 then

                self:drawText(
                    self.text,
                    x + ox,
                    y + oy,
                    0,
                    0,
                    0,
                    1,
                    self.font
                )

            end
        end
    end

    self:drawText(
        self.text,
        x,
        y,
        color.r,
        color.g,
        color.b,
        color.a,
        self.font
    )

end

function Winter_TextButton:onMouseUp(x, y)

    if self.callback then

        getSoundManager():playUISound(
            self.sounds.activate
        )

        self.callback(self)

    end

    return true
end

function Winter_UiUtils.createButton(
    parent,
    x,
    y,
    width,
    height,
    text,
    callback,
    font
)

    local button = Winter_TextButton:new(
        x,
        y,
        width,
        height,
        text,
        callback,
        font
    )

    button:initialise()
    button:instantiate()

    parent:addChild(button)

    return button
end

return Winter_UiUtils