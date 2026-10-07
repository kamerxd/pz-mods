local Winter_ModList = ISScrollingListBox:derive("Winter_ModList")

local TEXT_MANAGER = getTextManager()
local UI_BORDER_SPACING = 10
local BUTTON_HGT = TEXT_MANAGER:getFontHeight(UIFont.Small) + 6
local ITEM_HEIGHT = BUTTON_HGT + 12
local TEXT_HEIGHT = TEXT_MANAGER:getFontFromEnum(UIFont.Medium):getLineHeight()
local TEXT_SPACING = TEXT_MANAGER:MeasureStringX(UIFont.Small, "  ")
local CHECK_SIZE = 16
local CHECK_X = 8
local ICON_GAP = 6
local TEXT_GAP = 4
local AUTHOR_GAP = 10
local SCROLL_OFFSET = 10

local GOLD_R, GOLD_G, GOLD_B = 0.32, 0.27, 0.10
local ACTIVE_R, ACTIVE_G, ACTIVE_B = 1.0, 0.82, 0.35

if not ModSelector.Model._winterFavoriteSaveHooked then
    local originalSetFavorite = ModSelector.Model.setFavorite

    function ModSelector.Model:setFavorite(id, isFavorite)
        originalSetFavorite(self, id, isFavorite)
        self:saveModDataToFile()
    end

    ModSelector.Model._winterFavoriteSaveHooked = true
end

local function getFavoriteX(list)
    local offset = list:isVScrollBarVisible() and SCROLL_OFFSET or 0
    return list.width - UI_BORDER_SPACING - BUTTON_HGT - 1 - offset
end

function Winter_ModList:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.starUnsetTexture = getTexture("media/ui/inventoryPanes/FavouriteNo.png")
    o.starSetTexture = getTexture("media/ui/inventoryPanes/FavouriteYes.png")

    return o
end

function Winter_ModList:setup()
    self.itemheight = ITEM_HEIGHT
    self.font = UIFont.Medium
    self.drawBorder = true
    self.backgroundColor = {r = 0.035, g = 0.05, b = 0.055, a = 0.75}
    self.borderColor = {r = 0.35, g = 0.43, b = 0.46, a = 0.7}
    self.doDrawItem = self.drawModListItem
    self:loadMods()
end

function Winter_ModList:loadMods()
    self:clear()

    local model = ModSelector.instance.model

    if not self.modsInitialized then
        model:reloadMods()
        self.modsInitialized = true
    end

    local mods = {}

    for modId, modData in pairs(model.mods) do
        local modInfo = modData.modInfo
        local name = modInfo:getName()

        if name and name ~= "" then
            local displayName = getTextOrNull(name) or name
            local author = modInfo:getAuthor() or ""
            local icon = modInfo:getIcon()

            mods[#mods + 1] = {
                modId = modId,
                modData = modData,
                name = displayName,
                author = author,
                iconTexture = icon and icon ~= "" and getTexture(icon) or nil,
                nameWidth = TEXT_MANAGER:MeasureStringX(self.font, displayName),
                authorWidth = TEXT_MANAGER:MeasureStringX(self.font, author)
            }
        end
    end

    table.sort(mods, function(a, b)
        local aFavorite = a.modData.favorite ~= nil and a.modData.favorite ~= false
        local bFavorite = b.modData.favorite ~= nil and b.modData.favorite ~= false

        if aFavorite ~= bFavorite then
            return aFavorite
        end

        return a.name < b.name
    end)

    for i = 1, #mods do
        local mod = mods[i]
        self:addItem(mod.name, mod)
    end
end

