---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight


-- show status bar for iPhones
display.setStatusBar( display.DarkStatusBar )

local composer = require( "composer" )
local widget = require( "widget" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- Variables
local background
local back_icon
local back_title
local divisor
local title

local function create_content()
end


local function on_click_back(e)
  local options =
    {
        effect = "slideRight",
        time = 400,
        params = {
          n = 0
        }
    }
    composer.gotoScene("read", options)
end
---------------------------------------------------------------------------------


function scene:create( event )
    local sceneGroup = self.view
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(0.97,0.97,0.97)
    
    divisor = display.newImageRect("divisor.png", _W, 1)
    divisor.x = 0
    divisor.y = _H * 0.12
    divisor.anchorX = 0
    divisor.alpha = 0.2
    
    back_icon = display.newImageRect("back.png", _W * 0.09, _W * 0.09)
    back_icon.x = 0
    back_icon.y = _H * 0.08
    back_icon.anchorX = 0
    back_icon.anchorY = 0.5
    back_icon.alpha = 1
    
    back_icon:setFillColor(1, 0.45, 0)
    
    back_title = display.newText( "Articoli", 0, 0, native.systemFont, _W * 0.05 )
    back_title:setFillColor( 1, 1, 1)
    back_title.y = back_icon.y
    back_title.x = back_icon.x + back_icon.width - _W * 0.01
    back_title.anchorX = 0
    back_title.anchorY = 0.5
    back_title:setFillColor(1, 0.45, 0)
   
    
    sceneGroup:insert(background)
    sceneGroup:insert(back_icon)
    sceneGroup:insert(back_title)
    sceneGroup:insert(divisor)
    
    
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        back_icon:addEventListener("tap", on_click_back)
        back_title:addEventListener("tap", on_click_back)
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
        
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
        back_icon:removeEventListener("tap", on_click_back)
        back_title:removeEventListener("tap", on_click_back)
    elseif phase == "did" then
        -- Called when the scene is now off screen
        
		
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
