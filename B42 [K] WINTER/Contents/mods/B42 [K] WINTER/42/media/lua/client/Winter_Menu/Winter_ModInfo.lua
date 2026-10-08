local Winter_ModInfo = ISPanelJoypad:derive("Winter_ModInfo")

local UI_BORDER_SPACING = 10
local TITLE_HEIGHT = 40
local DESC_HEIGHT = 160
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local POSTER_SIZE = 220

local PANEL_BACKGROUND = {r = 0.035, g = 0.05, b = 0.055, a = 0.75}
local PANEL_BORDER = {r = 0.35, g = 0.43, b = 0.46, a = 0.7}
local TEXT_COLOR = {r = 0.82, g = 0.85, b = 0.86, a = 1}

local Winter_ModInfoTitle = ISPanelJoypad:derive("Winter_ModInfoTitle")
local Winter_ModInfoDesc = ISPanelJoypad:derive("Winter_ModInfoDesc")
local Winter_ModInfoThumbnail = ISPanelJoypad:derive("Winter_ModInfoThumbnail")
local Winter_ModInfoStatus = ISPanelJoypad:derive("Winter_ModInfoStatus")
local Winter_ModInfoStatusValue = ISPanelJoypad:derive("Winter_ModInfoStatusValue")
local Winter_ModInfoVersion = ISPanelJoypad:derive("Winter_ModInfoVersion")
local Winter_ModInfoVersionValue = ISPanelJoypad:derive("Winter_ModInfoVersionValue")
local Winter_ModInfoAuthor = ISPanelJoypad:derive("Winter_ModInfoAuthor")
local Winter_ModInfoAuthorValue = ISPanelJoypad:derive("Winter_ModInfoAuthorValue")
local Winter_ModInfoModID = ISPanelJoypad:derive("Winter_ModInfoModID")
local Winter_ModInfoModIDValue = ISPanelJoypad:derive("Winter_ModInfoModIDValue")
local Winter_ModInfoWorkshopID = ISPanelJoypad:derive("Winter_ModInfoWorkshopID")
local Winter_ModInfoWorkshopIDValue = ISPanelJoypad:derive("Winter_ModInfoWorkshopIDValue")
local Winter_ModInfoLastUpdate = ISPanelJoypad:derive("Winter_ModInfoLastUpdate")
local Winter_ModInfoLastUpdateValue = ISPanelJoypad:derive("Winter_ModInfoLastUpdateValue")
local Winter_ModInfoGameVersion = ISPanelJoypad:derive("Winter_ModInfoGameVersion")
local Winter_ModInfoGameVersionValue = ISPanelJoypad:derive("Winter_ModInfoGameVersionValue")

function Winter_ModInfoTitle:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.title = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoTitle:setModInfo(modInfo)
    self.title = modInfo and (getTextOrNull(modInfo:getName()) or modInfo:getName()) or ""
end

function Winter_ModInfoTitle:prerender()
    ISPanelJoypad.prerender(self)

    if self.title == "" then
        return
    end

    self:drawTextCentre(
        self.title,
        self.width / 2,
        5,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Large
    )
end

function Winter_ModInfoThumbnail:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.poster = nil
    o.backgroundColor = {r = 0.035, g = 0.05, b = 0.055, a = 0.0}
    o.borderColor = {r = 0.35, g = 0.43, b = 0.46, a = 0.0}

    return o
end

function Winter_ModInfoThumbnail:setModInfo(modInfo)
    self.poster = nil

    if not modInfo then
        return
    end

    local poster = modInfo:getPoster(0)

    if poster and poster ~= "" then
        self.poster = getTexture(poster)
    end
end

function Winter_ModInfoThumbnail:prerender()
    ISPanelJoypad.prerender(self)

    if not self.poster then
        return
    end

    local size = math.min(self.width, self.height) - UI_BORDER_SPACING * 2
    local x = self.width - size - UI_BORDER_SPACING
    local y = (self.height - size) / 2

    self:drawTextureScaledAspect(
        self.poster,
        x,
        y,
        size,
        size,
        1,
        1,
        1,
        1
    )
