local complex = require('https://raw.githubusercontent.com/h4rm/luafft/ad71ab4845a09b8ff5db9013f5183f36063b2bbe/src/complex.lua')
local fft = require('https://raw.githubusercontent.com/h4rm/luafft/ad71ab4845a09b8ff5db9013f5183f36063b2bbe/src/luafft.lua').fft

local musicFilename = 'music1.mp3'
local musicSoundData = love.sound.newSoundData(musicFilename)
local musicSource = love.audio.newSource(musicFilename, 'stream')
local musicSampleCount = musicSoundData:getSampleCount()
musicSource:play()

local spectrum -- FFT of window from current position in song, as complex numbers

local NUM_FREQS = 1024
local SAMPLE_RATE = 44100

function love.update()
    local pos = musicSource:tell('samples')
    if pos >= musicSampleCount - 1536 then -- About to end? Rewind.
        love.audio.rewind(musicSource)
    end

    local samples = {} -- Collect samples for window from `pos` as complex numbers
    for i = pos, pos + (NUM_FREQS - 1) do
        if i + 2048 > musicSampleCount then -- Don't spill over end
            i = musicSampleCount / 2
        end
        samples[#samples + 1] = complex.new(musicSoundData:getSample(i * 2), 0)
    end
    spectrum = fft(samples, false) -- Compute FFT of samples
end

function love.draw()
    if #spectrum > 0 then -- Draw FFT graph as a bunch of rectangles
        local wh = love.graphics.getHeight()
        for i = 1, #spectrum / 8 do
            love.graphics.rectangle('line', i * 7, wh, 7, -7 * spectrum[i]:abs())
        end
    end
    love.graphics.print('fps: ' .. love.timer.getFPS(), 2, 2)
end
