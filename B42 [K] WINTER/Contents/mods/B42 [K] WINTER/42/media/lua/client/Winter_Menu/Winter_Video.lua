local Winter_Video = {}

function Winter_Video:new()

    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.texture = VideoTexture.getOrCreate(
        "../../../../workshop/content/108600/winter.bik",
        1920,
        1080
    )

    return o
end

function Winter_Video:prerender()

    if self.texture and self.texture:isValid() then
        self.texture:RenderFrame()
    end

end

function Winter_Video:render(parent, width, height)

    if self.texture and self.texture:isValid() then

        parent:drawTextureScaled(
            self.texture,
            0,
            0,
            width,
            height,
            1
        )

    end

end

return Winter_Video