-- note[time stamp, position, color]

--images
local img_padred
local img_padblue
local img_notered
local img_noteblue
local img_pad
local padcol

--global values
local notes = {}
local notesize
local levelspeed
local padsize
local missDamage
local songaudio
local songlength
local health = 100
local levelname = "unity"


function createNote(position, height, red)
    local col
    if red then
        col = "red"
    else
        col = "blue"
    end
    
    table.insert(notes, {x=position, y=height, dx=0, dy=levelspeed, color=col})
end

function drawNotes()
    for k, note in pairs(notes) do
        if note.y > 0 and note.y < love.graphics.getHeight() then
            if note.color == "red" then
                love.graphics.draw(img_notered, note.x, note.y, math.pi/2, notesize/31, notesize/31)
            else
                love.graphics.draw(img_noteblue, note.x, note.y, math.pi/2, notesize/31, notesize/31)
            end
        end
    end     
end

function updateNotes()
    for k, note in pairs(notes) do
        note.y = note.y + note.dy
        note.x = note.x + note.dx
    end
end

function killNotes()
    for k, note in pairs(notes) do
        if note.y > love.graphics.getHeight() then
            if note.x < love.mouse.getX()-padsize/2 or note.x > love.mouse.getX()+padsize/2 or note.color ~= padcol then
                health = health - missDamage
            end

            table.remove(notes, k)
        end
    end
end

function jsonFile(file)
    local file = io.open("levels/"..file.."/notes.json", "r")
    local content = file:read("*a")
    file:close()
    return content
end

function love.conf(t)
    t.title = "catch rythm game"
    t.version= "1.0.1"
    t.console= true
end

function loadlevel(filename)
    songaudio = love.audio.newSource("levels/"..filename.."/song.mp3", "stream")
    songlength = songaudio:getDuration("seconds")
    local json = require "json"
    level = json.decode(jsonFile(levelname))
    
    levelspeed = level.speed
    padsize = level.padsize
    notesize = level.noteSize
    missDamage = level.damage

    for k, note in pairs(level.notes) do
        local red = false
        note[2] = note[2]/100*love.graphics.getWidth()
        note[1] = -note[1]*500
        if note[3] == 1 then
            red = true
        end
        createNote(note[2], note[1], red)
    end

    songaudio:play()
end

function love.load()
    --load images
    img_noteblue = love.graphics.newImage("images/note_blue.png")
    img_notered = love.graphics.newImage("images/note_red.png")
    img_padblue = love.graphics.newImage("images/pad_blue.png")
    img_padred = love.graphics.newImage("images/pad_red.png")
    img_pad = img_padred
    padcol = "red"

    --load level
    loadlevel(levelname)
end

function love.draw()
    --check keyboard input
    checkkeys()
    
    --draw background
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 0)

    --draw paddle
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(img_pad, constrain(love.mouse.getX()-padsize/2, 0, love.graphics.getWidth()-padsize), love.graphics.getHeight()-20, 0, padsize/85, 1)

    --draw notes
    drawNotes()
    updateNotes()

    --draw health
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 25, 25, (love.graphics.getWidth()-50)/100*health, 10)

    --draw debugging
    love.graphics.print(songaudio:tell("seconds")/songlength*100, 200, 10)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)

    killNotes()
end

function love.keypressed(key)
    if key=="r" then
        songaudio:stop()
        notes = {}
        loadlevel(levelname)
        health = 100
    end
end

function checkkeys()
    if love.keyboard.isDown("z") then
        if img_pad == img_padblue then
            img_pad = img_padred
            padcol = "red"
        end
    else
        img_pad = img_padblue
        padcol = "blue"

    end
end

--helper functions
function constrain(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end