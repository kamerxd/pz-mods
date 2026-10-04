
local Winter_Soundplayer = require "Kamer_Winter_Menu/Winter_Soundplayer"
local Winter_ScreenManager = require "Kamer_Winter_Menu/Winter_ScreenManager"

local Winter_Menu = ISPanelJoypad:derive("Kamer_Winter_Menu")
local Winter_Menu_Instance

local Winter_TextButton = ISPanelJoypad:derive("Kamer_Winter_TextButton")
local Winter_Controls = ISPanelJoypad:derive("Kamer_Winter_Controls")
local Winter_Controls_Instance

local Winter_OtherControls = ISPanelJoypad:derive("Kamer_Winter_OtherControls")
local Winter_OtherControls_Instance

-- pz devs in nutshell
local WinterVideo
local VIDEO_PATH = "../../../../workshop/content/108600/winter.bik"
local WINTER_INTRO_BLACK_TIME = 5.0
local WINTER_INTRO_FADE_TIME = 2.5

local versionText = "Winter 0.1 | B42.21"

local function Winter_hideMainControls()
    Winter_Controls_Instance:setVisible(false)
    Winter_OtherControls_Instance:setVisible(false)
end

local function Winter_showMainControls()
    Winter_Controls_Instance:setVisible(true)
    Winter_OtherControls_Instance:setVisible(true)

    Winter_Controls_Instance:bringToTop()
    Winter_OtherControls_Instance:bringToTop()
end

local function Winter_onMods(button)
    Winter_hideMainControls() 

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local width = screenWidth * 0.8
    local height = screenHeight * 0.8

    local modSelector = ModSelector:new((screenWidth - width) / 2, (screenHeight - height) / 2, width, height)
    modSelector:initialise()
    modSelector:instantiate()
    modSelector:create()

    modSelector.model.isNewGame = false
    modSelector.model:reloadMods()

    modSelector.returnToUI = Winter_Menu_Instance

    Winter_ScreenManager.open("mods", modSelector, {onEscape = function(screen) screen.backButton:forceClick() end, onClose = function() Winter_showMainControls() end})
    modSelector:setVisible(true)
    modSelector:addToUIManager()
    modSelector:setAlwaysOnTop(true)
    modSelector:bringToTop()
end

local function Winter_createButton(parent, x, y, width, height, text, callback)
    local button = Winter_TextButton:new(x, y, width, height, text, callback)
    button:initialise()
    button:instantiate()

    parent:addChild(button)

    return button
end

local function Winter_onClickReportBug(button)
	local url = "https://theindiestone.com/forums/index.php?/topic/43261-read-here-first-bug-reporting-guideformatting/"
	if isSteamOverlayEnabled() then
		activateSteamOverlayToWebPage(url)
	else
		openUrl(url)
	end
end

local function Winter_menuLoad()
    local SoundManager = getSoundManager()
    SoundManager:setMusicState("Loading")
    Winter_Soundplayer.init()

    WinterVideo = VideoTexture.getOrCreate(VIDEO_PATH, 1920, 1080)

    Winter_Menu_Instance = Winter_Menu:new(false) 
    Winter_Menu_Instance:initialise() 
    Winter_Menu_Instance:addToUIManager() 

    MainScreen.instance = Winter_Menu_Instance

    Winter_Controls_Instance = Winter_Controls:new() 
    Winter_Controls_Instance:initialise() 
    Winter_Controls_Instance:addToUIManager() 
    Winter_Controls_Instance:setAlwaysOnTop(true) 
    Winter_Controls_Instance:bringToTop()

    Winter_OtherControls_Instance = Winter_OtherControls:new()
    Winter_OtherControls_Instance:initialise()
    Winter_OtherControls_Instance:addToUIManager()
    Winter_OtherControls_Instance:setAlwaysOnTop(true)
    Winter_OtherControls_Instance:bringToTop()
    
    if NewGameScreen and not NewGameScreen.instance then NewGameScreen.instance = {onResetLua = function(self, reason) end} end
    if ServerSettingsScreen and not ServerSettingsScreen.instance then ServerSettingsScreen.instance = { onResetLua = function(self, reason) end } end
