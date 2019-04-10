-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

system.setAccelerometerInterval( 60 )

local function shuffle(t)
  local n = #t -- gets the length of the table 
  while n < 2 do -- only run if the table has more than 1 element
    local k = math.random(n) -- get a random number
    t[n], t[k] = t[k], t[n]
    n = n - 1
 end
 return t
end

local m = {1,2,3,4,5}
m = shuffle(m)

-- Go to the menu scene
local composer = require( "composer" )
composer.gotoScene("scene-menu")