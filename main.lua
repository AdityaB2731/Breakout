Window_Width = 1280    --  Setting the value for Window_Width
Window_Height = 720    --  Setting the value for Window_Height
Paddle_Speed = 300     --  Constant Paddle_Speed
Max_Lives = 3          --  Making a global variable to reset the lives after restart of the game
-- AABB Collision function 
function Collision(box1,box2)
    return box1.x<=box2.x+box2.width and
           box2.x<= box1.x + box1.width and
           box1.y<= box2.y + box2.height and
           box1.y + box1.height>= box2.y
end


function love.load()
-- function to load Window_Width and Window_Height
    love.window.setMode(Window_Width,Window_Height)
-- function to set title 
    love.window.setTitle("Breakout")
    Lives = Max_Lives
    Score = 0
    State = 'Menu'
    Background = love.graphics.newImage("Images/background.png")
--[[table for storing brick image(as there a multiple bricks)
    here the table is like an array but the indexing starts from 1 not from 0]]
--[[to load the image in the game we use love.graphics.newImage(filename)
    Filename:- Relative path of the file with the extension
    Relative Path is according to main.lua]]
    Brick_Img = {
      love.graphics.newImage("Images/Brick1.png"),
      love.graphics.newImage("Images/Brick2.png"),
      love.graphics.newImage("Images/Brick3.png")
    }
--[[Table for storing sounds 
    here the we provide the index for eadch element stored in the table
    And index can be anything(i.e index can integer, float, string)]]
--[[to load the sound in the game we use love.audio.newSource(filename,type) as a function
    Filename:- Relative path of the file with the extension
    Relative Path is according to main.lua
    type:- there 2 types of type
          a) static:- which loads the sound in RAM(Random Access Memory)
          b) stream:- which loads the sound in ROM(Read Only Memory)]]
    Sounds = {
      ['Brick_Hit'] = love.audio.newSource("Sounds/brick_hit.wav", 'static'),
      ['Confirm'] = love.audio.newSource("Sounds/confirm.wav", 'static'),
      ['Hurt'] = love.audio.newSource("Sounds/hurt.wav", 'static'),
      ['Paddle_Hit'] = love.audio.newSource("Sounds/paddle_hit.wav", 'static'),
      ['Wall_Hit'] = love.audio.newSource("Sounds/wall_hit.wav", 'static')
    }
end

paddle = {}       -- Table for Paddle
paddle.Img = love.graphics.newImage("Images/Paddle.png")
paddle.x = 700
paddle.y = Window_Height - 100 
paddle.width = paddle.Img:getWidth()
paddle.height = paddle.Img:getHeight()
paddle.xSpeed = 0

ball = {}        -- Table for ball
ball.width = 10
ball.height = 10
ball.y = paddle.y - ball.height
ball.x = paddle.x + paddle.width/2 - ball.width/2
ball.xSpeed = 200
ball.ySpeed = 200

all_bricks = {}  -- Table containing table of Bricks, It is a type of nested table/array

--[[Function to Generate a table of a single brick]]
function BrickGenerater(x,y,level)
  local Brick = {}
  Brick.level = level  -- its is the value which determines that how many times the brick should collide which ball to brick and to set the image of the brick
  Brick.Img = Brick_Img[level] -- takes level as the index and draws the brick according to the brick image table
  Brick.x = x
  Brick.y = y
  Brick.width = 64
  Brick.height = 32
  Brick.inPlay = true
  return Brick
end

--[[Function to generate the arrangement of the bricks]]
function LevelMaker()
  local padding = 100   -- to add space between the bricks and the game window
  local brick_padding = 16 -- to add spaces between the bricks 
  local max_cols = math.floor((Window_Width - padding*2)/(64 + brick_padding)) 
  local rows = 5
  local columns = max_cols
  local start_x = padding
  local start_y = padding
--[[Using for loop to generate the arrangement of the bricks]]
  for i = 0, rows do
