levelNum = 1
levels = {
  "///BBBBBBBBBBB/BBIBBEBBIBB/EHHHHHHHHHE",
  "//HHHHHHHHH/XXHHHHHHHXX/XXHHHHHHHXX/HHHHHHHHH///XXBBBBBXX/XXBBBBBBBBXX/BBBBBBBBBBB/XXIIIIIIXX/",
}

function _init()
  cls()
  mode = "start"
  printh('---')
end

function initGame()
  mode = "game"
  level = levels[levelNum]

  gameFrame = {
    x0 = 1,
    y0 = 13,
    x1 = 126,
    y1 = 127
  }
  
  paddle = {
    x = 52,
    dx = 0,
    dxMax = 1.5,
    a = 1.15,
    w = 24,
    h = 2,
    color = 7
  }
  paddle["y"] = gameFrame.y1 - paddle.h

  combo = 0
  bricksDestroyed = 0
  indestructibleBricks = 0

  initBall()

  initBricks(gameFrame.x0 + 3, gameFrame.y0 + 3, 9, 4)
end

function initBall()
  ball = {
    x = paddle.x + paddle.w / 2,
    dxMax = 1,
    dyMax = 1,
    r = 2,
    angle = 1,
    color = 6,
    sticky = true,
  }
  ball.dx = ball.dxMax
  ball.dy = ball.dyMax
  ball.y = paddle.y - ball.r - 2
end

-- ===========================
-- Brick Functions
-- ===========================

function initBricks(x, y, w, h)
  bricks = {}
  local n = 0
  local row = 0
  local col = 0

  for i = 0, #level do
    local b = sub(level, i+1, i+1)

    if b == "X" then
      col += 1
    elseif b == "/" then
      col = 0
      row += 1
    else 
      if b == "B" then
        bricks[n] = createBrick(
          x + (col * (w + 2)), 
          y + (row * (h + 2)), 
          w, h
        )
      elseif b == "H" then
        bricks[n] = createHardBrick(
          x + (col * (w + 2)), 
          y + (row * (h + 2)), 
          w, h
        )
      elseif b == "I" then
        indestructibleBricks += 1
        bricks[n] = createIndestructibleBrick(
          x + (col * (w + 2)), 
          y + (row * (h + 2)), 
          w, h
        )
      elseif b == "E" then
        bricks[n] = createExplodingBrick(
          x + (col * (w + 2)), 
          y + (row * (h + 2)), 
          w, h
        )
      end
      col += 1
      n += 1
    end
  end
end

Brick = {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  color = 0,
  hp = 1,
  show = true,
  onHit = function(self, playSound, continueCombo)
    if playSound then
      sfx(3 + min(combo, 7))
    end
    if continueCombo then
      combo += 1
    end
    score += 30 * combo
    self.show = false
    bricksDestroyed += 1
  end
}

function Brick:New(obj)
  obj = obj or {}
  setmetatable(obj, {__index = self})
  return obj
end

function createBrick(x, y, w, h)
  return Brick:New({
    x = x,
    y = y,
    w = w,
    h = h,
    color = 13,
  })
end

function createHardBrick(x, y, w, h)
  return Brick:New({
    x = x,
    y = y,
    w = w,
    h = h,
    hp = 2,
    color = 2,
    onHit = function(self, playSound, continueCombo)
      if playSound then
        sfx(3 + min(combo, 7))
      end
      self.hp -= 1
      self.color = 13
      if self.hp <= 0 then
        self.show = false
        if continueCombo then
          combo += 1
        end
        score += 30 * combo
        bricksDestroyed += 1
      end
    end
  })
end

function createIndestructibleBrick(x, y, w, h)
  return Brick:New({
    x = x,
    y = y,
    w = w,
    h = h,
    color = 5,
    onHit = function(self, playSound)
      if playSound then
        sfx(0)
      end
    end
  })
end

function createExplodingBrick(x, y, w, h)
  return Brick:New({
    x = x,
    y = y,
    w = w,
    h = h,
    color = 9,
    onHit = function(self, playSound, continueCombo)
      if playSound then
        sfx(18)
      end

      self.show = false
      if continueCombo then
        combo += 1
      end

      score += 30 * combo
      bricksDestroyed += 1

      for i = 0, #bricks do
        local brick = bricks[i]
        if brick.show then
          local adjacentX = abs(brick.x - self.x) <= (brick.w + 2)
          local adjacentY = abs(brick.y - self.y) <= (brick.h + 2)
          if adjacentX and adjacentY then
            brick:onHit(false, false)
          end
        end
      end
    end
  })
