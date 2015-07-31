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
-- show status bar for iPhones
display.setStatusBar( display.TranslucentStatusBar )

local orange = {255/255, 85/255, 1/255}

local composer = require( "composer" )
local widget = require( "widget" )
local json = require( "json" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- Variables
local background
local shadow
local back_icon
local back_title
local social
local divisor
local title
local dock
local content
local body
local image
local image_link

local author
local author_name
local summary

local scrollView = widget.newScrollView
{
    top = 0,
    left = 0,
    width = _W,
    height = _H * 0.895
}

local function get_content(name)
	local path = system.pathForFile( name, system.DocumentsDirectory )
	local fh = io.open( path, "r" )
  if not fh then
    return ""
  end
	return fh:read( "*a" )
end

local function on_click_back(e)
  local options =
    {
        effect = "fromLeft",
        time = 400,
        params = {
          n = 0
        }
    }
    composer.gotoScene("read", options)
end

local function decode_issue(response)
  local json_response = json.decode(response)
  author_name = json_response["author"]
  content = json_response["content"]
  image_link = json_response["link"]
end
---------------------------------------------------------------------------------


function scene:create( event )
    local sceneGroup = self.view
    print(event.params.link)
    decode_issue(get_content(event.params.link))
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(1)
    
    back_icon = display.newImageRect("back.png", _W * 0.08, _W * 0.08)
    back_icon.x = 0
    back_icon.y = _H * 0.048 + offset
    back_icon.anchorX = 0
    back_icon.anchorY = 0.5
    back_icon.alpha = 0
    back_icon:setFillColor(1)
    
    divisor = display.newImageRect("divisor.png", _W, 1)
    divisor.x = 0
    divisor.y = back_icon.y + back_icon.height * 0.5 + _H * 0.01
    divisor.anchorX = 0
    divisor.alpha = 0
    
    back_title = display.newText( "Articoli", 0, 0, native.systemFont, _W * 0.05 )
    back_title:setFillColor( 1, 1, 1)
    back_title.y = back_icon.y
    back_title.x = back_icon.x + back_icon.width - _W * 0.01
    back_title.anchorX = 0
    back_title.anchorY = 0.5
    back_title:setFillColor(1)
    back_title.alpha = 0
    
    title = display.newText( event.params.title, 0, 0, _W * 0.9, 0, native.systemFont, _W * 0.09 )
    title:setFillColor( 0.4, 0.4, 0.4)
    title.y = _H * 0.03
    title.x = _W * 0.05
    title.anchorX = 0
    title.anchorY = 0
    title.alpha = 1
    
    author = display.newText( "di "..author_name, 0, 0, _W * 0.9, 0, native.systemFont, _W * 0.034 )
    author:setFillColor( 0.4, 0.4, 0.4)
    author.y = title.y + title.height + _H * 0.02
    author.x = _W * 0.05
    author.anchorX = 0
    author.anchorY = 0
    author.alpha = 1
    
    body = display.newText( content, 0, 0, _W * 0.9, 0, "Ubuntu Regular", _W * 0.055 )
    body:setFillColor( 0.2, 0.2, 0.2)
    body.y = author.y + author.height + _H * 0.04
    body.x = _W * 0.05
    body.anchorX = 0
    body.anchorY = 0
    body.alpha = 1
    
    dock = display.newRect(0, 0, _W , divisor.y)
    dock.anchorX = 0
    dock.anchorY = 0
    dock.alpha = 1
    dock:setFillColor(unpack(orange))
    
    shadow = display.newImageRect("gradient3.png", _W, _W * 0.02)
    shadow.anchorX = 0.5
    shadow.anchorY = 0
    shadow.rotation = 180
    shadow.x = _W * 0.5
    shadow.y = dock.height + _H * 0.005
    shadow.alpha = 1
    
    social = display.newImageRect("social.png", _W * 0.069, _W * 0.069)
    social.x = _W * 0.95
    social.y = _H * 0.048 + offset
    social.anchorX = 1
    social.anchorY = 0.5
    social.alpha = 0
    social:setFillColor(1)
    
    scrollView.y = divisor.y
    scrollView.height = _H - divisor.y
    scrollView.anchorY = 0
    
    sceneGroup:insert(background)
    sceneGroup:insert(shadow)
    sceneGroup:insert(dock)
    sceneGroup:insert(back_icon)
    sceneGroup:insert(social)
    sceneGroup:insert(back_title)
    scrollView:insert(title)
    scrollView:insert(author)
    scrollView:insert(body)
    
    sceneGroup:insert(scrollView)
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
        transition.to(social, {alpha = 1, time = 150})
        transition.to(back_title, {alpha = 1, time = 150})
        transition.to(back_icon, {alpha = 1, time = 150})
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
        transition.to(social, {alpha = 0, time = 150})
        transition.to(back_icon, {alpha = 0, time = 150})
        transition.to(back_title, {alpha = 0, time = 150})
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
