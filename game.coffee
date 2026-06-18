# ============================================================
#  BOUNCY BUNNY - LEARNING VERSION
#  Fill in the code to make the game work!
#  Look for "YOUR CODE HERE" sections
# ============================================================

# --- Canvas size (don't change these) ---
W = 480
H = 640

# ============================================================
# CHALLENGE 1: Set up the game constants!
# ============================================================

# Where does the bunny start? (left side of screen)
BUNNY_X = 100

# How big is the bunny circle?
# Try a number between 15 and 30
BUNNY_SIZE = 20

# How fast does the bunny fall?
# Try a number between 0.3 and 0.8
# Bigger number = falls faster!
GRAVITY = 0.5
# How strong is a flap/jump?
# Try a number between 7 and 12
# Bigger number = jumps higher!
FLAP_POWER = 8

# How fast do walls move toward the bunny?
# Try a number between 2 and 5
WALL_SPEED = 4

# How wide are the walls?
WALL_WIDTH = 60

# How big is the gap between top and bottom walls?
# Try a number between 150 and 220
# Smaller gap = harder game!
GAP_SIZE = 165

# How often do new walls appear? (in frames)
# 60 frames = about 1 second
SPAWN_TIME = 100

# How often do powerups appear? (every N walls)
POWERUP_EVERY = 15

# How many points for collecting a carrot?
CARROT_POINTS = 10

# How many coins do you earn per carrot?
CARROT_COINS = 3

CARROT_WIDTH = 10

CARROT_HEIGHT = 30
# ============================================================
# SKIN COLORS - Change these to any colors you like!
# ============================================================

# ============================================================
# BUILT-IN CHARACTER DRAWING FUNCTIONS
# ============================================================


# ============================================================
# CSS PIXEL ART LOADER
# Drop .css files from pixelart-to-css.com in the skins/ folder,
# then add a line to SKIN_FILES below to use them!
# ============================================================


# Pokeball - drawn with canvas shapes (clean circle is better than pixel art)
drawPokeball = (cx, cy, size = 40) ->
  r = size / 2 - 1

  # Top half (red) 
  ctx.fillStyle = '#EE1515'
  ctx.beginPath()
  ctx.arc cx, cy, r, Math.PI, 0
  ctx.fill()

  # Bottom half (white)
  ctx.fillStyle = '#FFFFFF'
  ctx.beginPath()
  ctx.arc cx, cy, r, 0, Math.PI
  ctx.fill()

  # Black outline
  ctx.strokeStyle = 'black'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.arc cx, cy, r, 0, Math.PI * 2
  ctx.stroke()

  # Horizontal black band
  ctx.beginPath()
  ctx.stroke()

  # Center button (white circle with black outline)
  ctx.fillStyle = '#FFFFFF'
  ctx.beginPath()
  ctx.arc cx, cy, r * 0.25, 0, Math.PI * 2
  ctx.fill()
  ctx.stroke()

  # Inner button dot
  ctx.fillStyle = 'black'
  ctx.beginPath()
  ctx.arc cx, cy, r * 0.1, 0, Math.PI * 2
  ctx.fill()


# Pacman - yellow circle with a wedge mouth
drawPacman = (cx, cy, size = 40) ->
  r = size / 2 - 1

  # Yellow body with mouth wedge cut out
  # The mouth opens to the right (between angles 0.2*PI and -0.2*PI)
  ctx.fillStyle = '#FFD700'
  ctx.beginPath()
  ctx.moveTo cx, cy
  ctx.arc cx, cy, r, 0.2 * Math.PI, -0.2 * Math.PI
  ctx.closePath()
  ctx.fill()

  # Black outline
  ctx.strokeStyle = 'black'
  ctx.lineWidth = 2
  ctx.stroke()

  # Eye (small black dot in the upper part)
  ctx.fillStyle = 'black'
  ctx.beginPath()
  ctx.arc cx, cy - r * 0.5, r * 0.13, 0, Math.PI * 2
  ctx.fill()


