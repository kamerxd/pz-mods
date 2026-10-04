local Winter_Soundplayer = require "Kamer_Winter_Menu/Winter_Soundplayer"

function MainOptions:onRestartRequiredClick(button, closeAfter)
	if closeAfter then
		self:close()
	end

	if self.resetLua and not MainScreen.instance.inGame then
        Winter_Soundplayer.restartMusic()
		getCore():DelayResetLua("default", closeAfter and "optionsChangedAccepted" or "optionsChangedApplied")
	end
end

function MainOptions:apply(closeAfter)
	MainOptions.saveKeys();

	self.monitorSettings = {}
	self.monitorSettings.changed = false
	self.monitorSettings.fullscreen = getCore():isFullScreen()
	self.monitorSettings.borderless = getCore():getOptionBorderlessWindow()
	self.monitorSettings.width = getCore():getScreenWidth()
	self.monitorSettings.height = getCore():getScreenHeight()
	self.monitorSettings.vsync = getCore():getOptionVSync()

	self.resetLua = false
	self.restartRequired = false

	self.gameOptions:apply()
	for _, options in ipairs(PZAPI.ModOptions.Data) do
		options:apply()
	end

	getCore():saveOptions()
	PZAPI.ModOptions:save()

	self.gameOptions:toUI()

	if self.monitorSettings.changed then
		self:showConfirmMonitorSettingsDialog(closeAfter)
		return false
	end

	if self.restartRequired then
		self:showRestartRequiredDialog(closeAfter)
		return false
	end

	if closeAfter then
		self:close()
	end

	if self.resetLua and not MainScreen.instance.inGame then
        Winter_Soundplayer.restartMusic()
		getCore():DelayResetLua("default", closeAfter and "optionsChangedAccepted" or "optionsChangedApplied")
	end
end

function MainOptions:onConfirmMonitorSettingsClick(button, closeAfter)
	self.tabs:setVisible(true)
	self.backButton:setVisible(true)
	self.acceptButton:setVisible(true)
	self.saveButton:setVisible(true)
	self.modal = nil
	if button.internal == "YES" then
	else
		getCore():setOptionBorderlessWindow(self.monitorSettings.borderless)
		getCore():setResolutionAndFullScreen(self.monitorSettings.width, self.monitorSettings.height,
			self.monitorSettings.fullscreen)
		getCore():setOptionVSync(self.monitorSettings.vsync)
		self:toUI()
		getCore():saveOptions()
	end
	if closeAfter then
		self:close()
	end

    if not MainScreen.instance.inGame then
        Winter_Soundplayer.restartMusic()
        getCore():DelayResetLua("default", closeAfter and "optionsChangedAccepted" or "optionsChangedApplied")
    end
end

function ModSelector.Model:acceptChanges()
    self:saveModDataToFile()

    local activeMods = self:getActiveMods()
    -- Remove mod IDs for missing mods from ActiveMods.mods
    activeMods:checkMissingMods()
    -- Remove unused map directories from ActiveMods.mapOrder
    activeMods:checkMissingMaps()

    if self.loadGameFolder then
        local saveFolder = self.loadGameFolder
        self.loadGameFolder = nil
        manipulateSavefile(saveFolder, "WriteModsDotTxt")

        -- Setting 'currentGame' to 'default' in case other places forget to set it
        -- before starting a game (DebugScenarios.lua, etc).
        local defaultMods = ActiveMods.getById("default")
        local currentMods = ActiveMods.getById("currentGame")
        currentMods:copyFrom(defaultMods)

        LoadGameScreen.instance:onSavefileModsChanged(saveFolder)
        LoadGameScreen.instance:setVisible(true, self.joyfocus)
        return
    end

    if self.isNewGame then
        NewGameScreen.instance:setVisible(true, self.joyfocus)
    elseif self.isServerSettingsMods then
        local result = {}
        local mods = activeMods:getMods()
        for i = 0, mods:size()-1 do
            local id = mods:get(i)
            local info = self.mods[id].modInfo
            table.insert(result, {modID = id, modInfo = info})
        end
        self.serverSettingsFinishFunc(result)
        self.isServerSettingsMods = false
        return
    else
        saveModsFile()

        -- Setting 'currentGame' to 'default' in case other places forget to set it
        -- before starting a game (DebugScenarios.lua, etc).
        local defaultMods = ActiveMods.getById("default")
        local currentMods = ActiveMods.getById("currentGame")
        currentMods:copyFrom(defaultMods)

    end

    local reset = self.ModsEnabled ~= getCore():getOptionModsEnabled()
    if ActiveMods.requiresResetLua(activeMods) then
        reset = true
    end
    if reset then
        if self.isNewGame then
			Winter_Soundplayer.restartMusic()
            getCore():ResetLua("currentGame", "NewGameMods")
        else
			Winter_Soundplayer.restartMusic()
            getCore():ResetLua("default", "modsChanged")
        end
    end
end