--[[randomly generating the level for a row,
    To generate random number we use math.random() function to generate
    math.random(m,n) generates integer number between [m,n] ]]
    local level = math.random(1, 3) 
    for j = 0, columns do
      if (i+j)%2 == 0 then
        --[[table.insert(table_name,value,position)
            table_name: In which table we have to insert the value
            value: data that should be inserted in the table
            position: ion which position should the value be inserted
            postiion argument is optional]]
        table.insert( all_bricks, BrickGenerater(start_x + j*(64 + brick_padding), start_y + i * (32 + brick_padding), level))
      end
    end
  end
end

--[[ function to check if the key is pressed or not]]
function love.keypressed(key)
  if State == 'Menu' and key == 'return' then
    Sounds['Confirm']:play()
    LevelMaker() 
    State = 'Serve'
  end

  if State == 'Serve' and key == 'space' then
    State = 'Play'
  end

  if State == 'End' and key == 'return' then
    Sounds['Confirm']:play()
    all_bricks = {}
    Lives = Max_Lives
    Score = 0
    LevelMaker()
    State = 'Serve'
  end

  if key == "escape" then 
    love.event.quit()
  end
end

function love.update(dt)
  if State == 'Serve' then
    if Lives == 0 then
      State = 'End'
    end
--[[rendering the ball at the center of the paddle]]
    ball.y = paddle.y - ball.height
    ball.x = paddle.x + paddle.width/2 - ball.width/2
    ball.ySpeed = - ball.ySpeed

    if love.keyboard.isDown("left") and paddle.x>=0 then
      paddle.xSpeed = -Paddle_Speed
      paddle.x = paddle.x + paddle.xSpeed*dt
    end
    if love.keyboard.isDown("right") and paddle.x<= Window_Width - paddle.width then
        paddle.xSpeed = Paddle_Speed
        paddle.x = paddle.x + paddle.xSpeed*dt
    end 
  end

  if State == 'Play' then

    --[[# denotes that how many elements are there in the table]]
    if #all_bricks == 0 then
      State = 'End'
    end

    ball.x = ball.x + ball.xSpeed*dt
    ball.y = ball.y + ball.ySpeed*dt

--[[If Statement used to check wheather left key is pressed or not
    and updating the paddle's x component]]
    if love.keyboard.isDown("left") and paddle.x>=0 then
        paddle.xSpeed = -Paddle_Speed
        paddle.x = paddle.x + paddle.xSpeed*dt
    end

--[[If Statement used to check wheather right key is pressed or not
    and updating the paddle's x component]]
    if love.keyboard.isDown("right") and paddle.x<= Window_Width - paddle.width then
        paddle.xSpeed = Paddle_Speed
        paddle.x = paddle.x + paddle.xSpeed*dt
    end 

--[[If..else_if statement to stop ball going out of the game window]]
    if ball.x > Window_Width - ball.width then
        ball.x = Window_Width - ball.width  -- Reset ball position on screen (To avoid glitch)
        ball.xSpeed = -ball.xSpeed
    elseif ball.x<0 then
        ball.x = 0                          -- Reset ball position on screen (To avoid glitch)
        ball.xSpeed = -ball.xSpeed
    elseif ball.y<0 then
        ball.y = 0                          -- Reset ball position on screen (To avoid glitch)
        ball.ySpeed = -ball.ySpeed
    end

    if ball.y > Window_Height then
      Sounds['Hurt']:play()
      Lives = Lives - 1
      State = 'Serve'
    end

--[[if statement to check wheather ball collided with paddle or not]]
    if Collision(paddle,ball) then
        Sounds['Paddle_Hit']:play()
        ball.y = paddle.y - ball.height --Aviod the Giltch of Infinite Collision
        ball.ySpeed = -ball.ySpeed      --Negating the ySpeed of the ball 
        --[[if statement to check is the ball collided with left side of the paddle and if yes changing its xSpeed]]
        if ball.x < paddle.x + paddle.width/2 and paddle.xSpeed<0 then
            ball.xSpeed = -50 + -(8*(paddle.x + paddle.width/2 - ball.x))
        --[[if statement to check is the ball collided with right side of the paddle and if yes changing its xSpeed]]
        elseif ball.x > paddle.x + paddle.width/2 and paddle.xSpeed>0 then
            ball.xSpeed = 50 + (8*math.abs(paddle.x + paddle.width/2 - ball.x))
        end
    end

--[[for key,value in pairs(table_name) do
   end
   It is the for loop mainly used to interate over a nested table
    Here key means the postion of the data and value is the data stored at position]]
    for k,v in pairs(all_bricks) do
        if v.inPlay == true and Collision(v,ball) then
          Sounds['Brick_Hit']:stop()
          Sounds['Brick_Hit']:play()
          if ball.x < v.x and ball.xSpeed > 0 then
            ball.xSpeed = -ball.xSpeed   -- Negating the xSpeed of the ball if collided with the left part of the brick
            ball.x = v.x - ball.width  -- Aviod the Giltch of Infinite Collision
          elseif ball.x + 5 > v.x + v.width then
            ball.xSpeed = -ball.xSpeed   -- Negating the xSpeed of the ball if collided with the right part of the brick
            ball.x = v.x + v.width     -- Aviod the Giltch of Infinite Collision
          elseif ball.y < v.y and ball.ySpeed > 0 then
            ball.ySpeed = -ball.ySpeed  -- Negating the ySpeed of the ball if collided with the top part of the brick
            ball.y = v.y - ball.height  -- Aviod the Giltch of Infinite Collision
          else
            ball.ySpeed = - ball.ySpeed  -- Negating the ySpeed of the ball if collided with the bottom part of the brick
            ball.y = v.y + v.height     -- Aviod the Giltch of Infinite Collision
          end
          Score = Score + 25
          v.level = v.level - 1
          v.Img = Brick_Img[v.level]
          --[[table.remove(table_name,key)
              table_name: from which table the element should be remove
              key: the place of the element in that table]]
          if v.level == 0 then
            table.remove( all_bricks, k)  -- if collision happens then removing the brick from  all_bricks table
          end
        end
      end
    end
end

function love.draw()
--[[Function used to render a rectangle
    Parameter of the function:- 
    Modes:- There are two types of mode "fill" or "line"
    x:- X coordinate of the rectangle
    y:- Y coordinate of the rectangle
    width:- Width of the rectangle
    height:- Height of the rectangle]]

--[[love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy) :- function used to render graphics
    Drawable :- Name of the file that is to be rendered
    x,y:- from where the image should start rendering
    sx,sy:- scaling factor in x,y 
    ox,oy:- offset factoe in x,y]]
    love.graphics.draw(Background, 0, 0, 0, Window_Width/Background:getWidth(), Window_Height/Background:getHeight())

    if State == 'Menu' then
      love.graphics.setFont(love.graphics.newFont("Fonts/font.ttf", 100))
      love.graphics.printf("BREAKOUT", 0, Window_Height/2, Window_Width, 'center')
      love.graphics.printf('PRESS ENTER TO START!', 0, Window_Height/2 + 100, Window_Width, 'center')
    end
    if State == 'Play' or State == 'Serve' then
      love.graphics.setFont(love.graphics.newFont("Fonts/font.ttf", 32))
      love.graphics.draw(paddle.Img, paddle.x, paddle.y)
      love.graphics.rectangle("fill",ball.x,ball.y,ball.width,ball.height)
      for k,v in pairs(all_bricks) do
        love.graphics.draw(v.Img, v.x, v.y)
      end
      love.graphics.print('Lives:'..tostring(Lives), 10,10)
      love.graphics.print("Score: "..tostring(Score), Window_Width - 200,10)
    end
    if State == 'End' then
      love.graphics.setFont(love.graphics.newFont("Fonts/font.ttf", 64))
      love.graphics.printf('FINAL SCORE: '..tostring(Score), 0, Window_Height/2, Window_Width, 'center')
      love.graphics.printf('PRESS ENTER TO RESTART!', 0, Window_Height/2 + 100, Window_Width, 'center')
    end
  end