SKINS = [
  { name: 'circle',    color: '#FFFFFF' }
  { name: 'Pokeball', color: '#EE1515', draw: drawPokeball }
  { name: 'Pacman',   color: '#FFD700', draw: drawPacman }
]
SKIN_COST = [0, 25, 75]

SKIN_FILES = [
  {name: 'bunny',      file: 'skins/bunny.css',      cost: 0 }
  { name: 'Mushroom',  file: 'skins/mushroom.css',   cost: 100 }
  { name: 'Yoshi Egg', file: 'skins/yoshi-egg.css',  cost: 100 }
  { name: 'Hammer',    file: 'skins/hammer.css',     cost: 100}
  { name: 'BoxerDude', file: 'skins/boxer-dude.css', cost: 135 }
  { name: 'Charizard', file: 'skins/charizard.css',  cost: 175 }
  { name: 'Goomba',    file: 'skins/goomba.css',     cost: 185 }
  { name: 'Ditto',     file: 'skins/ditto.css',      cost: 200 }
  { name: 'Meltan',    file: 'skins/meltan.css',     cost: 250 }
  { name: 'Bulbasaur', file: 'skins/bulbasaur.css',  cost: 300 }
]

# Parse pixelart-to-css.com CSS into a grid of colors
parseCssPixelArt = (cssText) ->
  cellSize = parseInt(cssText.match(/width:\s*(\d+)px/)?[1] or '13')
  pattern = /(\d+)px\s+(\d+)px\s+0\s+0\s+rgba?\(([^)]+)\)/g
  pixels = {}
  minX = minY = Infinity
  maxX = maxY = -Infinity
  while (match = pattern.exec(cssText))
    x = parseInt(match[1])
    y = parseInt(match[2])
    [r, g, b] = match[3].split(',').slice(0, 3).map (s) -> parseInt(s.trim())
    pixels["#{x},#{y}"] = "rgb(#{r},#{g},#{b})"
    minX = Math.min(minX, x); maxX = Math.max(maxX, x)
    minY = Math.min(minY, y); maxY = Math.max(maxY, y)
  cols = (maxX - minX) / cellSize + 1
  rows = (maxY - minY) / cellSize + 1
  grid = []
  for r in [0...rows]
    row = []
    for c in [0...cols]
      row.push pixels["#{minX + c * cellSize},#{minY + r * cellSize}"] or null
    grid.push row
  { grid, cols, rows }

# Draw a parsed pixel art grid centered at (cx, cy)
drawCssPixelArt = (cx, cy, size, data) ->
  return unless data
  maxDim = Math.max(data.rows, data.cols)
  pixelSize = size / maxDim
  startX = cx - (data.cols * pixelSize) / 2
  startY = cy - (data.rows * pixelSize) / 2
  for r in [0...data.rows]
    for c in [0...data.cols]
      color = data.grid[r][c]
      continue unless color
      ctx.fillStyle = color
      ctx.fillRect startX + c * pixelSize, startY + r * pixelSize, pixelSize + 0.5, pixelSize + 0.5

# Load all CSS skin files, then call onDone
loadAllSkins = (onDone) ->
  return onDone() if SKIN_FILES.length is 0
  promises = SKIN_FILES.map (skinDef) ->
    fetch(skinDef.file)
      .then (r) -> r.text()
      .then (css) -> { skinDef, data: parseCssPixelArt(css) }
      .catch (err) ->
        console.error "Failed to load #{skinDef.file}:", err
        null
  Promise.all(promises).then (results) ->
    for result in results when result
      do (result) ->
        SKINS.push {
          name: result.skinDef.name
          color: '#FFFFFF'
          draw: (cx, cy, size = 40) -> drawCssPixelArt cx, cy, size, result.data
        }
        SKIN_COST.push result.skinDef.cost
    while owned.length < SKINS.length
      owned.push false
    onDone()

