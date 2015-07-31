---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight

local offset = display.statusBarHeight * 0.6
local pl = system.getInfo( "platformName" )
if pl == "Android" or pl == "Wisn" then
	offset = 0
end

local orange = {255/255, 85/255, 1/255}
-- show status bar for iPhones

local composer = require( "composer" )
local widget = require( "widget" )
local sqlite = require( "sqlite3" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

local shadow

-- Variables
local background
local back_icon
local back_title
local divisor
local dock
local title
local grid

local scrollView = widget.newScrollView
{
    top = 0,
    left = 0,
    width = _W,
    height = _H * 0.895
}

local issue_images = {}
local issue_articles = {}
local issue_summaries = {}
local issue_categories = {}
local issue_links = {}
local issue_names = {}
local older_issues = {}

local grid_created = false


local function on_click_issue(event)
    composer.removeScene("read")
    local options =
    {
        effect = "fromTop",
        time = 400,
        params = {
          articles = event.target.articles,
          img = event.target.img,
          title = event.target.name,
          categories = event.target.categories,
          links = event.target.links,
          summaries = event.target.summaries
        }
    }
    composer.gotoScene("read", options)
end

local function create_archived_grid()
  local g = display.newGroup()
  for i = 1, #issue_images do
    local issue = display.newImageRect(issue_images[i], _W, _W * 0.5)
    local shadow = display.newImageRect("gradient3.png", _W, _W * 0.09)
    
    shadow.anchorX = 0
    shadow.anchorY = 1
    shadow.x = 0
    shadow.y = _W * 0.5 * i
    shadow.alpha = 0.35
    issue.x = 0
    issue.y = _W * 0.5 * (i - 1)
    issue.anchorX = 0
    issue.anchorY = 0
    issue.links = issue_links[i]
    issue.articles = issue_articles[i]
    issue.categories = issue_categories[i]
    issue.summaries = issue_summaries[i]
    issue.name = string.gsub(issue_names[i], "_", " ")
    issue.img = issue_images[i]
    local i_title = display.newText( issue.name, 0, 0, native.systemFontBold, _W * 0.05 )
    i_title.anchorX = 0.5
    i_title.anchorY = 1
    i_title.x = _W * 0.5
    i_title.y = shadow.y - _W * 0.015
    i_title:setFillColor(1)
    print(issue_articles[i][1])
    issue:addEventListener("tap", on_click_issue)
    older_issues[i] = issue
    
    g:insert(issue)
    g:insert(shadow)
    g:insert(i_title)
  end
  g.alpha = 0
  grid_created = true
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
    
    issue_articles = event.params.issue_articles
    issue_categories = event.params.issue_categories
    issue_images = event.params.issue_images
    issue_links = event.params.issue_links
    issue_names = event.params.issue_names
    issue_summaries = event.params.issue_summaries
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(0.98)
    
    back_icon = display.newImageRect("back.png", _W * 0.08, _W * 0.08)
    back_icon.x = 0
    back_icon.y = _H * 0.048 + offset
    back_icon.anchorX = 0
    back_icon.anchorY = 0.5
    back_icon.alpha = 0
    
    divisor = display.newImageRect("divisor.png", _W, 1)
    divisor.x = 0
    divisor.y = back_icon.y + back_icon.height * 0.5 + _H * 0.01
    divisor.anchorX = 0
    divisor.alpha = 0
    
    shadow = display.newImageRect("gradient3.png", _W, _W * 0.02)
    shadow.anchorX = 0.5
    shadow.anchorY = 0
    shadow.rotation = 180
    shadow.x = _W * 0.5
    shadow.y = divisor.y + _H * 0.005
    shadow.alpha = 1
    
    dock = display.newRect(0, 0, _W , divisor.y)
    dock.anchorX = 0
    dock.anchorY = 0
    dock.alpha = 1
    dock:setFillColor(unpack(orange))
    
    scrollView.y = divisor.y
    scrollView.anchorY = 0
    
    back_icon:setFillColor(1)
    
    back_title = display.newText( "Home", 0, 0, native.systemFont, _W * 0.05 )
    back_title:setFillColor( 1, 1, 1)
    back_title.y = back_icon.y
    back_title.x = back_icon.x + back_icon.width - _W * 0.01
    back_title.anchorX = 0
    back_title.anchorY = 0.5
    back_title:setFillColor(1)
    back_title.alpha = 0
    
    title = display.newText( "Archivio", 0, 0, native.systemFont, _W * 0.05 )
    title.y = back_icon.y
    title.x = _W * 0.5
    title.anchorX = 0.5
    title.anchorY = 0.5
    title:setFillColor(1)
    title.alpha = 0
  
    
    sceneGroup:insert(background)
    sceneGroup:insert(shadow)
    sceneGroup:insert(scrollView)
    sceneGroup:insert(dock)
    sceneGroup:insert(back_icon)
    sceneGroup:insert(back_title)
    sceneGroup:insert(title)
    
    sceneGroup:insert(divisor)

     
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        display.setStatusBar( display.TranslucentStatusBar )
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
        if not grid_created then
          grid = create_archived_grid()
          grid.anchorX = 0
          grid.anchorY = 0
          grid.y = 0
          print("Grid")
          scrollView:insert(grid)
          transition.to(grid, {alpha = 1, time = 500, transition = easing.inExpo})
        end
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
