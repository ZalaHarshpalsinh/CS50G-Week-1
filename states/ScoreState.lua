ScoreState = Class{__includes = BaseState}

function ScoreState:init()
    self.medals = 
    {
        ['bronze'] = love.graphics.newImage('bronze.png'),
        ['silver'] = love.graphics.newImage('silver.png'),
        ['gold'] = love.graphics.newImage('gold.png'),
    }
end

function ScoreState:enter(params)
    self.score = params.score
    if(self.score <= 2) then 
        self.current_medal = 'bronze'
    elseif (self.score <= 5) then
        self.current_medal = 'silver'
    else
        self.current_medal = 'gold'
    end
    self.medal_width = self.medals[self.current_medal]:getWidth()
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("congratulations! You received " .. self.current_medal .. " medal",0,130,VIRTUAL_WIDTH,'center' )
    love.graphics.draw(self.medals[self.current_medal],VIRTUAL_WIDTH/2 - self.medal_width/2, 150)
    love.graphics.printf('Press Enter to Play Again!', 0, 250, VIRTUAL_WIDTH, 'center')
end