# ============================================================
# GAME VARIABLES (don't change this section)
# ============================================================

canvas = null
ctx = null

screen = 'HOME'

bunnyY = H / 2
bunnySpeed = 0

walls = []
carrots = []
powerups = []

score = 0
frames = 0
hasAxe = false
hasWacker = false
waiting = true

bestScore = 0
coins = 0
currentSkin = 0
owned = [true, false, false, false, false, false]

btns = {}


# ============================================================
# SETUP (don't change this section)
# ============================================================

setup = ->
  canvas = document.getElementById 'gameCanvas'
  ctx = canvas.getContext '2d'
  loadData()
  canvas.addEventListener 'click', onClick
  canvas.addEventListener 'touchstart', onTouch, { passive: false }
  document.addEventListener 'keydown', onKey
  # Load CSS skins, then start the game
  # This is a bit complicated - but it helps things load faster.
  loadAllSkins -> gameLoop()



# ============================================================
# SAVE / LOAD (don't change this section)
# ============================================================

saveData = ->
  localStorage.setItem 'bb4_best', bestScore
  localStorage.setItem 'bb4_coins', coins
  localStorage.setItem 'bb4_skin', currentSkin
  localStorage.setItem 'bb4_owned', JSON.stringify owned

loadData = ->
  bestScore = parseInt(localStorage.getItem('bb4_best') or '0')
  coins = parseInt(localStorage.getItem('bb4_coins') or '0')
  currentSkin = parseInt(localStorage.getItem('bb4_skin') or '0')
  savedOwned = localStorage.getItem 'bb4_owned'
  owned = if savedOwned then JSON.parse(savedOwned) else [true, false, false, false, false, false]


# ============================================================
# CHALLENGE 2: Draw the bunny!
# ============================================================
# Draw a circle with eyes for our bunny character
#
# You will need to:
# - Set the fill color using SKINS[skinIndex].color
# - Draw a circle using ctx.arc(x, y, radius, 0, Math.PI * 2)
# - Add a black outline using ctx.stroke()
# - Draw two small circles for eyes
#
# HINTS:
# - Use ctx.fillStyle to set colors
# - Use ctx.beginPath() before drawing shapes
# - Use ctx.fill() to fill shapes
# - The eyes should be at x-6 and x+6, slightly above center (y-4)

drawBunny = (x, y, skinIndex = currentSkin) ->
  # YOUR CODE HERE
  skin = SKINS[skinIndex]

  # If the skin has a draw function, use it and skip the rest of this function
  if skin.draw
    skin.draw x, y, BUNNY_SIZE * 2
    return


  # Step 1: Set fill color to the skin color and draw the body circle  
  
  ctx.fillStyle = SKINS[skinIndex].color
  ctx.beginPath()
  ctx.arc( x, y, BUNNY_SIZE, 0, Math.PI * 2)
  ctx.fill()

  # Step 2: Add a black outline (set strokeStyle, lineWidth, then stroke)
  ctx.strokeStyle = 'black'
  ctx.lineWidth = 5
  ctx.stroke()
  # Step 3: Draw two small black circles for eyes (radius 3)
  #ctx.fillStyle = '#000000'
  #ctx.arc(x, y, 3, 0, Math.PI * 2)
  ctx.fillStyle = 'black'
  ctx.beginPath()
  ctx.arc( x-6, y-4, 5, 0, Math.PI * 2)
  ctx.fill()

  ctx.fillStyle = 'black'
  ctx.beginPath()
  ctx.arc( x+6, y-4, 5, 0, Math.PI * 2)
  ctx.fill()
# ============================================================
# CHALLENGE 3: Draw the walls!
# ============================================================
# Draw brown rectangles for top walls and green for bottom walls
#
# You will need to:
# - Loop through each wall in the walls array
# - Draw a brown rectangle from the top of screen down to wall.topH
# - Draw a green rectangle from wall.botY down to the ground
#
# HINTS:
# - Brown color: '#8B4513'
# - Green color: '#228B22'
# - Use ctx.fillRect(x, y, width, height)
# - Top wall starts at y=0
# - Bottom wall height is: H - 30 - wall.botY

