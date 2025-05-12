speed = 3

greenX = 100
greenY = 54
greenW = 8
greenH = 8
greenDx = 0
greenDy = 0

blueX = 50
blueY = 50
blueW = 16
blueH = 16
blueC = 12

function _update()
  if btn(0) then 
    greenDx = -speed
  end
  if btn(1) then
    greenDx = speed
  end

  if not (btn(0) or btn(1)) then
    greenDx = 0
  end

  if not (greenDx == 0) then
    if isCollidingOnLeft(greenX, greenY, greenDx, greenW, greenH, blueX, blueY, blueW, blueH) then
      greenDx = 0
    end
    if isCollidingOnRight(greenX, greenY, greenDx, greenW, greenH, blueX, blueY, blueW, blueH) then
      greenDx = 0
    end
  end

  -- if btn(1) and not isCollidingOnRight(greenX, greenY, greenDx, greenW, greenH, blueX, blueY, blueW, blueH) then 
  --   greenDx = speed
  -- end

  -- if btn(2) then
  --   for newAy = ay, ay - ady, -1 do 
  --     if not isCollisionBoxOverlapping(ax, newAy, aw, ah, bx, by, bw, bh) then
  --       ay = newAy   
  --     end
  --   end
  -- end
  -- if btn(3) then
  --   for newAy = ay, ay + ady do 
  --     if not isCollisionBoxOverlapping(ax, newAy, aw, ah, bx, by, bw, bh) then
  --       ay = newAy   
  --     end
  --   end
  -- end
  
  greenX += greenDx

end

function _draw()
  cls()
  rect(greenX, greenY, greenX+greenW, greenY+greenH, 11)
  rect(blueX, blueY, blueX+blueW, blueY+blueH, blueC)
end

function isCollisionBoxOverlapping(ax, ay, aw, ah, bx, by, bw, bh)
  return (
    ax + aw >= bx and
    ax <= bx + bw and
    ay + ah >= by and
    ay <= by + bh
  )
end

function isCollidingOnRight(ax, ay, adx, aw, ah, bx, by, bw, bh)
  local finalAx = ax
  for newAx = ax, ax + adx do
    if not isCollisionBoxOverlapping(newAx, ay, aw, ah, bx, by, bw, bh) then
      finalAx = newAx
    end
  end
  return finalAx == ax
end

function isCollidingOnLeft(ax, ay, adx, aw, ah, bx, by, bw, bh)
  local finalAx = ax
  for newAx = ax, ax - abs(adx), -1 do
    if not isCollisionBoxOverlapping(newAx, ay, aw, ah, bx, by, bw, bh) then
      finalAx = newAx
    end
  end
  return finalAx == ax
end