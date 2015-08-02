---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight


-- show status bar for iPhones
local offset = display.statusBarHeight * 0.6
local pl = system.getInfo( "platformName" )
if pl == "Android" or pl == "Wisn" then
	offset = 0
end

local composer = require( "composer" )
local widget = require( "widget" )
local json = require("json")
local sqlite = require("sqlite3")

local orange = {255/255, 85/255, 1/255}

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- Variables
local divisor
local dock

local magazine_cover
local black_cover
local sample_articles = {}
local issue_date
local cancel
local issue_id
local issue_title
local rows = {}
local params = {}
local articles
local shadow
local categories
local links

local paragraph
local first_label
local first_text
local second_label
local second_text
local send_btn
local send_txt
params.progress = true
---------------------------------------------------------------------------------



local function networkListener( event )

    if ( event.isError ) then
        print( "Network error!" )
    else
        print ( "RESPONSE: " .. event.response )
    end
end

local function on_click_cancel()
    i = 1
    local options =
    {
        effect = "fromBottom",
        time = 400,
        params = {
          issue = "scene1"
        }
    }
    composer.gotoScene("scene1", options)
end


local function inputListener( event )
    if event.phase == "began" then
        -- user begins editing textBox
        print( event.text )

    elseif event.phase == "ended" then
        -- do something with textBox text
        print( event.target.text )

    elseif event.phase == "editing" then
        print( event.newCharacters )
        print( event.oldText )
        print( event.startPosition )
        print( event.text )
    end
end




function scene:create( event )
    local sceneGroup = self.view
    
    black_cover = display.newRect(0, 0, _W , _H)
    black_cover.anchorX = 0
    black_cover.anchorY = 0
    black_cover.x = 0
    black_cover.y = 0
    black_cover.alpha = 1
    black_cover:setFillColor(1)

    
    issue_date = display.newText( "Ipse Dixit", 0, 0, native.systemFont, _W * 0.056 )
    issue_date:setFillColor( 1 )
    issue_date.y = _H * 0.048 + offset
    issue_date.x = _W * 0.5
    issue_date.anchorX = 0.5
    issue_date.anchorY = 0.5
    issue_date.alpha = 1
    
    
    cancel = display.newImageRect("cancel.png", _W * 0.08 , _W * 0.08)
    cancel.anchorX = 0
    cancel.anchorY = 0.5
    cancel.x = _W * 0.05
    cancel.y = _H * 0.048 + offset
    cancel.alpha = 1
    cancel:setFillColor(1)
    
    divisor = display.newLine(0, cancel.y + cancel.height * 0.5 + _H * 0.01, _W, cancel.y + cancel.height * 0.5 + _H * 0.01)
    divisor.x = 0
    divisor.anchorX = 0
    divisor.alpha = 0
    divisor:setStrokeColor(0.9, 0.9, 0.9)
    divisor.strokeWidth = 1
    
    
    first_label = display.newText( "Insegnante:", 0, 0, "Roboto Bold", _W * 0.05 )
    first_label:setFillColor( unpack(orange) )
    first_label.y = divisor.y + _H * 0.05
    first_label.x = _W * 0.025
    first_label.anchorX = 0
    first_label.anchorY = 0
    first_label.alpha = 1

    first_text = native.newTextBox( _W * 0.5, first_label.y + _H * 0.1, _W, _H * 0.08 )
    first_text.text = ""
    first_text.isEditable = true
    
    second_label = display.newText( "Ha detto:", 0, 0, "Roboto Bold", _W * 0.05 )
    second_label:setFillColor( unpack(orange) )
    second_label.y = first_label.y + _H * 0.18
    second_label.x = _W * 0.025
    second_label.anchorX = 0
    second_label.anchorY = 0
    second_label.alpha = 1

    second_text = native.newTextBox( _W * 0.5, second_label.y + _H * 0.1, _W, _H * 0.1 )
    second_text.text = ""
    second_text.isEditable = true
    
    send_btn = display.newRoundedRect(0, 0, _W * 0.38, _W * 0.11, _H * 0.008)
    send_btn.x = _W * 0.5
    send_btn.y = _H * 0.61
    send_btn.anchorX = 0.5
    send_btn.anchorY = 0.5
    send_btn:setFillColor(unpack(orange))
    
    send_txt = display.newText( "Invia", 0, 0, native.systemFontBold, _W * 0.04 )
    send_txt:setFillColor( 1, 1, 1)
    send_txt.y = send_btn.y
    send_txt.x = send_btn.x
    send_txt.anchorX = 0.5
    send_txt.anchorY = 0.5
    
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
    
    sceneGroup:insert(black_cover)
    sceneGroup:insert(shadow)
    sceneGroup:insert(dock)
    sceneGroup:insert(issue_date)
    sceneGroup:insert(cancel)
    sceneGroup:insert(divisor)
    
    sceneGroup:insert(first_label)
    sceneGroup:insert(first_text)
    sceneGroup:insert(second_label)
    sceneGroup:insert(second_text)
    sceneGroup:insert(send_btn)
    sceneGroup:insert(send_txt)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        display.setStatusBar( display.TranslucentStatusBar )
        transition.to(cancel, {alpha = 1, time = 150})
        cancel:addEventListener("tap", on_click_cancel)
    elseif phase == "did" then
        -- Called when the scene is now on screen
        --
        --network.request( "https://raw.githubusercontent.com/MrAnonimus/the-mask/master/sample.json", "GET", networkListener )
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
        cancel:removeEventListener("tap", on_click_cancel)
        first_text:addEventListener( "userInput", inputListener )
        transition.to(articles_table, {y = _H * 2, time = 600, transition = easing.inExpo})
        transition.to(cancel, {alpha = 0, time = 150})
        
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