drawWalls = ->
  # YOUR CODE HERE
  # Use a for loop to go through each wall
  # Draw the top wall (brown) and bottom wall (green)
  for wall in walls
    ctx.fillStyle = '#8B4513'
    ctx.fillRect(wall.x, 0, WALL_WIDTH, wall.topH)
    ctx.fillStyle = '#228B22'
    ctx.fillRect(wall.x, wall.botY, WALL_WIDTH, H - wall.botY)
# ============================================================
# CHALLENGE 4: Draw the carrots!
# ============================================================
# Draw orange rectangles for carrots that haven't been collected
#
# You will need to:
# - Loop through each carrot in the carrots array
# - Skip carrots where carrot.got is true (already collected)
# - Draw an orange rectangle at carrot.x, carrot.y
#
# HINTS:
# - Orange color: '#FF8C00'
# - Carrots are 16 pixels wide and 24 pixels tall
# - Use "continue if carrot.got" to skip collected carrots

drawCarrots = ->
  # YOUR CODE HERE
  # Loop through carrots and draw ones that haven't been collected

  for carrot in carrots
    if carrot.got == false
      ctx.fillStyle = '#FF8C00'
      ctx.fillRect(carrot.x, carrot.y, CARROT_WIDTH, CARROT_HEIGHT)



# ============================================================
# DRAWING HELPERS (don't change these)
# ============================================================

drawBackground = ->
  ctx.fillStyle = '#87CEEB'
  ctx.fillRect 0, 0, W, H
  ctx.fillStyle = '#4CAF50'
  ctx.fillRect 0, H - 30, W, 30

drawPowerups = ->
  for powerup in powerups
    continue if powerup.got
    ctx.fillStyle = if powerup.type is 'axe' then '#4444FF' else '#44FF44'
    ctx.beginPath()
    ctx.arc powerup.x + 15, powerup.y + 15, 15, 0, Math.PI * 2
    ctx.fill()
    ctx.fillStyle = 'white'
    ctx.font = 'bold 14px Arial'
    ctx.textAlign = 'center'
    ctx.fillText (if powerup.type is 'axe' then 'A' else 'W'), powerup.x + 15, powerup.y + 20

drawScore = ->
  ctx.fillStyle = 'white'
  ctx.font = 'bold 20px Arial'
  ctx.textAlign = 'left'
  ctx.fillText 'Score: ' + score, 10, 28

drawPowerupIndicators = ->
  if hasAxe
    ctx.fillStyle = '#4444FF'
    ctx.fillRect W / 2 - 30, 40, 60, 20
    ctx.fillStyle = 'white'
    ctx.font = '12px Arial'
    ctx.textAlign = 'center'
    ctx.fillText 'AXE', W / 2, 54
  if hasWacker
    ctx.fillStyle = '#44FF44'
    yPos = if hasAxe then 65 else 40
    ctx.fillRect W / 2 - 40, yPos, 80, 20
    ctx.fillStyle = 'white'
    ctx.font = '12px Arial'
    ctx.textAlign = 'center'
    ctx.fillText 'WACKER', W / 2, yPos + 14

drawBtn = (id, x, y, w, h, text, color = '#4444AA') ->
  btns[id] = { x, y, w, h }
  ctx.fillStyle = color
  ctx.fillRect x, y, w, h
  ctx.fillStyle = 'white'
  ctx.font = 'bold 18px Arial'
  ctx.textAlign = 'center'
  ctx.fillText text, x + w / 2, y + h / 2 + 6


# ============================================================
# SCREENS (don't change these)
# ============================================================

