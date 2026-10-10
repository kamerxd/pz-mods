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
local ACTIVE_COLOR = {r = 1.0, g = 0.82, b = 0.35}
local MISSING_COLOR = {r = 0.65, g = 0.18, b = 0.18}

local function makeLabel(className, label)
    local class = ISPanelJoypad:derive(className)
    class.label = label

    function class:new(x, y, width, height)
        local o = ISPanelJoypad:new(x, y, width, height)
        setmetatable(o, self)
        self.__index = self
        o.backgroundColor = PANEL_BACKGROUND
        o.borderColor = PANEL_BORDER
        return o
    end

    function class:prerender()
        ISPanelJoypad.prerender(self)
        self:drawTextRight(self.label, self.width - UI_BORDER_SPACING, 2, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, UIFont.Small)
    end

    return class
end

local function makeTextValue(className)
    local class = ISPanelJoypad:derive(className)

    function class:new(x, y, width, height)
        local o = ISPanelJoypad:new(x, y, width, height)
        setmetatable(o, self)
        self.__index = self
        o.value = ""
        o.backgroundColor = PANEL_BACKGROUND
        o.borderColor = PANEL_BORDER
        return o
    end

    function class:setValue(value)
        self.value = value or ""
    end

    function class:prerender()
        ISPanelJoypad.prerender(self)
        if self.value ~= "" then
            self:drawText(self.value, UI_BORDER_SPACING, 2, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, UIFont.Small)
        end
    end

    return class
end

local function addPanel(parent, class, x, y, width, height, anchorRight)
    local panel = class:new(x, y, width, height)
    panel:initialise()
    panel:instantiate()
    if anchorRight then panel:setAnchorRight(true) end
    parent:addChild(panel)
    return panel
end

