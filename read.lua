---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight


-- show status bar for iPhones
display.setStatusBar( display.DarkStatusBar )

local offset = display.statusBarHeight * 0.6

local composer = require( "composer" )
local widget = require( "widget" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

-- Variables
local magazine_cover
local black_cover
local sample_articles = {"BCE Approves new Greek Debt Reduction Plan", "Tesla to be announcing new car model Tesla Z", "Congress approves same sex marriage", "N. Djokovic beats Federer and wins Wimbledon"}
local issue_date
local cancel
local rows = {}
---------------------------------------------------------------------------------
local i = 1
local function onRowRender( event )
	
    -- Get reference to the row group
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
	
	
    local rowTitle = display.newText( row, sample_articles[i], 0, 0, _W * 0.8, 0, nil, 14 )
    local bullet = display.newImageRect(row, "bullet.png", _W * 0.016, _W * 0.016)
    bullet.anchorX = 0
    bullet.anchorY = 0.5
    rowTitle:setFillColor( 1 )
    
    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    
    rowTitle.x = _W * 0.15
    rowTitle.y = rowHeight * 0.5
    
    bullet.x = _W * 0.1
    bullet.y = rowHeight * 0.5
    
    bullet:setFillColor(1,0.5,0.5)
    row.id = i
    rows[i] = row
    row.alpha = 0
    i = i + 1
end

local function onRowTouch(e)
  local options =
    {
        effect = "fromRight",
        time = 400,
        params = {
          n = e.target.id
        }
    }
    composer.gotoScene("article", options)
end

local function scrollListener(e)
end


local articles_table = widget.newTableView
{
    left = 0,
    top = _H * 0.12,
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
    
    magazine_cover = display.newImageRect("the_mask_cover.png", _W , _H)
    magazine_cover.anchorX = 0
    magazine_cover.anchorY = 0
    magazine_cover.x = 0
    magazine_cover.y = 0
    magazine_cover.alpha = 1
    
    magazine_cover.fill.effect = "filter.blurGaussian"

    magazine_cover.fill.effect.horizontal.blurSize = 12
    magazine_cover.fill.effect.horizontal.sigma = 128
    magazine_cover.fill.effect.vertical.blurSize = 8
    magazine_cover.fill.effect.vertical.sigma = 128
    
    black_cover = display.newRect(0, 0, _W , _H)
    black_cover.anchorX = 0
    black_cover.anchorY = 0
    black_cover.x = 0
    black_cover.y = 0
    black_cover.alpha = 0.6
    black_cover:setFillColor(0.3, 0.3, 0.3)
    black_cover.fill.effect = "filter.vignette"
    black_cover.fill.effect.radius = 1
    
    issue_date = display.newText( "Giugno '15", 0, 0, native.systemFontBold, _W * 0.056 )
    issue_date:setFillColor( 1, 1, 1 )
    issue_date.y = _H * 0.048 + offset * 0.9
    issue_date.x = _W * 0.5
    issue_date.anchorX = 0.5
    issue_date.anchorY = 0
    
    articles_table.y = issue_date.y + issue_date.height + _H * 0.016
    articles_table.anchorY = 0
    
    cancel = display.newImageRect("cancel.png", _W * 0.08 , _W * 0.08)
    cancel.anchorX = 0
    cancel.anchorY = 0.5
    cancel.x = _W * 0.05
    cancel.y = issue_date.y + issue_date.height * 0.5
    cancel.alpha = 1
    
    sceneGroup:insert(magazine_cover)
    sceneGroup:insert(black_cover)
    sceneGroup:insert(issue_date)
    sceneGroup:insert(articles_table)
    sceneGroup:insert(cancel)
    
    for i = 1, 4 do
      articles_table:insertRow(
      {
          --isCategory = isCategory,
          rowHeight = _H * 0.08,
          rowWidth = _W,
          rowColor  = { default={ 0.95,0.95,0.95, 0 }, over={ 159/255, 205/255, 146/255, 0 } },
          lineColor = {0.9, 0.9, 0.9},
          params = {}  -- Include custom data in the row
      })
    end
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        
        cancel:addEventListener("tap", on_click_cancel)
        transition.to(cancel, {alpha = 1, time = 150})
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
        for i = 1, 4 do
          transition.to(rows[i], {alpha = 1, time = 400, delay = i * 40})
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
        cancel:removeEventListener("tap", on_click_cancel)
        for i = 1, 4 do
          transition.to(rows[i], {alpha = 0, time = 150, delay = 0})
        end
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