drawHome = ->
  drawBackground()
  ctx.fillStyle = 'white'
  ctx.font = 'bold 36px Arial'
  ctx.textAlign = 'center'
  ctx.fillText 'Bouncy Bunny', W / 2, 80
  drawBunny W / 2, 150

  ctx.fillStyle = '#333'
  ctx.font = '16px Arial'
  ctx.fillText SKINS[currentSkin].name, W / 2, 190
  ctx.fillText 'Best: ' + bestScore, W / 2, 230
  ctx.fillText 'Coins: ' + coins, W / 2, 255

  drawBtn 'play', W / 2 - 80, 280, 160, 50, 'PLAY', '#4CAF50'
  drawBtn 'shop', W / 2 - 80, 350, 160, 45, 'SHOP', '#FF9800'

drawGame = ->
  drawBackground()
  drawWalls()
  drawCarrots()
  drawPowerups()
  drawBunny BUNNY_X, bunnyY
  drawScore()
  drawPowerupIndicators()
  if waiting
    ctx.fillStyle = 'rgba(0,0,0,0.4)'
    ctx.fillRect 0, 0, W, H
    ctx.fillStyle = 'white'
    ctx.font = 'bold 28px Arial'
    ctx.textAlign = 'center'
    ctx.fillText 'Tap or SPACE to start!', W / 2, H / 2

drawOver = ->
  drawBackground()
  drawWalls()
  ctx.fillStyle = 'rgba(0,0,0,0.6)'
  ctx.fillRect 0, 0, W, H

  ctx.fillStyle = '#FF5555'
  ctx.font = 'bold 40px Arial'
  ctx.textAlign = 'center'
  ctx.fillText 'Game Over!', W / 2, 120

  ctx.fillStyle = '#FFD700'
  ctx.font = 'bold 28px Arial'
  ctx.fillText 'Score: ' + score, W / 2, 170
  ctx.font = '18px Arial'
  ctx.fillText 'Best: ' + bestScore, W / 2, 200

  drawBtn 'again', W / 2 - 80, 240, 160, 50, 'Play Again', '#4CAF50'
  drawBtn 'home', W / 2 - 80, 310, 160, 45, 'Home', '#666666'

drawShop = ->
  drawBackground()
  ctx.fillStyle = 'rgba(255,255,255,0.9)'
  ctx.fillRect 20, 20, W - 40, H - 40

  ctx.fillStyle = '#333'
  ctx.font = 'bold 24px Arial'
  ctx.textAlign = 'center'
  ctx.fillText 'Skin Shop', W / 2, 55
  ctx.font = '16px Arial'
  ctx.fillText 'Coins: ' + coins, W / 2, 80

  for i in [0...SKINS.length]
    col = i % 2
    row = Math.floor(i / 2)
    cardX = 30 + col * 215
    cardY = 100 + row * 75
    cardW = 200
    ctx.fillStyle = if i is currentSkin then '#E0FFE0' else '#F0F0F0'
    ctx.fillRect cardX, cardY, cardW, 65
    # Draw character preview - use draw function if available
    if SKINS[i].draw
      SKINS[i].draw cardX + 25, cardY + 32, 32
    else
      ctx.fillStyle = SKINS[i].color
      ctx.beginPath()
      ctx.arc cardX + 25, cardY + 32, 16, 0, Math.PI * 2
      ctx.fill()
      ctx.strokeStyle = '#333'
      ctx.lineWidth = 2
      ctx.stroke()
    ctx.fillStyle = '#333'
    ctx.font = 'bold 12px Arial'
    ctx.textAlign = 'left'
    ctx.fillText SKINS[i].name, cardX + 48, cardY + 25
    ctx.font = '10px Arial'
    ctx.fillText (if owned[i] then 'Owned' else SKIN_COST[i] + ' coins'), cardX + 48, cardY + 42
    if i is currentSkin
      drawBtn 'skin' + i, cardX + 115, cardY + 18, 80, 30, 'Wearing', '#4CAF50'
    else if owned[i]
      drawBtn 'skin' + i, cardX + 115, cardY + 18, 80, 30, 'Wear', '#2196F3'
    else
      btnColor = if coins >= SKIN_COST[i] then '#FF9800' else '#999'
      drawBtn 'skin' + i, cardX + 115, cardY + 18, 80, 30, 'Buy', btnColor

  drawBtn 'back', W / 2 - 60, H - 70, 120, 40, 'Back', '#666'


