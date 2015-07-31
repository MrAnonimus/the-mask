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
local summaries
params.progress = true
---------------------------------------------------------------------------------

local function does_exist(name)
	--> Specify the path
	local path = system.pathForFile( name, system.DocumentsDirectory )
	--> This opens the specified file and returns nil if it couldn't be found
	local fh = io.open( path, "r" )
	if fh then
	   return true
	else
	   return false
	end
end

local function networkListener( event )

    if ( event.isError ) then
        print( "Network error!" )
    else
        print ( "RESPONSE: " .. event.response )
    end
end



local i = 1

local function get_bullet_color(category)
  if category == "a" then
    return unpack({1, 0.5, 0.5})
  elseif category == "b" then
    return unpack({0.5, 1, 0.5})
  elseif category == "c" then
    return unpack({0.5, 0.5, 1})
  end
end

local function get_category_link(category)
  if category == "a" then
    return "scuola.png"
  elseif category == "b" then
    return "arte.png"
  elseif category == "c" then
    return "musica.png"
  end
end

local function onRowRender( event )
	
    -- Get reference to the row group
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    
    local rowShadow = display.newRoundedRect(row, rowWidth*0.5, rowHeight*0.51, rowWidth*0.93, rowHeight*0.91, 5)
	
    local rowCard = display.newRoundedRect(row, rowWidth*0.5, rowHeight*0.5, rowWidth*0.92, rowHeight*0.9, 5)
    

    local rowTitle = display.newText( row, articles[i], 0, 0, _W * 0.8, 0, native.systemFont, _W * 0.002 )
    
    local rowSummary = display.newText( row, summaries[i], 0, 0, _W * 0.8, 0, native.systemFont, _W * 0.0018 )
    local bullet = display.newImageRect(row, get_category_link(categories[i]), _W * 0.11, _W * 0.11)
    bullet.anchorX = 1
    bullet.anchorY = 1
    bullet.alpha = 0.11
    rowTitle:setFillColor( 1, 0.45, 0 )
    rowSummary:setFillColor(0.65, 0.65, 0.65)
    
    rowCard:setFillColor(1)
    rowShadow:setFillColor(0.92)
    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowSummary.anchorX = 0
    rowSummary.anchorY = 0
    
    rowTitle.x = _W * 0.08
    rowSummary.x = rowTitle.x
    rowTitle.y = rowHeight * 0.3
    rowSummary.y = rowTitle.y + _H * 0.04
    
    
    bullet.x = _W * 0.94
    bullet.y = rowHeight * 0.94
    
    row.id = i
    row.link = links[i]
    row.summary = summaries[i]
    row.title = articles[i]
    rows[i] = row
    row.alpha = 1
    i = i + 1
end

local function onRowTouch(e)
  local options =
    {
        effect = "fromRight",
        time = 400,
        params = {
          link = e.target.link,
          title = e.target.title,
          summary = e.target.summary
        }
    }
    composer.gotoScene("article", options)
end

local function scrollListener(e)
end


local articles_table = widget.newTableView
{
    left = 0,
    top = _H * 1.12,
    height = _H * 0.8,
    width = _W,
    backgroundColor = {1,1,1},
    hideBackground = true,
    hideScrollBar = true,
    onRowRender = onRowRender,
    onRowTouch = onRowTouch,
    listener = scrollListener
}


local nextSceneButton

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




function scene:create( event )
    local sceneGroup = self.view
    articles = event.params.articles
    categories = event.params.categories
    links = event.params.links
    summaries = event.params.summaries
    -- Access Google over SSL:
    
    black_cover = display.newRect(0, 0, _W , _H)
    black_cover.anchorX = 0
    black_cover.anchorY = 0
    black_cover.x = 0
    black_cover.y = 0
    black_cover.alpha = 1
    black_cover:setFillColor(0.985)

    
    issue_date = display.newText( event.params.title, 0, 0, native.systemFont, _W * 0.056 )
    issue_date:setFillColor( 1 )
    issue_date.y = _H * 0.048 + offset
    issue_date.x = _W * 0.5
    issue_date.anchorX = 0.5
    issue_date.anchorY = 0.5
    issue_date.alpha = 1
    
    articles_table.y = _H * 2
    articles_table.anchorY = 0
    
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
    
    
    for i = 1, #event.params.articles do
    articles_table:insertRow(
    {
        --isCategory = isCategory,
        rowHeight = _H * 0.2,
        rowWidth = _W,
        rowColor  = { default={ 0.95,0.95,0.95, 0 }, over={ 159/255, 205/255, 146/255, 0 } },
        lineColor = {0.9, 0.9, 0.9, 0},
        params = {}  -- Include custom data in the row
    })
  end
    
    sceneGroup:insert(black_cover)
    sceneGroup:insert(shadow)
    sceneGroup:insert(dock)
    sceneGroup:insert(issue_date)
    sceneGroup:insert(articles_table)
    sceneGroup:insert(cancel)
    sceneGroup:insert(divisor)
    
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        display.setStatusBar( display.TranslucentStatusBar )
        cancel:addEventListener("tap", on_click_cancel)
        transition.to(cancel, {alpha = 1, time = 150})
        
    elseif phase == "did" then
        -- Called when the scene is now on screen
        --
        --network.request( "https://raw.githubusercontent.com/MrAnonimus/the-mask/master/sample.json", "GET", networkListener )
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
        
        transition.to(articles_table, {y = issue_date.y + issue_date.height + _H * 0.015, time = 1100, transition = easing.outExpo})
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
