---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight

local offset = display.statusBarHeight * 0.6
-- show status bar for iPhones
display.setStatusBar( display.DefaultStatusBar )

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
local grid

local scrollView = widget.newScrollView
{
    top = 0,
    left = 0,
    width = _W,
    height = _H * 0.895
}

local issues = {"the_mask_cover.png", "cover2.png", "cover3.png", "cover4.png", "cover5.jpg"}
local older_issues = {}

local function create_archived_grid()
  local g = display.newGroup()
  for i = 1, #issues do
    local issue = display.newImageRect(issues[i], _W * 0.5, _W * 1.417 * 0.5)
    issue.x = ((i - 1) % 2) * _W * 0.5
    issue.y = _W * 1.417 * 0.5 * math.floor((i - 1)/2)
    issue.anchorX = 0
    issue.anchorY = 0
    issue.link = issues[i]
    older_issues[i] = issue
    g:insert(issue)
  end
  return g
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
    composer.gotoScene("scene1", options)
end
---------------------------------------------------------------------------------


function scene:create( event )
    local sceneGroup = self.view
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(0.98)
    
    back_icon = display.newImageRect("back.png", _W * 0.09, _W * 0.09)
    back_icon.x = 0
    back_icon.y = _H * 0.048 + offset
    back_icon.anchorX = 0
    back_icon.anchorY = 0.5
    back_icon.alpha = 0
    
    divisor = display.newImageRect("divisor.png", _W, 1)
    divisor.x = 0
    divisor.y = back_icon.y + back_icon.height * 0.5 + _H * 0.01
    divisor.anchorX = 0
    divisor.alpha = 0.2
    
    scrollView.y = divisor.y
    scrollView.anchorY = 0
    
    back_icon:setFillColor(1, 0.45, 0)
    
    back_title = display.newText( "Home", 0, 0, native.systemFont, _W * 0.05 )
    back_title:setFillColor( 1, 1, 1)
    back_title.y = back_icon.y
    back_title.x = back_icon.x + back_icon.width - _W * 0.01
    back_title.anchorX = 0
    back_title.anchorY = 0.5
    back_title:setFillColor(1, 0.45, 0)
    back_title.alpha = 0
    
    title = display.newText( "Archivio", 0, 0, native.systemFont, _W * 0.05 )
    title.y = back_icon.y
    title.x = _W * 0.5
    title.anchorX = 0.5
    title.anchorY = 0.5
    title:setFillColor(1, 0.45, 0)
    title.alpha = 0
    
    grid = create_archived_grid()
    grid.anchorX = 0
    grid.anchorY = 0
    grid.y = 0
    
    sceneGroup:insert(background)
    sceneGroup:insert(back_icon)
    sceneGroup:insert(back_title)
    sceneGroup:insert(title)
    scrollView:insert(grid)
    sceneGroup:insert(scrollView)
    sceneGroup:insert(divisor)
    
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        back_icon:addEventListener("tap", on_click_back)
        back_title:addEventListener("tap", on_click_back)
        
        transition.to(back_title, {alpha = 1, time = 150})
        transition.to(back_icon, {alpha = 1, time = 150})
        transition.to(title, {alpha = 1, time = 150})
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
        transition.to(back_icon, {alpha = 0, time = 150})
        transition.to(back_title, {alpha = 0, time = 150})
        transition.to(title, {alpha = 0, time = 150})
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