# ============================================================
# CHALLENGE 5: Bunny physics!
# ============================================================
# Make the bunny fall with gravity and jump when flapping
#
# How gravity works:
# - bunnySpeed starts at 0
# - Each frame, we ADD gravity to bunnySpeed (makes it fall faster)
# - Then we ADD bunnySpeed to bunnyY (moves the bunny down)
#
# How flapping works:
# - Set bunnySpeed to a NEGATIVE number (negative = up!)

applyGravity = ->
  # YOUR CODE HERE
  # Add GRAVITY to bunnySpeed to make the bunny accelerate downward
  bunnySpeed += GRAVITY

moveBunny = ->
  # YOUR CODE HERE
  # Add bunnySpeed to bunnyY to move the bunny
  bunnyY += bunnySpeed

flap = ->
  # YOUR CODE HERE
  # Set waiting to false (game has started)
  # Set bunnySpeed to negative FLAP_POWER to go up
  waiting = false
  bunnySpeed = -FLAP_POWER
# ============================================================
# CHALLENGE 6: Keep bunny on screen!
# ==========================================================
# Stop the bunny at the ceiling, end game at the ground
   
checkCeiling = ->
  # YOUR CODE HERE
  # If bunnyY is less than BUNNY_SIZE:
  #   - Set bunnyY to BUNNY_SIZE (keep on screen)
  #   - Set bunnySpeed to 0 (stop moving)
  if bunnyY < 0
    gameOver()
  return


checkGround = ->
  # YOUR CODE HERE
  # If bunnyY is greater than (H - 30 - BUNNY_SIZE):
  #   - Call gameOver()
  if bunnyY > H - 30 - BUNNY_SIZE
    gameOver()
  return

# ============================================================
# CHALLENGE 7: Move everything left!
# ============================================================
# Move walls, carrots and powerups toward the bunny
# Give points when bunny flies past a wall

moveWalls = ->
  # YOUR CODE HERE
  # Use a for loop to go through each wall:
  #   - Subtract WALL_SPEED from wall.x to move it left
  #   - If wall hasn't been scored yet AND bunny passed it:
  #     - Set wall.scored to true
  #     - Add 1 to score
  #
  # HINT: Bunny passes a wall when wall.x + WALL_WIDTH < BUNNY_X
  for wall in walls
    wall.x -= WALL_SPEED
    if (wall.x + WALL_WIDTH < BUNNY_X) and wall.scored == false
      wall.scored = true
      if wall.scored == true
        score += 1
moveCarrots = ->
  # YOUR CODE HERE
  # Use a for loop to move each carrot left by WALL_SPEED
  for carrot in carrots
    carrot.x -= WALL_SPEED
    


movePowerups = ->
  # YOUR CODE HERE
  # Use a for loop to move each powerup left by WALL_SPEED
  for powerup in powerups
    powerup.x -= WALL_SPEED

removeOldStuff = ->
  # Remove walls, carrots, and powerups that went off the left side
  walls = walls.filter (w) -> w.x + WALL_WIDTH > 0
  carrots = carrots.filter (c) -> c.x + 20 > 0
  powerups = powerups.filter (p) -> p.x + 30 > 0


# ============================================================
# COLLISION HELPER (don't change this)
# ============================================================

# This checks if two rectangles are overlapping (touching)
# Returns true if they overlap, false if they don't
boxesOverlap = (x1, y1, w1, h1, x2, y2, w2, h2) ->
  x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2


