init_x = 30
init_y = 30
max_x = 90
max_y = 90

ball = {
  x = init_x,
  y = init_y
}

dx = 0
dy = 0

function _draw()
  cls(2)
  spr(0, ball.x, ball.y)
end

function _update()
  ball.x += dx
  ball.y += dy

  if ball.x == init_x and ball.y == init_y then 
    dx = 1 
    dy = 0
  end

  if ball.x == max_x and ball.y == init_y  then 
    dx = 0
    dy = 1
  end

  if ball.x == max_x and ball.y == max_y then 
    dx = -1 
    dy = 0
  end

  if ball.x == init_x and ball.y == max_y  then 
    dx = 0
    dy = -1
  end
end