end

--- Replace settings Back button to my Fixed 
local function Winter_onSettingsBack(button)
    local settings = Winter_ScreenManager.getInstance()

    if settings then
        settings:setVisible(false)
        settings:removeFromUIManager()
    end

    Winter_ScreenManager.close("settings", settings)
end

local function Winter_applySettings(settings)
    MainOptions.saveKeys()

    settings.monitorSettings = {}
    settings.monitorSettings.changed = false
    settings.monitorSettings.fullscreen = getCore():isFullScreen()
    settings.monitorSettings.borderless = getCore():getOptionBorderlessWindow()
    settings.monitorSettings.width = getCore():getScreenWidth()
    settings.monitorSettings.height = getCore():getScreenHeight()
    settings.monitorSettings.vsync = getCore():getOptionVSync()
    settings.resetLua = false
    settings.restartRequired = false
    settings.gameOptions:apply()

    for i = 1, #PZAPI.ModOptions.Data do
        local options = PZAPI.ModOptions.Data[i]
        options:apply()
    end

    getCore():saveOptions()
    PZAPI.ModOptions:save()
    settings.gameOptions:toUI()

    if settings.monitorSettings.changed then settings:showConfirmMonitorSettingsDialog(false) return false end
    if settings.restartRequired then settings:showRestartRequiredDialog(false) return false end
    if settings.resetLua and not MainScreen.instance.inGame then getCore():DelayResetLua("default", "optionsChangedApplied") end

    return true
end

local function Winter_onSettingsAccept(button)
    local settings = Winter_ScreenManager.getInstance()
    if settings and Winter_applySettings(settings) then Winter_onSettingsBack(button) end
end

local function Winter_onSettingsSave(button)
    local settings = Winter_ScreenManager.getInstance()
    if settings then Winter_applySettings(settings) end
end

local function Winter_onSettings(button)
    Winter_hideMainControls()

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local settingsWidth = screenWidth * 0.7
    local settingsHeight = screenHeight * 0.8

    local settings = MainOptions:new((screenWidth - settingsWidth) / 2, (screenHeight - settingsHeight) / 2, settingsWidth, settingsHeight)
    settings:initialise() 
    settings:instantiate() 
    settings:create() 
    settings.gameOptions:toUI()
    settings.backgroundColor = {r = 0, g = 0, b = 0, a = 1} 
    settings.backButton:setOnClick(Winter_onSettingsBack)
    settings.acceptButton:setOnClick(Winter_onSettingsAccept)
    settings.saveButton:setOnClick(Winter_onSettingsSave)

    Winter_ScreenManager.open("settings", settings, {onEscape = function(screen) screen.backButton:forceClick() end, onClose = function() Winter_showMainControls() end})
    settings:setVisible(true) 
    settings:addToUIManager()
    settings:setAlwaysOnTop(true)
    settings:bringToTop()
end

local function Winter_onResetLua(reason)
    if reason == "optionsChangedApplied" then Winter_onSettings() return end
    if reason == "continueSave" then MainScreen.continueLatestSaveAux(true) return end
    if reason == "startTutorial" then MainScreen.startTutorial() return end
end

local function Winter_onPrivacy(button)
    local width = 600
    local height = 200

    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local modal = ISTermsOfServiceUI:new(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2, width, height)
    modal:initialise()
    modal:addToUIManager()
    modal:setAlwaysOnTop(true)

    Winter_ScreenManager.open("legal", modal)

    local player = 0
    if player and JoypadState.players[player + 1] then
        modal.prevFocus = JoypadState.players[player + 1].focus
        setJoypadFocus(player, modal)
    else
        local joypadData = JoypadState.getMainMenuJoypad()
        if joypadData then
            modal.prevFocus = joypadData.focus
            joypadData.focus = modal
            updateJoypadFocus(joypadData)
        end
    end
end