# ============================================================
# CHALLENGE 8: Check if bunny hits walls!
# ============================================================
# Use boxesOverlap to detect collisions with walls
# If bunny has a powerup, destroy the wall instead of dying
#
# The bunny's hitbox is a square:
#   - Left edge: BUNNY_X - BUNNY_SIZE
#   - Top edge: bunnyY - BUNNY_SIZE
#   - Width and Height: BUNNY_SIZE * 2
#
# The top wall's hitbox:
#   - Position: wall.x, 0
#   - Size: WALL_WIDTH, wall.topH
#
# The bottom wall's hitbox:
#   - Position: wall.x, wall.botY
#   - Size: WALL_WIDTH, H - wall.botY

checkWallCollision = ->
  # Calculate bunny's hitbox
  bunnyLeft = BUNNY_X - BUNNY_SIZE
  bunnyTop = bunnyY - BUNNY_SIZE
  bunnyBoxSize = BUNNY_SIZE * 2

  for wall in walls
    if boxesOverlap(BUNNY_X, bunnyY, BUNNY_SIZE, BUNNY_SIZE, 
                    wall.x, 0, WALL_WIDTH, wall.topH)
      if hasAxe == false
        gameOver()
      else
        wall.topH = 0
        hasAxe = false
    if boxesOverlap(BUNNY_X, bunnyY, BUNNY_SIZE, BUNNY_SIZE, 
                    wall.x, wall.botY, WALL_WIDTH, H - wall.botY)
      if hasWacker == false
        gameOver()
      else
        wall.botY = H
        hasWacker = false
    return                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
  # For each wall:
  #   - Check if bunny overlaps with top wall using boxesOverlap
  #   - If hit: use axe to destroy wall (set wall.topH = 0) or gameOver
  #   - Check if bunny overlaps with bottom wall
  #   - If hit: use wacker to destroy wall (set wall.botY = H) or gameOver
  #
  # Remember to set hasAxe or hasWacker to false after using them!
  # Use "return" after gameOver() to stop checking more walls


# ============================================================
# CHALLENGE 9: Collect carrots!
# ============================================================
# Check if bunny touches a carrot and collect it
#
# Carrot hitbox: carrot.x, carrot.y, , 

checkCarrotCollision = ->
  bunnyLeft = BUNNY_X - BUNNY_SIZE
  bunnyTop = bunnyY - BUNNY_SIZE
  bunnyBoxSize = BUNNY_SIZE * 2

  # YOUR CODE HERE
  # For each carrot:
  #   - Skip if carrot.got is true (already collected)
  #   - Check if bunny overlaps with carrot using boxesOverlap
  #   - If touching: set carrot.got to true, add points and coins
  for carrot in carrots
    if carrot.got == false
      if boxesOverlap(carrot.x, carrot.y, CARROT_WIDTH, CARROT_HEIGHT,
                      BUNNY_X, bunnyY, BUNNY_SIZE, BUNNY_SIZE)
        carrot.got = true
        score += CARROT_POINTS
        coins += CARROT_COINS
        


# ============================================================
# CHALLENGE 10: Collect powerups!
# ============================================================
# Check if bunny touches a powerup and give it to them

# Powerup hitbox: powerup.x, powerup.y, width 30, height 30
# If powerup.type is 'axe', set hasAxe to true, 
# Otherwise set hasWacker to true

checkPowerupCollision = ->
  bunnyLeft = BUNNY_X - BUNNY_SIZE
  bunnyTop = bunnyY - BUNNY_SIZE
  bunnyBoxSize = BUNNY_SIZE * 2

  for powerup in powerups
    if powerup.got == false
      if boxesOverlap(powerup.x, powerup.y, 30, 30,
                      BUNNY_X, bunnyY, BUNNY_SIZE, BUNNY_SIZE)
          powerup.got = true
          if powerup.type == 'axe'
            hasAxe = true
          if powerup.type == 'wacker'
            hasWacker = true
  # YOUR CODE HERE
  # For each powerup:


  #   - Check if bunny overlaps with powerup
  #   - If touching: set powerup.got to true, give the right powerup