function Winter_ModList:drawModListItem(y, item)
    local rowHeight = self.itemheight
    local width = self.width
    local itemData = item.item
    local data = itemData.modData
    local isActive = data.isActive == true
    local isFavorite = data.favorite ~= nil and data.favorite ~= false
    local selected = self.selected == item.index
    local hovered = self.mouseoverselected == item.index and not self:isMouseOverScrollBar()

    local backgroundR, backgroundG, backgroundB = 0.06, 0.08, 0.09
    local backgroundAlpha = 0.45

    if selected then
        backgroundR, backgroundG, backgroundB = GOLD_R, GOLD_G, GOLD_B
        backgroundAlpha = 0.75
    elseif hovered then
        backgroundR, backgroundG, backgroundB = 0.12, 0.16, 0.17
        backgroundAlpha = 0.65
    end

    self:drawRect(0, y, width, rowHeight, backgroundAlpha, backgroundR, backgroundG, backgroundB)
    self:drawRectBorder(0, y, width, rowHeight, 0.45, 0.35, 0.43, 0.46)

    local checkY = y + (rowHeight - CHECK_SIZE) / 2

    self:drawRectBorder(CHECK_X, checkY, CHECK_SIZE, CHECK_SIZE, 0.7, 0.55, 0.65, 0.70)

    if isActive then
        self:drawRect(CHECK_X + 2, checkY + 2, CHECK_SIZE - 4, CHECK_SIZE - 4, 1.0, ACTIVE_R, ACTIVE_G, ACTIVE_B)
        self:drawLine2(CHECK_X + 4, checkY + 8, CHECK_X + 7, checkY + 11, 1.0, 0.08, 0.10, 0.11)
        self:drawLine2(CHECK_X + 7, checkY + 11, CHECK_X + 12, checkY + 5, 1.0, 0.08, 0.10, 0.11)
    end

    local iconSize = BUTTON_HGT
    local iconX = CHECK_X + CHECK_SIZE + ICON_GAP
    local iconY = y + (rowHeight - iconSize) / 2

    if itemData.iconTexture then
        self:drawTextureScaled(itemData.iconTexture, iconX, iconY, iconSize, iconSize, 1, 1, 1, 1)
    end

    local textX = iconX + iconSize + TEXT_GAP
    local textY = y + (rowHeight - TEXT_HEIGHT) / 2

    local textR, textG, textB = 0.82, 0.85, 0.86

    if isActive then
        textR, textG, textB = ACTIVE_R, ACTIVE_G, ACTIVE_B
    elseif selected then
        textR, textG, textB = 0.95, 0.97, 0.98
    end

    self:drawText(item.text, textX, textY, textR, textG, textB, 1.0, self.font)

    local favoriteX = getFavoriteX(self)
    local favoriteY = y + (rowHeight - BUTTON_HGT) / 2

    self:drawTextureScaled(
        isFavorite and self.starSetTexture or self.starUnsetTexture,
        favoriteX,
        favoriteY,
        BUTTON_HGT,
        BUTTON_HGT,
        1,
        1,
        1,
        1
    )

    if itemData.author ~= "" then
        local authorX = favoriteX - AUTHOR_GAP
        local availableWidth = authorX - textX - itemData.nameWidth - TEXT_SPACING
        local author = itemData.author

        if availableWidth > 0 then
            if itemData.authorWidth > availableWidth then
                while #author > 3 and TEXT_MANAGER:MeasureStringX(self.font, author .. "...") > availableWidth do
                    author = string.sub(author, 1, #author - 1)
                end
                author = author .. "..."
            end

            self:drawTextRight(author, authorX, textY, 0.55, 0.59, 0.60, 0.9, self.font)
        end
    end

    return y + rowHeight
end

function Winter_ModList:toggleSelectedMod()
    local item = self.items[self.selected]

    if not item or not item.item then
        return
    end

    local modData = item.item.modData

    ModSelector.instance.model:forceActivateMods(
        modData.modInfo,
        not modData.isActive
    )
end

function Winter_ModList:toggleFavorite(item)
    if not item or not item.item then
        return
    end

    local modData = item.item.modData

    ModSelector.instance.model:setFavorite(
        modData.modId,
        not modData.favorite
    )
end

function Winter_ModList:onMouseDown(x, y)
    if #self.items == 0 or self:isMouseOverScrollBar() then
        return
    end

    local row = self:rowAt(x, y)

    if row < 1 or row > #self.items then
        return
    end

    local item = self.items[row]

    if x >= CHECK_X and x <= CHECK_X + CHECK_SIZE then
        self.selected = row
        self:toggleSelectedMod()
        return true
    end

    local favoriteX = getFavoriteX(self)

    if x >= favoriteX and x <= favoriteX + BUTTON_HGT then
        self:toggleFavorite(item)
        return true
    end

    self.selected = row
    return true
end

return Winter_ModList
