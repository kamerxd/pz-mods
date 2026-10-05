local Winter_Soundplayer = {} 
Winter_Soundplayer.SoundManager = nil
Winter_Soundplayer.CurrentSong = nil
Winter_Soundplayer.Volume = 0
Winter_Soundplayer.Music = FMODSoundEmitter:new()

function Winter_Soundplayer.backgroundMusic()
    Winter_Soundplayer.CurrentSong = Winter_Soundplayer.Music:playSound("KamerWinter1", true)
    Winter_Soundplayer.Volume = getCore():getOptionMusicVolume() / 10.0
    Winter_Soundplayer.Music:setVolume(Winter_Soundplayer.CurrentSong, Winter_Soundplayer.Volume)
end

function Winter_Soundplayer.init()
    Winter_Soundplayer.SoundManager = getSoundManager()
    Winter_Soundplayer.SoundManager:setMusicState("Loading")
    Winter_Soundplayer.backgroundMusic()
    
    Events.OnFETick.Add(Winter_Soundplayer.stopMainMusic)
end

local stopMainMusic_Ticks = 0
function Winter_Soundplayer.stopMainMusic()
    Winter_Soundplayer.SoundManager:setMusicVolume(0)
    Winter_Soundplayer.Music:tick()
    stopMainMusic_Ticks = stopMainMusic_Ticks + 1

    if stopMainMusic_Ticks >= 5 then
        stopMainMusic_Ticks = 0

        if not Winter_Soundplayer.Music:isPlaying(Winter_Soundplayer.CurrentSong) then Winter_Soundplayer.backgroundMusic() return end

        local currentVolume = getCore():getOptionMusicVolume() / 10.0
        if Winter_Soundplayer.Volume ~= currentVolume then
            Winter_Soundplayer.Volume = currentVolume
            Winter_Soundplayer.Music:setVolume(Winter_Soundplayer.CurrentSong, Winter_Soundplayer.Volume)
        end
    end
end

function Winter_Soundplayer.restartMusic()
    if Winter_Soundplayer.CurrentSong then
        Winter_Soundplayer.Music:stopSoundByName("KamerWinter1")

        Winter_Soundplayer.CurrentSong = nil
    end
end

return Winter_Soundplayer