# ============================================================
# SPAWNING (don't change this section)
# ============================================================


spawnWall = ->
  topH = 50 + Math.random() * (H - GAP_SIZE - 110)
  botY = topH + GAP_SIZE
  walls.push { x: W, topH: topH, botY: botY, scored: false }

  # Choose when to have a carrot appear
  if Math.random() < 0.1  # Change this to make it less frequent
    carrotY = topH + 20 + Math.random() * (GAP_SIZE - 60)
    carrots.push { x: W + WALL_WIDTH / 2 - 8, y: carrotY, got: false }

  if walls.length % POWERUP_EVERY is 0
    type = if Math.random() < 0.5 then 'axe' else 'wacker'
    powerups.push { x: W + WALL_WIDTH + 20, y: topH + GAP_SIZE / 2 - 15, type: type, got: false }


# ============================================================
# GAME STATE (don't change this section)
# ============================================================

resetGame = ->
  score = 0
  frames = 0
  bunnyY = H / 2
  bunnySpeed = 0
  walls = []
  carrots = []
  powerups = []
  hasAxe = false
  hasWacker = false
  waiting = true

gameOver = ->
  if score > bestScore
    bestScore = score
  saveData()
  screen = 'OVER'


# ============================================================
# INPUT (don't change this section)
# ============================================================

hitBtn = (id, x, y) ->
  b = btns[id]
  return false unless b
  x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h

handleClick = (x, y) ->
  switch screen
    when 'HOME'
      if hitBtn 'play', x, y
        resetGame()
        screen = 'GAME'
      else if hitBtn 'shop', x, y
        screen = 'SHOP'
    when 'GAME'
      flap()
    when 'OVER'
      if hitBtn 'again', x, y
        resetGame()
        screen = 'GAME'
      else if hitBtn 'home', x, y
        screen = 'HOME'
    when 'SHOP'
      if hitBtn 'back', x, y
        screen = 'HOME'
      else
        for i in [0...SKINS.length]
          if hitBtn 'skin' + i, x, y
            if owned[i]
              currentSkin = i
              saveData()
            else if coins >= SKIN_COST[i]
              coins -= SKIN_COST[i]
              owned[i] = true
              currentSkin = i
              saveData()

onClick = (e) ->
  r = canvas.getBoundingClientRect()
  x = (e.clientX - r.left) * (W / r.width)
  y = (e.clientY - r.top) * (H / r.height)
  handleClick x, y

onTouch = (e) ->
  e.preventDefault()
  t = e.touches[0]
  r = canvas.getBoundingClientRect()
  x = (t.clientX - r.left) * (W / r.width)
  y = (t.clientY - r.top) * (H / r.height)
  handleClick x, y

onKey = (e) ->
  if e.key is ' '
    e.preventDefault()
    if screen is 'HOME'
      resetGame()
      screen = 'GAME'
    else if screen is 'GAME'
      flap()


# ============================================================
# MAIN GAME LOOP (don't change this section)
# ============================================================

update = ->
  return if screen isnt 'GAME' or waiting

  frames = frames + 1

  # Physics
  applyGravity()
  moveBunny()
  checkCeiling()
  checkGround()

  # Movement
  moveWalls()
  moveCarrots()
  movePowerups()
  removeOldStuff()

  # Spawn new walls
  if frames % SPAWN_TIME is 0
    spawnWall()

  # Collisions
  checkWallCollision()
  checkCarrotCollision()
  checkPowerupCollision()

draw = ->
  btns = {}
  switch screen
    when 'HOME' then drawHome()
    when 'GAME' then drawGame()
    when 'OVER' then drawOver()
    when 'SHOP' then drawShop()

gameLoop = ->
  update()
  draw()
  requestAnimationFrame gameLoop


# ============================================================
# START THE GAME!
# ============================================================

setup()