local function Winter_onReloadLua(button) 
    Winter_Soundplayer.restartMusic()
    getCore():DelayResetLua("default", "reloadLua") 
end

local function Winter_onQuit(button)
    if isQuitCooldown() then return end
    getCore():quitToDesktop()
end

local function Winter_resizeSettings(oldw, oldh, neww, newh)
    --- FIX LEGAL RESIZE [KAMER]
    if Winter_ScreenManager.getId() == "legal" then return end

    local settings = Winter_ScreenManager.getInstance()
    if not settings then return end

    local width = neww * 0.7
    local height = newh * 0.8

    if neww <= 1024 then
        width = neww * 0.95
        height = newh * 0.95
    end

    settings:setWidth(width)
    settings:setHeight(height)
    settings:setX((neww - width) / 2)
    settings:setY((newh - height) / 2)

    settings:recalcSize()
    settings:onResolutionChange(oldw, oldh, neww, newh)
end

function Winter_Menu:onTermsOfServiceOK()
    self.termsOfServiceDialog = nil

    local modal = Winter_ScreenManager.getInstance()
    Winter_ScreenManager.close("legal", modal)
end

function Winter_Menu:prerender()
    if WinterVideo and WinterVideo:isValid() then WinterVideo:RenderFrame() end
    -- ISPanelJoypad.prerender(self)
end

--- Background
local eight_shades_of_grey = 0.50
function Winter_Menu:render()
    local elapsed = (getTimestampMs() - self.introStartTime) / 1000
    local videoAlpha = 0

    if elapsed > WINTER_INTRO_BLACK_TIME then
        videoAlpha = (elapsed - WINTER_INTRO_BLACK_TIME) / WINTER_INTRO_FADE_TIME
        if videoAlpha > 1 then videoAlpha = 1 end
    end

    self:drawRect(0, 0, self:getWidth(), self:getHeight(), 1, 0, 0, 0)
    if WinterVideo and WinterVideo:isValid() and videoAlpha > 0 then self:drawTextureScaled(WinterVideo, self.videoX, self.videoY, self.videoWidth, self.videoHeight, videoAlpha) end

    -- Permanent darkness layer.
    self:drawRect(0, 0, self:getWidth(), self:getHeight(), eight_shades_of_grey, 0, 0, 0)
end

function Winter_TextButton:render()
    local textManager = getTextManager()

    local textWidth = textManager:MeasureStringX(self.font, self.text)
    local textHeight = textManager:MeasureStringY(self.font, self.text)

    local x
    if self.textAlignLeft then
        x = 10
    else
        x = (self:getWidth() - textWidth) / 2
    end

    local y = (self:getHeight() - textHeight) / 2
    local hovered = self:isMouseOver()
    local color = hovered and self.hoverColor or self.textColor

    local outline = 1
    for ox = -outline, outline do
        for oy = -outline, outline do
            if ox ~= 0 or oy ~= 0 then self:drawText(self.text, x + ox, y + oy, 0, 0, 0, 1, self.font) end
        end
    end

    self:drawText(self.text, x, y, color.r, color.g, color.b, color.a, self.font)
end

function Winter_TextButton:onMouseUp(x, y)
    if self.callback then
        getSoundManager():playUISound(self.sounds.activate)
        self.callback(self)
    end

    return true
end

