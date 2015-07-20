---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight

-- show status bar for iPhones
display.setStatusBar( display.DefaultStatusBar )

local composer = require( "composer" )
local widget = require( "widget" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- Variables
local background
local cover
local the_mask_logo
local the_mask_motto
local latest_issue_btn
local latest_issue_txt
local older_issues_txt
local archivio_numeri_txt
local social_media
local social_media_icon_size = _W * 0.077



---------------------------------------------------------------------------------

local function create_social_media_group()
  local g = display.newGroup()
  local fb = display.newImageRect("facebook-32.png", social_media_icon_size, social_media_icon_size)
  fb.anchorX = 0.5
  fb.anchorY = 0.5
  local insta = display.newImageRect("instagram-32.png", social_media_icon_size, social_media_icon_size)
  insta.anchorX = 0.5
  insta.anchorY = 0.5
  local ytb = display.newImageRect("youtube-32.png", social_media_icon_size, social_media_icon_size)
  ytb.anchorX = 0.5
  ytb.anchorY = 0.5
  
  local icon_offset = _W * 0.15
  
  fb.alpha = 0.8
  insta.alpha = 0.8
  ytb.alpha = 0.8
  
  fb.x = _W * 0.5
  insta.x = _W * 0.5 - icon_offset
  ytb.x = _W * 0.5 + icon_offset
  
  g:insert(fb)
  g:insert(insta)
  g:insert(ytb)
  
  return g
  
end

local nextSceneButton

local function on_click_btn()
    local options =
    {
        effect = "fromTop",
        time = 400,
        params = {
          issue = "latest"
        }
    }
    composer.gotoScene("read", options)
end

local function on_click_archivio()
    local options =
    {
        effect = "fromBottom",
        time = 400
        
    }
    composer.gotoScene("archive", options)
end

function scene:create( event )
    local sceneGroup = self.view
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(0.98)
    

    cover = display.newRect(0, 0, _W, _H * 0.56)
    cover.x = 0
    cover.y = 0
    cover.anchorX = 0
    cover.anchorY = 0
    cover:setFillColor(1, 0.45, 0)
    
    latest_issue_btn = display.newRoundedRect(0, 0, _W * 0.4, _W * 0.12, _H * 0.008)
    latest_issue_btn.x = _W * 0.5
    latest_issue_btn.y = _H * 0.68
    latest_issue_btn.anchorX = 0.5
    latest_issue_btn.anchorY = 0.5
    latest_issue_btn:setFillColor(1, 0.45, 0)
    --latest_issue_btn:setStrokeColor(1, 0.45, 0)
    --latest_issue_btn.strokeWidth = 3
    
    the_mask_logo = display.newImageRect("the_mask_logo.png", _W * 0.8, _W * 0.15)
    the_mask_logo.anchorX = 0.5
    the_mask_logo.anchorY = 0
    the_mask_logo.x = _W * 0.5
    the_mask_logo.y = _H * 0.26
    the_mask_logo.alpha = 1
    
    the_mask_motto = display.newText( "A full Mascheroni Production", 0, 0, native.systemFontBold, _W * 0.045 )
    the_mask_motto:setFillColor( 1, 1, 1 )
    the_mask_motto.y = the_mask_logo.y + the_mask_logo.height + _H * 0.05
    the_mask_motto.x = _W * 0.5
    the_mask_motto.anchorX = 0.5
    the_mask_motto.anchorY = 0
    the_mask_motto.id = "tmm"
    
    latest_issue_txt = display.newText( "Ultimo numero", 0, 0, native.systemFontBold, _W * 0.04 )
    latest_issue_txt:setFillColor( 1, 1, 1)
    latest_issue_txt.y = latest_issue_btn.y
    latest_issue_txt.x = latest_issue_btn.x
    latest_issue_txt.anchorX = 0.5
    latest_issue_txt.anchorY = 0.5
    
    archivio_numeri_txt = display.newText( "Archivio numeri", 0, 0, native.systemFontBold, _W * 0.032 )
    archivio_numeri_txt:setFillColor( 0.2, 0.2, 0.2)
    archivio_numeri_txt.y = latest_issue_btn.y + _H * 0.09
    archivio_numeri_txt.x = _W * 0.5
    archivio_numeri_txt.anchorX = 0.5
    archivio_numeri_txt.anchorY = 0.5
    
    social_media = create_social_media_group()
    social_media.y = _H * 0.92
    
    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
    sceneGroup:insert(background)
    sceneGroup:insert(cover)
    sceneGroup:insert(latest_issue_btn)
    sceneGroup:insert(the_mask_logo)
    sceneGroup:insert(the_mask_motto)
    sceneGroup:insert(latest_issue_txt)
    sceneGroup:insert(archivio_numeri_txt)
    sceneGroup:insert(social_media)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        latest_issue_btn:addEventListener("tap", on_click_btn)
        archivio_numeri_txt:addEventListener("tap", on_click_archivio)
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
        latest_issue_btn:removeEventListener("tap", on_click_btn)
        archivio_numeri_txt:removeEventListener("tap", on_click_archivio)
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