end

-- ===========================
-- Update Functions
-- ===========================

function _update60()
  if mode == "start" then
    updateStart()
  elseif mode == "game" then
    updateGame()
  elseif mode == "gameover" then
    updateGameOver()
  elseif mode == "levelover" then
    updateLevelOver()
  end
end

function updateStart()
  if btnp(5) then
    lives = 3
    score = 0
    initGame()
  end
end

function updateGameOver()
  if btnp(5) then
    mode = "start"
  end
end

function updateLevelOver()
  if btnp(5) then
    levelNum = min(levelNum + 1, #levels)
    initGame()
  end
end

function updateGame()
  if bricksDestroyed == (#bricks + 1 - indestructibleBricks) then
    mode = "levelover"
    return
  end

  if lives == 0 then
    mode = "gameover"
    return
  end

  -- Paddle Buttons
  if btn(0) then
    paddle.dx = -paddle.dxMax
    if ball.sticky then
      ball.dx = -ball.dxMax
    end
  end
  if btn(1) then
    paddle.dx = paddle.dxMax
    if ball.sticky then
      ball.dx = ball.dxMax
    end
  end
  if btnp(5) and ball.sticky then
    ball.sticky = false
  end

  -- Paddle Deceleration
  if not (btn(0) or btn(1)) then
    paddle.dx /= paddle.a
  end

  -- Paddle Movement
  paddle.x += paddle.dx

  -- Restrict Paddle to Game Frame
  paddle.x = mid(gameFrame.x0, paddle.x, gameFrame.x1 - paddle.w)

  -- Stick Ball to Paddle
  if ball.sticky then
    ball.x = paddle.x + paddle.w / 2
    return
  end

  -- Ball Collision with Game Frame
  if ball.x + ball.r >= gameFrame.x1 or ball.x - ball.r <= gameFrame.x0 then
    sfx(0)
    ball.dx = -ball.dx
  end
  if ball.y - ball.r <= gameFrame.y0 or ball.y + ball.r >= gameFrame.y1 then
    sfx(0)
    ball.dy = -ball.dy
  end
  if ball.y + ball.r >= gameFrame.y1 then
    sfx(2)
    lives -= 1
    if lives == 0 then return end
    initBall()
    return
  end

  -- Ball Collision with Paddle
  local paddleCollision = checkCollisionDirection(
    ball.x - ball.r, ball.y - ball.r, 
    ball.r * 2, ball.r * 2, 
    ball.dx, ball.dy, 
    paddle.x, paddle.y, 
    paddle.w, paddle.h
  )

  -- Ball Collision with Brick
  local brickCollision = nil
  for i = 0, #bricks do
    local brick = bricks[i]
    if brick.show then
      local collision = checkCollisionDirection(
        ball.x - ball.r, ball.y - ball.r, 
        ball.r * 2, ball.r * 2, 
        ball.dx, ball.dy, 
        brick.x, brick.y, 
        brick.w, brick.h
      )
      if collision and not brickCollision then
        brickCollision = collision
      end
      if collision then
        brick:onHit(true, true)
      end
    end
  end

  -- Check Entity Ball Collided With
  local collision = nil
  if paddleCollision then
    sfx(1)
    score += 10
    combo = 0
    collision = paddleCollision

    if not (abs(paddle.dx) < 0) then
      if sgn(paddle.dx) != sgn(ball.dx) then
        --setBallAngle(min(2, ball.angle + 1))
        ball.dx = -ball.dx
      elseif sgn(paddle.dx) == sgn(ball.dx) then
        --setBallAngle(max(0, ball.angle - 1))
      end
    end
  elseif brickCollision then
    collision = brickCollision
  end

  -- Calculate next ball position
  local nextX = ball.x + ball.dx
  local nextY = ball.y + ball.dy
  
  -- Change Ball Direction on Collision
  if collision then
    -- The next available coords where there is no collision
    nextX = collision.nextX + ((ball.r + 1) * -sgn(ball.dx))
    nextY = collision.nextY + ((ball.r + 1) * -sgn(ball.dy))
    nextX = mid(gameFrame.x0 + ball.r, nextX, gameFrame.x1 - ball.r)
    nextY = mid(gameFrame.y0 + ball.r, nextY, gameFrame.y1 - ball.r)

    if collision.side == "both" then
      ball.dx = -ball.dx
      ball.dy = -ball.dy
      ball.x = nextX
      ball.y = nextY
    elseif collision.side == "vertical" then
      ball.dy = -ball.dy
      ball.y = nextY
    elseif collision.side == "horizontal" then
      ball.dx = -ball.dx
      ball.x = nextX
    end
  else
    ball.x = mid(gameFrame.x0 + ball.r, nextX, gameFrame.x1 - ball.r)
    ball.y = mid(gameFrame.y0 + ball.r, nextY, gameFrame.y1 - ball.r)
  end
end

-- ===========================
-- Draw Functions
-- ===========================

function _draw()
  if mode == "start" then
    drawStart()
  elseif mode == "game" then
    drawGame()
  elseif mode == "gameover" then
    drawGameOver()
  elseif mode == "levelover" then
    drawLevelOver()
  end
end

function drawStart()
  cls(7)
  rectfill(1, 1, 126, 126, 0)
  print("breakout", 48, 50, 12)
  print("press ❎ to start", 32, 60, 5)
end

function drawGameOver()
  rectfill(gameFrame.x0 + 20, 44, gameFrame.x1 - 20, 70, 5)
  print("gameover", 48, 50, 8)
  print("press ❎ to restart", 27, 60, 6)
end

function drawLevelOver()
  rectfill(gameFrame.x0 + 20, 44, gameFrame.x1 - 20, 70, 5)
  print("level complete!", 36, 50, 11)
  print("press ❎ to continue", 24, 60, 6)
end

function drawGame()
  cls(7)
  print("score:"..score, 1, 1, 0)
  print("level:"..levelNum, 100, 1, 0)
  print("lives:"..lives, 100, 7, 0)
  print("combo:"..combo, 1, 7, 0)
  rectfill(gameFrame.x0, gameFrame.y0, gameFrame.x1, gameFrame.y1, 0)
  rectfill(paddle.x, paddle.y, paddle.x + paddle.w, paddle.y + paddle.h, paddle.color)

  for i = 0, #bricks do
    local brick = bricks[i]
    if brick.show then
      rectfill(brick.x, brick.y, brick.x + brick.w, brick.y + brick.h, brick.color)
    end
  end

  if ball.sticky then
    line(
      ball.x + ball.dx * 4, 
      ball.y - ball.dy * 4, 
      ball.x + ball.dx * 8, 
      ball.y - ball.dy * 8, 
      ball.color
    )
  end
  circfill(ball.x, ball.y, ball.r, ball.color)
end

-- ===========================
-- Helper Functions
-- ===========================

function isCollisionBoxOverlapping(ax, ay, aw, ah, bx, by, bw, bh)
  if ay > by + bh then return false end -- Top of A is outside of bottom of B
  if ay + ah < by then return false end -- Bottom of A is outside of top of B
  if ax > bx + bw then return false end -- Right of A is outside of left of B
  if ax + aw < bx then return false end -- Left of A is outside of right of B
  return true
end

-- Finds a collision along the line of travel 
function checkCollisionDirection(ax, ay, aw, ah, speedX, speedY, bx, by, bw, bh)
  local horizontalCollision = false
  local verticalCollision = false
  local nextAx = ax + speedX
  local nextAy = ay + speedY

  for newAx = ax, ax + speedX, sgn(speedX) do
    if isCollisionBoxOverlapping(newAx, ay, aw, ah, bx, by, bw, bh) then
      horizontalCollision = true
      nextAx = newAx
      break
    end
  end

  for newAy = ay, ay + speedY, sgn(speedY) do
    if isCollisionBoxOverlapping(ax, newAy, aw, ah, bx, by, bw, bh) then
      verticalCollision = true
      nextAy = newAy
      break
    end
  end

  if horizontalCollision and verticalCollision then
    return { side="both", nextX=nextAx, nextY=nextAy }
  elseif verticalCollision then
    return { side="vertical", nextX=nextAx, nextY=nextAy }
  elseif horizontalCollision then
    return { side="horizontal", nextX=nextAx, nextY=nextAy }
  else
    return nil
  end
end

function setBallAngle(ang)
  ball.angle = ang
  if ang == 2 then
    ball.dx = 0.5 * sgn(ball.dx)
    ball.dy = 1.5 * sgn(ball.dy)  
  elseif ang == 0 then
    ball.dx = 1.5 * sgn(ball.dx)
    ball.dy = 0.5 * sgn(ball.dy) 
  else
   ball.dx = 1 * sgn(ball.dx)
    ball.dy = 1 * sgn(ball.dy)
  end
end