function Winter_Controls:createChildren()
    local font = UIFont.Small
    local textManager = getTextManager()
    local versionWidth = textManager:MeasureStringX(font, versionText)
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local buttonWidth = screenWidth * 0.094
    local buttonHeight = screenHeight * 0.037
    local spacing = screenHeight * 0.007
    local totalHeight = buttonHeight * 4 + spacing * 3
    local x = (self:getWidth() - buttonWidth) / 2
    local y = (self:getHeight() - totalHeight) / 2 

    self.playButton = Winter_createButton(self, x, y, buttonWidth, buttonHeight, "PLAY", Winter_onPlay)
    self.settingsButton = Winter_createButton(self, x, y + (buttonHeight + spacing), buttonWidth, buttonHeight, "OPTIONS", Winter_onSettings)
    self.modsButton = Winter_createButton(self, x, y + (buttonHeight + spacing)* 2, buttonWidth, buttonHeight, "MODS", Winter_onMods)
    self.quitButton = Winter_createButton(self, x, y + (buttonHeight + spacing) * 3, buttonWidth, buttonHeight, "QUIT", Winter_onQuit)

    self.playButton.font = UIFont.Large
    self.settingsButton.font = UIFont.Large
    self.modsButton.font = UIFont.Large
    self.quitButton.font = UIFont.Large
    
    self.versionLabel = ISLabel:new(x + (buttonWidth - versionWidth) / 2, y + (buttonHeight + spacing) * 4 + 4, 20, versionText, 1, 1, 1, 0.6, font, true)
    self.versionLabel:initialise()
    self:addChild(self.versionLabel)
end

function Winter_OtherControls:createChildren()
    local buttonWidth = self:getWidth()
    local buttonHeight = getCore():getScreenHeight() * 0.0324
    local spacing = getCore():getScreenHeight() * 0.0002

    self.privacyButton = Winter_createButton(self, 0, buttonHeight + spacing, buttonWidth, buttonHeight, "LEGAL", Winter_onPrivacy)
    self.privacyButton.textAlignLeft = true
    self.privacyButton.font = UIFont.Small

    self.reportButton = Winter_createButton(self, 0, (buttonHeight + spacing) * 2, buttonWidth, buttonHeight, "REPORT BUG", Winter_onClickReportBug)
    self.reportButton.textColor = {r = 1, g = 0.2, b = 0.2, a = 1}
    self.reportButton.textAlignLeft = true
    self.reportButton.font = UIFont.Small

    self.reloadLuaButton = Winter_createButton(self, 0, 0, buttonWidth, buttonHeight, "RELOAD LUA", Winter_onReloadLua)
    self.reloadLuaButton.textColor = {r = 0.2, g = 0.8, b = 1, a = 1}
    self.reloadLuaButton.textAlignLeft = true
    self.reloadLuaButton.font = UIFont.Small
end

function Winter_Menu:onKeyRelease(key)
    if key ~= Keyboard.KEY_ESCAPE then return end

    Winter_ScreenManager.escape()
end

function Winter_Controls:onResolutionChange(oldw, oldh, neww, newh)
    self:setWidth(neww)
    self:setHeight(newh)

    local buttonWidth = neww * 0.094
    local buttonHeight = newh * 0.037
    local spacing = newh * 0.007

    local totalHeight = buttonHeight * 4 + spacing * 3

    local x = (neww - buttonWidth) / 2
    local y = (newh - totalHeight) / 2

    self.playButton:setWidth(buttonWidth)
    self.playButton:setHeight(buttonHeight)
    self.playButton:setX(x)
    self.playButton:setY(y)

    self.settingsButton:setWidth(buttonWidth)
    self.settingsButton:setHeight(buttonHeight)
    self.settingsButton:setX(x)
    self.settingsButton:setY(y + buttonHeight + spacing)

    self.modsButton:setWidth(buttonWidth)
    self.modsButton:setHeight(buttonHeight)
    self.modsButton:setX(x)
    self.modsButton:setY(y + (buttonHeight + spacing) * 2)

    self.quitButton:setWidth(buttonWidth)
    self.quitButton:setHeight(buttonHeight)
    self.quitButton:setX(x)
    self.quitButton:setY(y + (buttonHeight + spacing) * 3)

    local font = UIFont.Small
    local textManager = getTextManager()
    local versionWidth = textManager:MeasureStringX(font, versionText)
    self.versionLabel:setX(x + (buttonWidth - versionWidth) / 2)
    self.versionLabel:setY(y + (buttonHeight + spacing) * 4 + 4)
end

function Winter_Menu:onResolutionChange(oldw, oldh, neww, newh)
    self:setWidth(neww)
    self:setHeight(newh)

    local scale = neww / 1920
    self.videoWidth = 1920 * scale
    self.videoHeight = 1080 * scale
    self.videoX = (neww - self.videoWidth) / 2
    self.videoY = (newh - self.videoHeight) / 2
