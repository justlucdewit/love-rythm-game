--images
local img_padred
local img_padblue
local img_notered
local img_noteblue
local img_pad

--global values
local notes = {}
local notesize
local levelspeed
local padsize
local missDamage
local health = 100
local levelname = "levels/level1.json"


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
            if note.x < love.mouse.getX()-padsize/2 or note.x > love.mouse.getX()+padsize/2 then
                health = health - missDamage
            end

            table.remove(notes, k)
        end
    end
end

function jsonFile(file)
    local file = io.open(file, "r")
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
end

function love.load()
    --load images
    img_noteblue = love.graphics.newImage("images/note_blue.png")
    img_notered = love.graphics.newImage("images/note_red.png")
    img_padblue = love.graphics.newImage("images/pad_blue.png")
    img_padred = love.graphics.newImage("images/pad_red.png")
    img_pad = img_padred

    --load level
    loadlevel(levelname)
end

function love.draw()
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

    killNotes()
end

function love.keyreleased(key)
    if key=="space" then 
        if img_pad == img_padblue then
            img_pad = img_padred
        else
            img_pad = img_padblue
        end
    end

    if key=="r" then
        notes = {}
        loadlevel(levelname)
        health = 100
    end
end

--helper functions
function constrain(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end