local function truncateText(text, width)
    local manager = getTextManager()
    local font = UIFont.Small
    local textWidth = manager:MeasureStringX(font, text)
    if textWidth <= width then return text, textWidth, false end

    local dots = "..."
    local maxWidth = math.max(0, width - manager:MeasureStringX(font, dots))
    while text ~= "" and manager:MeasureStringX(font, text) > maxWidth do
        text = string.sub(text, 1, #text - 1)
    end

    text = text .. dots
    return text, manager:MeasureStringX(font, text), true
end

local Winter_ModInfoTitle = ISPanelJoypad:derive("Winter_ModInfoTitle")
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
    if self.title ~= "" then
        self:drawTextCentre(self.title, self.width / 2, 5, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, UIFont.Large)
    end
end

local Winter_ModInfoDesc = ISPanelJoypad:derive("Winter_ModInfoDesc")
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
    if self.description == "" then return end

    local manager = getTextManager()
    local font = UIFont.Small
    local lineHeight = manager:getFontFromEnum(font):getLineHeight()
    local maxWidth = self.width - POSTER_SIZE - UI_BORDER_SPACING * 3
    local words, line, y = {}, "", UI_BORDER_SPACING
    for word in string.gmatch(self.description, "%S+") do words[#words + 1] = word end

    for i = 1, #words do
        local candidate = line == "" and words[i] or line .. " " .. words[i]
        if manager:MeasureStringX(font, candidate) > maxWidth and line ~= "" then
            self:drawText(line, UI_BORDER_SPACING, y, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, font)
            y = y + lineHeight
            line = words[i]
        else
            line = candidate
        end
    end
    if line ~= "" then self:drawText(line, UI_BORDER_SPACING, y, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, font) end
end

local Winter_ModInfoThumbnail = ISPanelJoypad:derive("Winter_ModInfoThumbnail")
function Winter_ModInfoThumbnail:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.poster = nil
    o.backgroundColor = {r = 0.035, g = 0.05, b = 0.055, a = 0}
    o.borderColor = {r = 0.35, g = 0.43, b = 0.46, a = 0}
    return o
end
function Winter_ModInfoThumbnail:setModInfo(modInfo)
    self.poster = nil
    if modInfo then
        local poster = modInfo:getPoster(0)
        if poster and poster ~= "" then self.poster = getTexture(poster) end
    end
end
function Winter_ModInfoThumbnail:prerender()
    ISPanelJoypad.prerender(self)
    if not self.poster then return end
    local size = math.min(self.width, self.height) - UI_BORDER_SPACING * 2
    self:drawTextureScaledAspect(self.poster, self.width - size - UI_BORDER_SPACING, (self.height - size) / 2, size, size, 1, 1, 1, 1)
end

local Winter_ModInfoStatus = makeLabel("Winter_ModInfoStatus", "Status")
local Winter_ModInfoVersion = makeLabel("Winter_ModInfoVersion", "Version")
local Winter_ModInfoAuthor = makeLabel("Winter_ModInfoAuthor", "Author")
local Winter_ModInfoModID = makeLabel("Winter_ModInfoModID", "Mod ID")
local Winter_ModInfoWorkshopID = makeLabel("Winter_ModInfoWorkshopID", "Workshop ID")
local Winter_ModInfoLastUpdate = makeLabel("Winter_ModInfoLastUpdate", "Last Update")
local Winter_ModInfoGameVersion = makeLabel("Winter_ModInfoGameVersion", "Game Version")
local Winter_ModInfoDependencies = makeLabel("Winter_ModInfoDependencies", "Dependencies")
local Winter_ModInfoIncompatible = makeLabel("Winter_ModInfoIncompatible", "Incompatible With")
local Winter_ModInfoChangelog = makeLabel("Winter_ModInfoChangelog", "Changelog")

local Winter_ModInfoStatusValue = ISPanelJoypad:derive("Winter_ModInfoStatusValue")
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
    if self.status == "" then return end
    local color = self.isActive and ACTIVE_COLOR or MISSING_COLOR
    self:drawText(self.status, UI_BORDER_SPACING, 2, color.r, color.g, color.b, 1, UIFont.Small)
end

local Winter_ModInfoVersionValue = makeTextValue("Winter_ModInfoVersionValue")
function Winter_ModInfoVersionValue:setModInfo(modInfo)
    self.value = modInfo and modInfo:getModVersion() or ""
end
local Winter_ModInfoAuthorValue = makeTextValue("Winter_ModInfoAuthorValue")
function Winter_ModInfoAuthorValue:setModInfo(modInfo)
    self.value = modInfo and modInfo:getAuthor() or ""
end
local Winter_ModInfoModIDValue = makeTextValue("Winter_ModInfoModIDValue")
function Winter_ModInfoModIDValue:setModInfo(modInfo)
    self.value = modInfo and "\\" .. modInfo:getId() or ""
end
local Winter_ModInfoGameVersionValue = makeTextValue("Winter_ModInfoGameVersionValue")
function Winter_ModInfoGameVersionValue:setModInfo(modInfo)
    self.value = ""
    if not modInfo then return end
    local minVersion, maxVersion = modInfo:getVersionMin(), modInfo:getVersionMax()
    self.value = (minVersion and minVersion:toString() or "**") .. " - " .. (maxVersion and maxVersion:toString() or "**")
end

local Winter_ModInfoWorkshopIDValue = ISPanelJoypad:derive("Winter_ModInfoWorkshopIDValue")
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
    self.workshopID, self.displayWorkshopID, self.workshopIDLen = "", "", 0
    if not modInfo then return end
    self.workshopID = modInfo:getWorkshopID() or ""
    self.displayWorkshopID = self.workshopID
    if self.workshopID == "" then return end
    self.displayWorkshopID, self.workshopIDLen = truncateText(self.displayWorkshopID, self.width - UI_BORDER_SPACING * 2)
end
function Winter_ModInfoWorkshopIDValue:onMouseDown(x, y)
    self.pressed = true
end
function Winter_ModInfoWorkshopIDValue:prerender()
    ISPanelJoypad.prerender(self)
    if self.displayWorkshopID == "" then self.pressed = false; return end

    local x, y = UI_BORDER_SPACING, 2
    local hovered = self:isMouseOver() and self:getMouseX() > x and self:getMouseX() < x + self.workshopIDLen and self:getMouseY() > y and self:getMouseY() < y + FONT_HGT_SMALL + 1
    self:drawText(self.displayWorkshopID, x, y, 0.2, 0.6, 1, 1, UIFont.Small)
    if not hovered then
        self:drawRectBorder(x, 1 + FONT_HGT_SMALL, self.workshopIDLen, 1, 0.9, 0.2, 0.6, 1)
    elseif self.pressed then
        activateSteamOverlayToWorkshopItem(self.workshopID)
    end
    self.pressed = false
end

local Winter_ModInfoLastUpdateValue = ISPanelJoypad:derive("Winter_ModInfoLastUpdateValue")
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
    if not seconds or seconds == 0 then return "" end

    local millis = seconds * 1000.0
    local nowMillis = getTimestampMs()
    local dateStr = SimpleDateFormat.new("d M yyyy H m"):format(millis)
    local values = {}
    for v in string.gmatch(dateStr, "%S+") do values[#values + 1] = tonumber(v) end

    local day, month, year, hour, min = values[1], values[2], values[3], values[4], values[5]
    local sdf = SimpleDateFormat.new("yyyyMMdd")
    local dateKey, nowKey = sdf:format(millis), sdf:format(nowMillis)
    local yesterdayKey = sdf:format(nowMillis - 86400000.0)
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
        if h12 > 12 then h12 = h12 - 12 end
    else
        ampm = getText("UI_modinfopanel_AM")
        if h12 == 0 then h12 = 12 end
    end

    local result = timeFormat
    result = result:gsub("{day}", tostring(day))
    result = result:gsub("{month}", tostring(monthStr))
    result = result:gsub("{year}", tostring(year))
    result = result:gsub("{hour24}", string.format("%02d", hour))
    result = result:gsub("{hour12}", tostring(h12))
    result = result:gsub("{min}", string.format("%02d", min))
    result = result:gsub("{ampm}", tostring(ampm))
    return result
end
function Winter_ModInfoLastUpdateValue:setModData(modData)
    self.formattedDate = modData and self:formatDate(modData.timeUpdated) or ""
end
function Winter_ModInfoLastUpdateValue:prerender()
    ISPanelJoypad.prerender(self)
    if self.formattedDate ~= "" then
        self:drawText(self.formattedDate, UI_BORDER_SPACING, 2, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, UIFont.Small)
    end
end

local function makeModLinkValue(className, kind)
    local class = ISPanelJoypad:derive(className)

    function class:new(x, y, width, height)
        local o = ISPanelJoypad:new(x, y, width, height)
        setmetatable(o, self)
        self.__index = self
        o.kind = kind
        o.modInfo = nil
        o.items = {}
        o.tooltip = nil
        o.pressed = false
        o.backgroundColor = PANEL_BACKGROUND
        o.borderColor = PANEL_BORDER
        return o
    end

    function class:initialise()
        ISPanelJoypad.initialise(self)
        self.tooltipUI = ISToolTip:new()
        self.tooltipUI:initialise()
        self.tooltipUI:setOwner(self)
    end

    function class:update()
        ISPanelJoypad.update(self)
        if self.tooltipUI and self:isMouseOver() and self.tooltip and self.tooltip ~= "" then
            if not self.tooltipUI:getIsVisible() then
                self.tooltipUI:addToUIManager()
                self.tooltipUI:setVisible(true)
            end
            self.tooltipUI.description = self.tooltip
        elseif self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end

    function class:setModInfo(modInfo)
        self.modInfo, self.items, self.tooltip = modInfo, {}, nil
        local model = ModSelector.instance.model
        local ids = {}

        if kind == "dependencies" then
            local data = modInfo and model.mods[modInfo:getId()]
            if modInfo and modInfo:getRequire() and data and data.requireMods then
                for id in pairs(data.requireMods) do ids[#ids + 1] = id end
            end
        else
            local incompatible = modInfo and modInfo:getIncompatible() and model.incompatibles and model.incompatibles[modInfo:getId()]
            if incompatible then
                for id in pairs(incompatible) do ids[#ids + 1] = id end
            end
        end

        table.sort(ids)
        local fullText, truncated = {}, false
        local width = self.width - UI_BORDER_SPACING * 2

        for i = 1, #ids do
            local id = ids[i]
            local data = model.mods[id]
            local color = MISSING_COLOR
            if data then
                if kind == "dependencies" then
                    color = data.isActive and ACTIVE_COLOR or TEXT_COLOR
                elseif not data.isActive then
                    color = TEXT_COLOR
                end
            end

            local fullID = string.sub(id, 1, 1) == "\\" and id or "\\" .. id
            local displayID, textWidth, wasTruncated = truncateText(fullID, width)
            fullText[#fullText + 1] = fullID
            truncated = truncated or wasTruncated
            self.items[#self.items + 1] = {
                id = id,
                displayID = displayID,
                width = textWidth,
                color = color,
                data = data,
                modInfo = data and data.modInfo or nil
            }
        end

        if truncated then self.tooltip = table.concat(fullText, "\n") end

        local height = math.max(BUTTON_HGT, #self.items * BUTTON_HGT)
        self:setHeight(height)
        local parent = self.parent

        if kind == "dependencies" then
            if parent and parent.dependenciesPanel then parent.dependenciesPanel:setHeight(height) end
            if parent and parent.incompatiblePanel then
                local y = parent.dependenciesPanel:getBottom() - 1
                parent.incompatiblePanel:setY(y)
                parent.incompatibleValuePanel:setY(y)
            end
        else
            if parent and parent.incompatiblePanel then parent.incompatiblePanel:setHeight(height) end
            if parent then parent:updateChangelogLayout() end
        end
    end

    function class:onMouseDown(x, y)
        self.pressed = true
    end

    function class:prerender()
        ISPanelJoypad.prerender(self)
        if #self.items == 0 then
            self:drawText("", UI_BORDER_SPACING, 2, TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b, TEXT_COLOR.a, UIFont.Small)
            self.pressed = false
            return
        end

        local screen = self.parent and self.parent.parent
        local modList = screen and screen.modList

        for i = 1, #self.items do
            local item = self.items[i]
            local textY = 2 + (i - 1) * BUTTON_HGT
            local mx, my = self:getMouseX(), self:getMouseY()
            local hovered = self:isMouseOver() and mx >= UI_BORDER_SPACING and mx < UI_BORDER_SPACING + item.width and my >= textY and my < textY + FONT_HGT_SMALL + 1

            self:drawText(item.displayID, UI_BORDER_SPACING, textY, item.color.r, item.color.g, item.color.b, 1, UIFont.Small)
            if not hovered then
                self:drawRectBorder(UI_BORDER_SPACING, textY + FONT_HGT_SMALL, item.width, 1, 0.9, item.color.r, item.color.g, item.color.b)
            elseif self.pressed then
                if item.data and item.modInfo then
                    local found = false
                    if modList then
                        for index = 1, #modList.items do
                            local row = modList.items[index]
                            local data = row.item and row.item.modData
                            if data and data.modInfo and data.modInfo:getId() == item.id then
                                modList.selected = index
                                modList:updateSelection()
                                found = true
                                break
                            end
                        end
                    end
                    if not found and self.parent then self.parent:updateView(item.modInfo) end
                elseif kind == "dependencies" then
                    local workshopID = item.data and item.data.workshopIDStr
                    if workshopID and workshopID ~= "" then activateSteamOverlayToWorkshopItem(workshopID) end
                end
                break
            end
        end

        self.pressed = false
    end

    return class
end

local Winter_ModInfoDependenciesValue = makeModLinkValue("Winter_ModInfoDependenciesValue", "dependencies")
local Winter_ModInfoIncompatibleValue = makeModLinkValue("Winter_ModInfoIncompatibleValue", "incompatible")

local function Winter_ModInfo_splitLines(str)
    local lines, start = {}, 1
    while true do
        local pos = string.find(str, "\n", start, true)
        if not pos then
            lines[#lines + 1] = string.sub(str, start)
            break
        end
        lines[#lines + 1] = string.sub(str, start, pos - 1)
        start = pos + 1
    end
    return lines
end

local function Winter_ModInfo_stripInline(text)
    text = string.gsub(text, "%*%*%*(.-)%*%*%*", "%1")
    text = string.gsub(text, "%*%*(.-)%*%*", "%1")
    text = string.gsub(text, "~~(.-)~~", "%1")
    text = "\0" .. text .. "\0"
    text = string.gsub(text, "([^%w_])__(%S.-)__([^%w_])", "%1%2%3")
    text = string.gsub(text, "([^%w_])_(%S.-)_([^%w_])", "%1%2%3")
    text = string.gsub(text, "([^%w*])%*(%S.-)%*([^%w*])", "%1%2%3")
    text = string.sub(text, 2, -2)
    text = string.gsub(text, "%(%[(#%d+)%]%((.-)%)%)", "(%1)")
    return string.gsub(text, "%[(.-)%]%((.-)%)", function(label)
        if string.match(label, "^\".-\"$") then return label end
        return "\"" .. label .. "\""
    end)
end

local function Winter_ModInfo_markdownToPlaintext(content)
    content = string.gsub(content, "<!%-%-[%s%S]-%-%->", "")
    local lines = Winter_ModInfo_splitLines(content)

    local result, inCode = "", false
    for i = 1, #lines do
        local raw, line = lines[i], string.trim(lines[i])
        if string.match(line, "^```") then
            inCode = not inCode
        elseif inCode then
            result = result .. raw .. "\n"
        elseif line == "" then
            result = result .. "\n"
        else
            local h3, h2, h1 = string.match(line, "^###%s+(.+)$"), string.match(line, "^##%s+(.+)$"), string.match(line, "^#%s+(.+)$")
            local hr = string.match(line, "^%-%-%-+$") or string.match(line, "^%*%*%*+$") or string.match(line, "^___+$")
            local quote = string.match(line, "^>%s*(.*)$")
            local ulIndent, ulText = string.match(raw, "^(%s*)[-*+]%s+(.+)$")
            local olIndent, olText = string.match(raw, "^(%s*)%d+%.%s+(.+)$")

            if h3 then result = result .. Winter_ModInfo_stripInline(h3) .. "\n"
            elseif h2 then result = result .. Winter_ModInfo_stripInline(h2) .. "\n"
            elseif h1 then result = result .. Winter_ModInfo_stripInline(h1) .. "\n"
            elseif hr then result = result .. "---\n"
            elseif quote ~= nil then result = result .. Winter_ModInfo_stripInline(quote) .. "\n"
            elseif ulIndent and ulText then
                local tabs = 0
                for _ in string.gmatch(ulIndent, "\t") do tabs = tabs + 1 end
                local level = tabs > 0 and tabs or math.floor(#ulIndent / 4)
                local indent = level * 20
                if indent > 0 then result = result .. " <INDENT:" .. indent .. "> " end
                result = result .. "- " .. Winter_ModInfo_stripInline(ulText) .. "\n"
                if indent > 0 then result = result .. " <INDENT:0> " end
            elseif olIndent and olText then
                local tabs = 0
                for _ in string.gmatch(olIndent, "\t") do tabs = tabs + 1 end
                local level = tabs > 0 and tabs or math.floor(#olIndent / 4)
                local indent = level * 20
                if indent > 0 then result = result .. " <INDENT:" .. indent .. "> " end
                result = result .. olText .. "\n"
                if indent > 0 then result = result .. " <INDENT:0> " end
            else
                result = result .. Winter_ModInfo_stripInline(line) .. "\n"
            end
        end
    end
    return string.trim(result)
end

local function Winter_ModInfo_detectMdFormat(lines)
    local inComment = false
    for i = 1, #lines do
        local line = string.trim(lines[i])
        if string.match(line, "^<!%-%-") then
            if not string.match(line, "%-%->$") then inComment = true end
        elseif inComment and string.match(line, "%-%->$") then
            inComment = false
        elseif not inComment and line ~= "" then
            return string.match(line, "^###%s*.-%s*###") and "legacy" or "modern"
        end
    end
    return "modern"
end

local function Winter_ModInfo_parseLegacyMd(lines)
    local entries, title, contents, inComment = nil, nil, nil, false
    for i = 1, #lines do
        local line, trimmed = lines[i], string.trim(lines[i])
        if string.match(trimmed, "^<!%-%-") then
            if not string.match(trimmed, "%-%->$") then inComment = true end
        elseif inComment and string.match(trimmed, "%-%->$") then
            inComment = false
        else
            local heading = string.match(trimmed, "^###%s*(.-)%s*###$")
            if heading then
                if heading ~= "ALERT_CONFIG" then
                    if title then
                        entries = entries or {}
                        entries[#entries + 1] = {title = title, contents = string.trim(contents or "")}
                    end
                    title, contents = heading, ""
                end
            elseif trimmed == "#" then
                if title then
                    entries = entries or {}
                    entries[#entries + 1] = {title = title, contents = string.trim(contents or "")}
                    title, contents = nil, nil
                end
            elseif title and not inComment then
                contents = (contents or "") .. line .. "\n"
            end
        end
    end
    if title then
        entries = entries or {}
        entries[#entries + 1] = {title = title, contents = string.trim(contents or "")}
    end
    return entries
end

local function Winter_ModInfo_parseMdHeader(line)
    local title = string.match(line, "^#%s+(.+)$")
    if not title then return nil end
    local version = string.match(title, "^%[(.-)%]") or string.match(title, "^(.-)%s+%-%s")
    return string.trim(version or title)
end

local function Winter_ModInfo_parseTxtHeader(line)
    if string.match(line, "^%[%s*%-%-+%s*%]$") or line == "#" then return nil, true end
    local title = string.match(line, "^%[%s*(.-)%s*%]$") or string.match(line, "^###%s*(.-)%s*###$")
    if title and title ~= "ALERT_CONFIG" then return title, false end
    return nil, false
end

local function Winter_ModInfo_fetchChangelog(modID)
    if not modID or modID == "" then return nil, false, false end
    local reader = getModFileReader(modID, "ChangeLog.md", false)
    local isMd = reader ~= nil
    if not reader then reader = getModFileReader(modID, "ChangeLog.txt", false) end
    if not reader then return nil, false, false end

    local lines, line = {}, reader:readLine()
    while line do
        lines[#lines + 1] = line
        line = reader:readLine()
    end
    reader:close()

    if isMd and Winter_ModInfo_detectMdFormat(lines) == "legacy" then
        return Winter_ModInfo_parseLegacyMd(lines), true, true
    end

    local entries, title, contents, inComment = nil, nil, nil, false
    for i = 1, #lines do
        line = lines[i]
        local trimmed = string.trim(line)
        local version, separator

        if string.match(trimmed, "^<!%-%-") then
            if not string.match(trimmed, "%-%->$") then inComment = true end
        elseif inComment and string.match(trimmed, "%-%->$") then
            inComment = false
        elseif isMd then
            version = Winter_ModInfo_parseMdHeader(trimmed)
        else
            version, separator = Winter_ModInfo_parseTxtHeader(trimmed)
        end

        if separator then
            if title then
                entries = entries or {}
                entries[#entries + 1] = {title = title, contents = contents or ""}
            end
            title, contents = nil, nil
        elseif version then
            if title then
                entries = entries or {}
                entries[#entries + 1] = {title = title, contents = contents or ""}
            end
            title, contents = version, ""
        elseif title and not inComment then
            if isMd then
                contents = contents .. line .. "\n"
            elseif trimmed ~= "" then
                contents = contents .. trimmed .. "\n"
            end
        end
    end
    if title then
        entries = entries or {}
        entries[#entries + 1] = {title = title, contents = contents or ""}
    end
    return entries, isMd, false
end

local Winter_ModInfoChangelogValue = ISPanelJoypad:derive("Winter_ModInfoChangelogValue")
function Winter_ModInfoChangelogValue:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.modInfo = nil
    o.backgroundColor = PANEL_BACKGROUND
    o.borderColor = PANEL_BORDER
    return o
end
function Winter_ModInfoChangelogValue:createChildren()
    self.richText = ISRichTextPanel:new(UI_BORDER_SPACING, 3, self.width - UI_BORDER_SPACING * 2 - 2, self.height - 6)
    self.richText:initialise()
    self.richText:instantiate()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self.richText.defaultFont = UIFont.Small
    self.richText.autosetheight = false
    self.richText.clip = true
    self.richText:noBackground()
    self.richText.marginLeft = 0
    self.richText.marginTop = 0
    self.richText.marginRight = 0
    self.richText.marginBottom = 0
    self:addChild(self.richText)
    self.richText:addScrollBars()
    self.richText.marginRight = self.richText.vscroll and self.richText.vscroll:getWidth() or 0
end
function Winter_ModInfoChangelogValue:onMouseWheel(del)
    return self.richText and self.richText:onMouseWheel(del) or false
end
function Winter_ModInfoChangelogValue:recalcSize()
    ISPanelJoypad.recalcSize(self)
    if self.richText then
        self.richText:setWidth(self.width - UI_BORDER_SPACING * 2 - 2)
        self.richText:setHeight(self.height - 6)
    end
end
function Winter_ModInfoChangelogValue:setModInfo(modInfo)
    if not self.richText then return end
    self.modInfo = modInfo
    if not modInfo then
        self.richText:setText("")
        self.richText:paginate()
        self.richText:setYScroll(0)
        return
    end

    local entries, isMd, isLegacy = Winter_ModInfo_fetchChangelog(modInfo:getId())
    if not entries or #entries == 0 then
        self.richText:setText("")
        self.richText:paginate()
        self.richText:setYScroll(0)
        return
    end

    local parts = {" <TEXT> "}
    local first, last, step = 1, #entries, 1
    if not (isMd and not isLegacy) then first, last, step = #entries, 1, -1 end

    local latest = true
    for i = first, last, step do
        local entry = entries[i]
        if type(entry.title) == "string" then
            local contents = isMd and not isLegacy and Winter_ModInfo_markdownToPlaintext(entry.contents or "") or string.trim(entry.contents or "")
            local color = latest and " <RGB:0.8,0.8,0.8> " or " <RGB:0.4,0.4,0.4> "
            parts[#parts + 1] = color .. entry.title .. " <LINE> "
            parts[#parts + 1] = color .. contents
            parts[#parts + 1] = " <LINE> <LINE> "
            latest = false
        end
    end

    self.richText:setText(table.concat(parts, ""))
    self.richText:paginate()
    self.richText:setYScroll(0)
end

function Winter_ModInfo:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0.035, g = 0.05, b = 0.055, a = 0}
    o.borderColor = {r = 0.35, g = 0.43, b = 0.46, a = 0}
    return o
end

function Winter_ModInfo:updateChangelogLayout()
    if not self.incompatiblePanel or not self.changelogPanel or not self.changelogValuePanel then return end
    local y = self.incompatiblePanel:getBottom() - 1
    local height = math.max(BUTTON_HGT, self.height - y)
    self.changelogPanel:setY(y)
    self.changelogPanel:setHeight(height)
    self.changelogValuePanel:setY(y)
    self.changelogValuePanel:setHeight(height)
    self.changelogValuePanel:recalcSize()
end

function Winter_ModInfo:createChildren()
    self.titlePanel = addPanel(self, Winter_ModInfoTitle, 0, 0, self.width, TITLE_HEIGHT)
    self.descPanel = addPanel(self, Winter_ModInfoDesc, 0, self.titlePanel:getBottom() - 1, self.width, DESC_HEIGHT)
    self.thumbnailPanel = addPanel(self, Winter_ModInfoThumbnail, self.width - POSTER_SIZE - UI_BORDER_SPACING * 2, self.descPanel:getY(), POSTER_SIZE + UI_BORDER_SPACING * 2, self.descPanel:getHeight(), true)

    local statusWidth = self.width / 4
    local y = self.descPanel:getBottom() - 1
    self.statusPanel = addPanel(self, Winter_ModInfoStatus, 0, y, statusWidth, BUTTON_HGT)
    self.statusValuePanel = addPanel(self, Winter_ModInfoStatusValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.statusPanel:getBottom() - 1
    self.versionPanel = addPanel(self, Winter_ModInfoVersion, 0, y, statusWidth, BUTTON_HGT)
    self.versionValuePanel = addPanel(self, Winter_ModInfoVersionValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.versionPanel:getBottom() - 1
    self.authorPanel = addPanel(self, Winter_ModInfoAuthor, 0, y, statusWidth, BUTTON_HGT)
    self.authorValuePanel = addPanel(self, Winter_ModInfoAuthorValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.authorPanel:getBottom() - 1
    self.modIDPanel = addPanel(self, Winter_ModInfoModID, 0, y, statusWidth, BUTTON_HGT)
    self.modIDValuePanel = addPanel(self, Winter_ModInfoModIDValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.modIDPanel:getBottom() - 1
    self.workshopIDPanel = addPanel(self, Winter_ModInfoWorkshopID, 0, y, statusWidth, BUTTON_HGT)
    self.workshopIDValuePanel = addPanel(self, Winter_ModInfoWorkshopIDValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.workshopIDPanel:getBottom() - 1
    self.lastUpdatePanel = addPanel(self, Winter_ModInfoLastUpdate, 0, y, statusWidth, BUTTON_HGT)
    self.lastUpdateValuePanel = addPanel(self, Winter_ModInfoLastUpdateValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.lastUpdatePanel:getBottom() - 1
    self.gameVersionPanel = addPanel(self, Winter_ModInfoGameVersion, 0, y, statusWidth, BUTTON_HGT)
    self.gameVersionValuePanel = addPanel(self, Winter_ModInfoGameVersionValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.gameVersionPanel:getBottom() - 1
    self.dependenciesPanel = addPanel(self, Winter_ModInfoDependencies, 0, y, statusWidth, BUTTON_HGT)
    self.dependenciesValuePanel = addPanel(self, Winter_ModInfoDependenciesValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.dependenciesPanel:getBottom() - 1
    self.incompatiblePanel = addPanel(self, Winter_ModInfoIncompatible, 0, y, statusWidth, BUTTON_HGT)
    self.incompatibleValuePanel = addPanel(self, Winter_ModInfoIncompatibleValue, statusWidth - 1, y, self.width - statusWidth + 1, BUTTON_HGT)

    y = self.incompatiblePanel:getBottom() - 1
    local height = math.max(BUTTON_HGT, self.height - y)
    self.changelogPanel = addPanel(self, Winter_ModInfoChangelog, 0, y, statusWidth, height)
    self.changelogValuePanel = addPanel(self, Winter_ModInfoChangelogValue, statusWidth - 1, y, self.width - statusWidth + 1, height)
    self:updateChangelogLayout()
end

function Winter_ModInfo:updateView(modInfo)
    if not modInfo then return end
    local model = ModSelector.instance.model
    local data = model.mods[modInfo:getId()]

    self.titlePanel:setModInfo(modInfo)
    self.descPanel:setModInfo(modInfo)
    self.thumbnailPanel:setModInfo(modInfo)
    self.versionValuePanel:setModInfo(modInfo)
    self.authorValuePanel:setModInfo(modInfo)
    self.modIDValuePanel:setModInfo(modInfo)
    self.workshopIDValuePanel:setModInfo(modInfo)
    self.lastUpdateValuePanel:setModData(data)
    self.gameVersionValuePanel:setModInfo(modInfo)
    self.dependenciesValuePanel:setModInfo(modInfo)
    self.incompatibleValuePanel:setModInfo(modInfo)
    self.changelogValuePanel:setModInfo(modInfo)
    self.statusValuePanel:setStatus(model:isModActive(modInfo:getId()))
end

return Winter_ModInfo