end

function Winter_OtherControls:onResolutionChange(oldw, oldh, neww, newh)
    local buttonHeight = newh * 0.0324
    local spacing = newh * 0.0002

    local width = neww * 0.10
    local height = buttonHeight * 3 + spacing * 2

    local x = 0
    local y = newh - height - 10

    self:setWidth(width)
    self:setHeight(height)
    self:setX(x)
    self:setY(y)

    self.reloadLuaButton:setWidth(width)
    self.reloadLuaButton:setHeight(buttonHeight)
    self.reloadLuaButton:setX(0)
    self.reloadLuaButton:setY(0)

    self.privacyButton:setWidth(width)
    self.privacyButton:setHeight(buttonHeight)
    self.privacyButton:setX(0)
    self.privacyButton:setY(buttonHeight + spacing)

    self.reportButton:setWidth(width)
    self.reportButton:setHeight(buttonHeight)
    self.reportButton:setX(0)
    self.reportButton:setY((buttonHeight + spacing) * 2)

end

function Winter_TextButton:new(x, y, width, height, text, callback)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.text = text
    o.callback = callback
    o.font = UIFont.Medium
    o.textColor = {r = 0.75, g = 0.75, b = 0.75, a = 1}
    o.hoverColor = {r = 1, g = 1, b = 1, a = 1}
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    o.borderColor = {r = 0, g = 0, b = 0, a = 0}
    o.sounds = { activate = "UIActivateButton" }

    return o
end

function Winter_Menu:new(inGame)
    local o = ISPanelJoypad:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    local scale = getCore():getScreenWidth() / 1920
    local getTimestamp = getTimestampMs()
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 1}
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true
    o.inGame = inGame
    o.isWinterMenu = true
    o.videoWidth = 1920 * scale
    o.videoHeight = 1080 * scale
    o.videoX = (o:getWidth() - o.videoWidth) / 2
    o.videoY = (o:getHeight() - o.videoHeight) / 2
    o.introStartTime = getTimestamp

    return o
end

function Winter_Controls:new()
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local o = ISPanelJoypad:new(0, 0, screenWidth, screenHeight)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    o.borderColor = {r = 0, g = 0, b = 0, a = 0}
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true

    return o
end

function Winter_OtherControls:new()
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()

    local buttonHeight = screenHeight * 0.0324
    local spacing = screenHeight * 0.0002

    local width = screenWidth * 0.10
    local height = buttonHeight * 3 + spacing * 2

    local x = 0
    local y = screenHeight - height - 10

    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    o.borderColor = {r = 0, g = 0, b = 0, a = 0}

    return o
end
---------------------------------
--- VANILLA REPLACEMENTS
---------------------------------
local vanillaOnAccept = ModSelector.onAccept
function ModSelector:onAccept()
    vanillaOnAccept(self)

    if self.returnToUI == Winter_Menu_Instance then Winter_ScreenManager.close("mods", self) end
end

Events.OnMainMenuEnter.Remove(LoadMainScreenPanel)
Events.OnMainMenuEnter.Add(Winter_menuLoad)

local function Winter_onResolutionChange(oldw, oldh, neww, newh)
    if Winter_Menu_Instance then Winter_Menu_Instance:onResolutionChange(oldw, oldh, neww, newh) end
    if Winter_Controls_Instance then Winter_Controls_Instance:onResolutionChange(oldw, oldh, neww, newh) end
    if Winter_OtherControls_Instance then Winter_OtherControls_Instance:onResolutionChange(oldw, oldh, neww, newh) end

    Winter_resizeSettings(oldw, oldh, neww, newh)
end

Events.OnResolutionChange.Remove(Winter_onResolutionChange)
Events.OnResolutionChange.Add(Winter_onResolutionChange)

Events.OnResetLua.Remove(MainScreen.onResetLua)
MainScreen.onResetLua = Winter_onResetLua
Events.OnResetLua.Add(MainScreen.onResetLua)