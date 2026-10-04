local Winter_ScreenManager = {}
Winter_ScreenManager.activeId = nil
Winter_ScreenManager.activeInstance = nil
Winter_ScreenManager.activeOnEscape = nil
Winter_ScreenManager.activeOnClose = nil


function Winter_ScreenManager.open(id, instance, options)
    options = options or {}

    Winter_ScreenManager.activeId = id
    Winter_ScreenManager.activeInstance = instance
    Winter_ScreenManager.activeOnEscape = options.onEscape
    Winter_ScreenManager.activeOnClose = options.onClose
end


function Winter_ScreenManager.close(id, instance)
    if id and Winter_ScreenManager.activeId ~= id then return false end
    if instance and Winter_ScreenManager.activeInstance ~= instance then return false end

    local activeInstance = Winter_ScreenManager.activeInstance
    local onClose = Winter_ScreenManager.activeOnClose

    Winter_ScreenManager.activeId = nil
    Winter_ScreenManager.activeInstance = nil
    Winter_ScreenManager.activeOnEscape = nil
    Winter_ScreenManager.activeOnClose = nil

    if onClose then onClose(activeInstance) end

    return true
end


function Winter_ScreenManager.is(id)
    return Winter_ScreenManager.activeId == id
end


function Winter_ScreenManager.getId()
    return Winter_ScreenManager.activeId
end


function Winter_ScreenManager.getInstance()
    return Winter_ScreenManager.activeInstance
end


function Winter_ScreenManager.escape()
    local instance = Winter_ScreenManager.activeInstance
    local onEscape = Winter_ScreenManager.activeOnEscape

    if not instance or not instance:isVisible() then return false end
    if not onEscape then return false end

    onEscape(instance)

    return true
end


return Winter_ScreenManager