end

function Winter_ModInfoDesc:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.description = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoDesc:setModInfo(modInfo)
    self.description = modInfo and modInfo:getDescription() or ""
end

function Winter_ModInfoDesc:prerender()
    ISPanelJoypad.prerender(self)

    if self.description == "" then
        return
    end

    local textManager = getTextManager()
    local font = UIFont.Small
    local lineHeight = textManager:getFontFromEnum(font):getLineHeight()
    local maxWidth = self.width - POSTER_SIZE - UI_BORDER_SPACING * 3
    local words = {}
    local line = ""
    local y = UI_BORDER_SPACING

    for word in string.gmatch(self.description, "%S+") do
        words[#words + 1] = word
    end

    for i = 1, #words do
        local testLine = line == "" and words[i] or line .. " " .. words[i]

        if textManager:MeasureStringX(font, testLine) > maxWidth and line ~= "" then
            self:drawText(
                line,
                UI_BORDER_SPACING,
                y,
                TEXT_COLOR.r,
                TEXT_COLOR.g,
                TEXT_COLOR.b,
                TEXT_COLOR.a,
                font
            )

            y = y + lineHeight
            line = words[i]
        else
            line = testLine
        end
    end

    if line ~= "" then
        self:drawText(
            line,
            UI_BORDER_SPACING,
            y,
            TEXT_COLOR.r,
            TEXT_COLOR.g,
            TEXT_COLOR.b,
            TEXT_COLOR.a,
            font
        )
    end
end

function Winter_ModInfoStatus:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoStatus:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Status",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoStatusValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.status = ""
    o.isActive = false
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoStatusValue:setStatus(isActive)
    self.isActive = isActive
    self.status = isActive and "Enabled" or "Disabled"
end

function Winter_ModInfoStatusValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.status == "" then
        return
    end

    local color = self.isActive
        and {r = 1.0, g = 0.82, b = 0.35, a = 1}
        or {r = 0.65, g = 0.18, b = 0.18, a = 1}

    self:drawText(
        self.status,
        UI_BORDER_SPACING,
        2,
        color.r,
        color.g,
        color.b,
        color.a,
        UIFont.Small
    )
end

function Winter_ModInfoVersion:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoVersion:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Version",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoVersionValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.version = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoVersionValue:setModInfo(modInfo)
    self.version = modInfo and modInfo:getModVersion() or ""
end

function Winter_ModInfoVersionValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.version == "" then
        return
    end

    self:drawText(
        self.version,
        UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoAuthor:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoAuthor:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Author",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoAuthorValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.author = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoAuthorValue:setModInfo(modInfo)
    self.author = modInfo and modInfo:getAuthor() or ""
end

function Winter_ModInfoAuthorValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.author == "" then
        return
    end

    self:drawText(
        self.author,
        UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoModID:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoModID:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Mod ID",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoModIDValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.modID = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoModIDValue:setModInfo(modInfo)
    self.modID = modInfo and "\\" .. modInfo:getId() or ""
end

function Winter_ModInfoModIDValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.modID == "" then
        return
    end

    self:drawText(
        self.modID,
        UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoWorkshopID:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoWorkshopID:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Workshop ID",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoWorkshopIDValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.workshopID = ""
    o.displayWorkshopID = ""
    o.workshopIDLen = 0
    o.pressed = false
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoWorkshopIDValue:setModInfo(modInfo)
    self.workshopID = ""
    self.displayWorkshopID = ""
    self.workshopIDLen = 0

    if not modInfo then
        return
    end

    self.workshopID = modInfo:getWorkshopID() or ""
    self.displayWorkshopID = self.workshopID

    if self.workshopID == "" then
        return
    end

    local availableWidth = self.width - UI_BORDER_SPACING * 2
    local textManager = getTextManager()

    if textManager:MeasureStringX(UIFont.Small, self.displayWorkshopID) > availableWidth then
        local dotWidth = textManager:MeasureStringX(UIFont.Small, "...")

        while self.displayWorkshopID ~= "" and textManager:MeasureStringX(UIFont.Small, self.displayWorkshopID) > availableWidth - dotWidth do
            self.displayWorkshopID = string.sub(self.displayWorkshopID, 1, #self.displayWorkshopID - 1)
        end

        self.displayWorkshopID = self.displayWorkshopID .. "..."
    end

    self.workshopIDLen = textManager:MeasureStringX(UIFont.Small, self.displayWorkshopID)
end

function Winter_ModInfoWorkshopIDValue:onMouseDown(x, y)
    self.pressed = true
end

function Winter_ModInfoWorkshopIDValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.displayWorkshopID == "" then
        self.pressed = false
        return
    end

    local textX = UI_BORDER_SPACING
    local textY = 2
    local isMouseOverText =
        self:isMouseOver()
        and self:getMouseX() > textX
        and self:getMouseX() < textX + self.workshopIDLen
        and self:getMouseY() > textY
        and self:getMouseY() < textY + FONT_HGT_SMALL + 1

    self:drawText(
        self.displayWorkshopID,
        textX,
        textY,
        0.2,
        0.6,
        1.0,
        1,
        UIFont.Small
    )

    if not isMouseOverText then
        self:drawRectBorder(
            textX,
            1 + FONT_HGT_SMALL,
            self.workshopIDLen,
            1,
            0.9,
            0.2,
            0.6,
            1.0
        )
    elseif self.pressed then
        activateSteamOverlayToWorkshopItem(self.workshopID)
    end

    self.pressed = false
end

function Winter_ModInfoLastUpdate:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoLastUpdate:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Last Update",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoLastUpdateValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.formattedDate = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoLastUpdateValue:formatDate(seconds)
    if not seconds or seconds == 0 then
        return ""
    end

    local millis = seconds * 1000.0
    local nowMillis = getTimestampMs()

    local sdfComponents = SimpleDateFormat.new("d M yyyy H m")
    local dateStr = sdfComponents:format(millis)

    local values = {}

    for v in string.gmatch(dateStr, "%S+") do
        values[#values + 1] = tonumber(v)
    end

    local day = values[1]
    local month = values[2]
    local year = values[3]
    local hour = values[4]
    local min = values[5]

    local sdfCompare = SimpleDateFormat.new("yyyyMMdd")
    local dateKey = sdfCompare:format(millis)
    local nowKey = sdfCompare:format(nowMillis)
    local yesterdayKey = sdfCompare:format(nowMillis - 86400000.0)

    local timeFormat

    if dateKey == nowKey then
        timeFormat = getText("UI_modinfopanel_TimeFormat_Today")
    elseif dateKey == yesterdayKey then
        timeFormat = getText("UI_modinfopanel_TimeFormat_Yesterday")
    elseif year == tonumber(os.date("%Y")) then
        timeFormat = getText("UI_modinfopanel_TimeFormat_ThisYear")
    else
        timeFormat = getText("UI_modinfopanel_TimeFormat_OtherYears")
    end

    local monthStr = getText("UI_modinfopanel_Month_Short_" .. month)

    local h12, ampm = hour, ""

    if h12 >= 12 then
        ampm = getText("UI_modinfopanel_PM")

        if h12 > 12 then
            h12 = h12 - 12
        end
    else
        ampm = getText("UI_modinfopanel_AM")

        if h12 == 0 then
            h12 = 12
        end
    end

    local res = timeFormat
    res = res:gsub("{day}", tostring(day))
    res = res:gsub("{month}", tostring(monthStr))
    res = res:gsub("{year}", tostring(year))
    res = res:gsub("{hour24}", string.format("%02d", hour))
    res = res:gsub("{hour12}", tostring(h12))
    res = res:gsub("{min}", string.format("%02d", min))
    res = res:gsub("{ampm}", tostring(ampm))

    return res
end

function Winter_ModInfoLastUpdateValue:setModData(modData)
    self.formattedDate = ""

    if not modData then
        return
    end

    self.formattedDate = self:formatDate(modData.timeUpdated)
end

function Winter_ModInfoLastUpdateValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.formattedDate == "" then
        return
    end

    self:drawText(
        self.formattedDate,
        UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoGameVersion:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoGameVersion:prerender()
    ISPanelJoypad.prerender(self)

    self:drawTextRight(
        "Game Version",
        self.width - UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfoGameVersionValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.gameVersion = ""
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER

    return o
end

function Winter_ModInfoGameVersionValue:setModInfo(modInfo)
    self.gameVersion = ""

    if not modInfo then
        return
    end

    local versionMin = modInfo:getVersionMin()
    local versionMax = modInfo:getVersionMax()

    self.gameVersion =
        (versionMin and versionMin:toString() or "**") ..
        " - " ..
        (versionMax and versionMax:toString() or "**")
end

function Winter_ModInfoGameVersionValue:prerender()
    ISPanelJoypad.prerender(self)

    if self.gameVersion == "" then
        return
    end

    self:drawText(
        self.gameVersion,
        UI_BORDER_SPACING,
        2,
        TEXT_COLOR.r,
        TEXT_COLOR.g,
        TEXT_COLOR.b,
        TEXT_COLOR.a,
        UIFont.Small
    )
end

function Winter_ModInfo:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = {r = 0.035, g = 0.05, b = 0.055, a = 0.0}
    o.borderColor = {r = 0.35, g = 0.43, b = 0.46, a = 0.0}

    return o
end

function Winter_ModInfo:createChildren()
    self.titlePanel = Winter_ModInfoTitle:new(0, 0, self.width, TITLE_HEIGHT)
    self.titlePanel:initialise()
    self.titlePanel:instantiate()
    self:addChild(self.titlePanel)

    self.descPanel = Winter_ModInfoDesc:new(
        0,
        self.titlePanel:getBottom() - 1,
        self.width,
        DESC_HEIGHT
    )
    self.descPanel:initialise()
    self.descPanel:instantiate()
    self:addChild(self.descPanel)

    local posterWidth = POSTER_SIZE + UI_BORDER_SPACING * 2

    self.thumbnailPanel = Winter_ModInfoThumbnail:new(
        self.width - posterWidth,
        self.descPanel:getY(),
        posterWidth,
        self.descPanel:getHeight()
    )
    self.thumbnailPanel:initialise()
    self.thumbnailPanel:instantiate()
    self.thumbnailPanel:setAnchorRight(true)
    self:addChild(self.thumbnailPanel)

    local statusY = self.descPanel:getBottom() - 1
    local statusWidth = self.width / 4

    self.statusPanel = Winter_ModInfoStatus:new(
        0,
        statusY,
        statusWidth,
        BUTTON_HGT
    )
    self.statusPanel:initialise()
    self.statusPanel:instantiate()
    self:addChild(self.statusPanel)

    self.statusValuePanel = Winter_ModInfoStatusValue:new(
        statusWidth - 1,
        statusY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.statusValuePanel:initialise()
    self.statusValuePanel:instantiate()
    self:addChild(self.statusValuePanel)

    local versionY = self.statusPanel:getBottom() - 1

    self.versionPanel = Winter_ModInfoVersion:new(
        0,
        versionY,
        statusWidth,
        BUTTON_HGT
    )
    self.versionPanel:initialise()
    self.versionPanel:instantiate()
    self:addChild(self.versionPanel)

    self.versionValuePanel = Winter_ModInfoVersionValue:new(
        statusWidth - 1,
        versionY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.versionValuePanel:initialise()
    self.versionValuePanel:instantiate()
    self:addChild(self.versionValuePanel)

    local authorY = self.versionPanel:getBottom() - 1

    self.authorPanel = Winter_ModInfoAuthor:new(
        0,
        authorY,
        statusWidth,
        BUTTON_HGT
    )
    self.authorPanel:initialise()
    self.authorPanel:instantiate()
    self:addChild(self.authorPanel)

    self.authorValuePanel = Winter_ModInfoAuthorValue:new(
        statusWidth - 1,
        authorY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.authorValuePanel:initialise()
    self.authorValuePanel:instantiate()
    self:addChild(self.authorValuePanel)

    local modIDY = self.authorPanel:getBottom() - 1

    self.modIDPanel = Winter_ModInfoModID:new(
        0,
        modIDY,
        statusWidth,
        BUTTON_HGT
    )
    self.modIDPanel:initialise()
    self.modIDPanel:instantiate()
    self:addChild(self.modIDPanel)

    self.modIDValuePanel = Winter_ModInfoModIDValue:new(
        statusWidth - 1,
        modIDY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.modIDValuePanel:initialise()
    self.modIDValuePanel:instantiate()
    self:addChild(self.modIDValuePanel)

    local workshopIDY = self.modIDPanel:getBottom() - 1

    self.workshopIDPanel = Winter_ModInfoWorkshopID:new(
        0,
        workshopIDY,
        statusWidth,
        BUTTON_HGT
    )
    self.workshopIDPanel:initialise()
    self.workshopIDPanel:instantiate()
    self:addChild(self.workshopIDPanel)

    self.workshopIDValuePanel = Winter_ModInfoWorkshopIDValue:new(
        statusWidth - 1,
        workshopIDY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.workshopIDValuePanel:initialise()
    self.workshopIDValuePanel:instantiate()
    self:addChild(self.workshopIDValuePanel)

    local lastUpdateY = self.workshopIDPanel:getBottom() - 1

    self.lastUpdatePanel = Winter_ModInfoLastUpdate:new(
        0,
        lastUpdateY,
        statusWidth,
        BUTTON_HGT
    )
    self.lastUpdatePanel:initialise()
    self.lastUpdatePanel:instantiate()
    self:addChild(self.lastUpdatePanel)

    self.lastUpdateValuePanel = Winter_ModInfoLastUpdateValue:new(
        statusWidth - 1,
        lastUpdateY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.lastUpdateValuePanel:initialise()
    self.lastUpdateValuePanel:instantiate()
    self:addChild(self.lastUpdateValuePanel)

    local gameVersionY = self.lastUpdatePanel:getBottom() - 1

    self.gameVersionPanel = Winter_ModInfoGameVersion:new(
        0,
        gameVersionY,
        statusWidth,
        BUTTON_HGT
    )
    self.gameVersionPanel:initialise()
    self.gameVersionPanel:instantiate()
    self:addChild(self.gameVersionPanel)

    self.gameVersionValuePanel = Winter_ModInfoGameVersionValue:new(
        statusWidth - 1,
        gameVersionY,
        self.width - statusWidth + 1,
        BUTTON_HGT
    )
    self.gameVersionValuePanel:initialise()
    self.gameVersionValuePanel:instantiate()
    self:addChild(self.gameVersionValuePanel)
end

function Winter_ModInfo:updateView(modInfo)
    if not modInfo then
        return
    end

    local model = ModSelector.instance.model
    local modData = model.mods[modInfo:getId()]

    self.titlePanel:setModInfo(modInfo)
    self.descPanel:setModInfo(modInfo)
    self.thumbnailPanel:setModInfo(modInfo)
    self.versionValuePanel:setModInfo(modInfo)
    self.authorValuePanel:setModInfo(modInfo)
    self.modIDValuePanel:setModInfo(modInfo)
    self.workshopIDValuePanel:setModInfo(modInfo)
    self.lastUpdateValuePanel:setModData(modData)
    self.gameVersionValuePanel:setModInfo(modInfo)

    local isActive = model:isModActive(modInfo:getId())
    self.statusValuePanel:setStatus(isActive)
end

return Winter_ModInfo