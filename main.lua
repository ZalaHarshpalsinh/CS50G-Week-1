-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

require 'StateMachine'

require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('resources/images/background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('resources/images/ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Fifty Bird')

    smallFont = love.graphics.newFont('recources/fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('recources/fonts/flappy.ttf', 14)
    flappyFont = love.graphics.newFont('recources/fonts/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('recources/fonts/flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    sounds = {
        ['jump'] = love.audio.newSource('recources/audio/jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('recources/audio/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('recources/audio/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('recources/audio/score.wav', 'static'),

        ['music'] = love.audio.newSource('recources/audio/marios_way.mp3', 'static')
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

    love.keyboard.keysPressed = {}

    love.mouse.buttonsPressed = {}

    pause = false;
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end


function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    if (love.keyboard.wasPressed('p')) then
        pause = not pause
        if(pause) then
            sounds['music']:pause()
        else
            sounds['music']:play()
        end
    end
    if(not pause) then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
        gStateMachine:update(dt)
    end
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.draw()
    push:start()

    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    if(pause)then
        love.graphics.setFont(hugeFont)
        love.graphics.printf("Pause",0,VIRTUAL_HEIGHT/2 - 60, VIRTUAL_WIDTH,'center')
        love.graphics.setFont(flappyFont)
        love.graphics.printf("Press P to resume",0,VIRTUAL_HEIGHT/2 , VIRTUAL_WIDTH,'center')
    end
    push:finish()
end
