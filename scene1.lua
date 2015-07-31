---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local _W = display.viewableContentWidth
local _H = display.contentHeight

-- show status bar for iPhones

local composer = require( "composer" )
local widget = require( "widget" )
local json = require( "json" )
local sqlite = require( "sqlite3" )
local GameThrive = require "plugin.GameThrivePushNotifications"

-- This function gets called when the player opens a notification or one is received when the app is open and active.
function DidReceiveRemoteNotification(message, additionalData, isActive)
    timer.performWithDelay(1500, function() native.showAlert( "The Mask", message, { "OK"} ) end)
end


local GameThrive = require("plugin.GameThrivePushNotifications")
GameThrive.Init("cb151ace-36fa-11e5-865d-4f1fd150547d", "449299554154", DidReceiveRemoteNotification)

local orange = {255/255, 85/255, 1/255}

local options = {
    width = 12,
    height = 12,
    numFrames = 12,
    sheetContentWidth = 144,
    sheetContentHeight = 12
}

local spinnerMultiSheet = graphics.newImageSheet( "spinner.png", options )

local spinner = widget.newSpinner
{
    x = _W * 0.5,
    y = _H * 0.2,
    width = _W * 0.02,
    height = _W * 0.02,
    sheet = spinnerMultiSheet,
    startFrame = 1,
    count = 12,
    time = 800
}
spinner.alpha = 0

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
local shadow
local social_media
local social_media_icon_size = _W * 0.079
local params = {}
params.progress = true

local latest_issue_articles = {}
local latest_categories = {}
local latest_links = {}
local latest_summaries = {}
local img_link
local issue_title
local completed_count = 0
local to_download = 0

local issue_articles = {}
local issue_summaries = {}
local issue_names = {}
local issue_categories = {}
local issue_images = {}
local issue_links = {}

local is_content_downloaded = false

--------------------------------------------------------------------------------
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

local function on_click_social(e)
	system.openURL( e.target.link )
	return true
end

local function on_click_btn()
    local options =
    {
        effect = "fromTop",
        time = 400,
        params = {
          articles = latest_issue_articles,
          img = img_link,
          title = string.gsub(issue_names[1], "_", " "),
          categories = latest_categories,
          links = latest_links,
          summaries = latest_summaries
        }
    }
    composer.gotoScene("read", options)
end

local function on_click_archivio()
    local options =
    {
        effect = "fromBottom",
        time = 400,
        params = {
          issue_names = issue_names,
          issue_links = issue_links,
          issue_summaries = issue_summaries,
          issue_images = issue_images,
          issue_articles = issue_articles,
          issue_categories = issue_categories
        }
        
    }
    composer.gotoScene("archive", options)
end

local function stop_spinner()
  print("Stop")
  latest_issue_btn:addEventListener("tap", on_click_btn)
  archivio_numeri_txt:addEventListener("tap", on_click_archivio)
  spinner:stop()
  spinner.alpha = 0
  transition.to(latest_issue_btn, {alpha = 1, time = 200})
  transition.to(archivio_numeri_txt, {alpha = 1, time = 200})
end

local function get_latest()
  local path = system.pathForFile("db.sqlite", system.DocumentsDirectory);
	local db = sqlite.open(path);
  local table_name

	for row in db:nrows("SELECT * FROM issues WHERE id = (SELECT MAX(id) FROM issues)") do
    table_name = row.name
  end
  
  local i = 1
  for article in db:nrows("SELECT * FROM "..table_name) do
    latest_issue_articles[i] = article.title
    latest_categories[i] = article.category
    latest_links[i] = article.html_link
    latest_summaries[i] = article.summary
    i = i + 1
  end
end


local function create_content()
  local path = system.pathForFile("db.sqlite", system.DocumentsDirectory);
	local db = sqlite.open(path);
  
  local k = 1
	for issue in db:nrows("SELECT * FROM issues ORDER BY id DESC") do
    local issue_name = issue.name
    issue_names[k] = issue_name
    issue_images[k] = issue.link
    local articles = {}
    local summaries = {}
    local categories = {}
    local links = {}
    
    local l = 1
    for article in db:nrows("SELECT * FROM "..issue_name) do
      articles[l] = article.title
      categories[l] = article.category
      links[l] = article.html_link
      summaries[l] = article.summary
      l = l + 1
    end
    
    issue_articles[k] = articles
    issue_categories[k] = categories
    issue_links[k] = links
    issue_summaries[k] = summaries
    k = k + 1
  end
  
  db:close()
  
  --show_content()
  for i = 1, #latest_issue_articles do
    print(latest_issue_articles[i])
  end
  print(89)
  completed_count = completed_count + 1
  if completed_count == to_download then
    print("Getting Latest")
    get_latest()
    stop_spinner()
    is_content_downloaded = true
  end
end

local function article_networkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed" )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        print( "HTML!" )
        
    end
end

local function img_networkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed" )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        print("Image downloaded")
        create_content()
    end
end

local function decode_issue(response)
  local json_response = json.decode(response)
  local infos = json_response["info"]
  local n = tonumber(infos["n"])
  local img = infos["img"]
  img_link = img
  local id = infos["id"]

  local date = infos["date"]
  issue_title = date
  
  local articles = json_response["articles"]

	date = string.gsub(date, " ", "_")
	local path = system.pathForFile("db.sqlite", system.DocumentsDirectory);
	local db = sqlite.open(path);

	db:exec("CREATE TABLE IF NOT EXISTS "..date.." (id INTEGER PRIMARY KEY, title TEXT UNIQUE, html_link TEXT, category TEXT, summary TEXT);")
  
  local query = "INSERT INTO "..date.." (title, html_link, category, summary) VALUES " 
	
  for i = 1, n do
    if i ~= n then
      query = query.."('"..articles[tostring(i)]["title"].."','"..articles[tostring(i)]["link"].."','"..articles[tostring(i)]["category"].."','"..articles[tostring(i)]["summary"].."'),"
    else
      query = query.."('"..articles[tostring(i)]["title"].."','"..articles[tostring(i)]["link"].."','"..articles[tostring(i)]["category"].."','"..articles[tostring(i)]["summary"].."');"
    end
  end
  print(query)
  db:exec(query)
  db:exec("INSERT INTO issues (id, name, link) VALUES ("..id..",'"..date.."', '"..img.."');")
  db:close()
  
  for i = 1, n do
    if not does_exist(articles[tostring(i)]["link"]) then
      network.download(
          "https://raw.githubusercontent.com/MrAnonimus/the-mask/master/"..articles[tostring(i)]["link"],
          "GET",
          article_networkListener,
          params,
          articles[tostring(i)]["link"],
          system.DocumentsDirectory
      )
    end
  end
  if not does_exist(img) then
      network.download(
          "https://raw.githubusercontent.com/MrAnonimus/the-mask/master/"..img,
          "GET",
          img_networkListener,
          params,
          img,
          system.DocumentsDirectory
      )
  else
    create_content()
  end
end

local function networkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed" )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        decode_issue(event.response)
    end
end

---------------------------------------------------------------------------------

local function create_social_media_group()
  local g = display.newGroup()
  local fb = display.newImageRect("facebook.png", social_media_icon_size, social_media_icon_size)
  fb.anchorX = 0.5
  fb.anchorY = 0.5
  local insta = display.newImageRect("instagram.png", social_media_icon_size, social_media_icon_size)
  insta.anchorX = 0.5
  insta.anchorY = 0.5
  local ytb = display.newImageRect("vimeo.png", social_media_icon_size, social_media_icon_size)
  ytb.anchorX = 0.5
  ytb.anchorY = 0.5
  
  local icon_offset = _W * 0.15
  
  fb.alpha = 0.7
  insta.alpha = 0.7
  ytb.alpha = 0.7
  
  fb.x = _W * 0.5
  insta.x = _W * 0.5 - icon_offset
  ytb.x = _W * 0.5 + icon_offset
  
  fb.link = "https://facebook.com/themaskmagazine"
  insta.link = "https://instagram.com/themaskmagazine"
  ytb.link = "https://youtube.com/user/themaskmagazine"
  
  fb:addEventListener("tap", on_click_social)
  insta:addEventListener("tap", on_click_social)
  ytb:addEventListener("tap", on_click_social)
  
  g:insert(fb)
  g:insert(insta)
  g:insert(ytb)
  
  return g
  
end

local nextSceneButton


local function dirNetworkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed" )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        for line in event.response:gmatch("[^\r\n]+") do 
          to_download = to_download + 1
          print(to_download)
          network.request( line, "GET", networkListener )
        end
        
    end
end

local function get_data()
  network.request( "https://raw.githubusercontent.com/MrAnonimus/the-mask/master/dir.html", "GET", dirNetworkListener )
end

local function start_spinner()
  latest_issue_btn:removeEventListener("tap", on_click_btn)
  archivio_numeri_txt:removeEventListener("tap", on_click_archivio)
  spinner:start()
  spinner.alpha = 1
  transition.to(latest_issue_btn, {alpha = 0.3, time = 200})
  transition.to(archivio_numeri_txt, {alpha = 0.3, time = 200})
end

function scene:create( event )
    local sceneGroup = self.view
    
    background = display.newRect(0, 0, _W, _H)
    background.x = _W * 0.5
    background.y = _H * 0.5
    background:setFillColor(1)
    

    cover = display.newRect(0, 0, _W, _H * 0.54)
    cover.x = 0
    cover.y = 0
    cover.anchorX = 0
    cover.anchorY = 0
    cover:setFillColor(unpack(orange))
    
    cover.fill.effect = "filter.linearWipe"

    cover.fill.effect.direction = { 1, 1 }
    cover.fill.effect.smoothness = 6
    cover.fill.effect.progress = 1
    
    shadow = display.newImageRect("gradient3.png", _W, _W * 0.02)
    shadow.anchorX = 0.5
    shadow.anchorY = 0
    shadow.rotation = 180
    shadow.x = _W * 0.5
    shadow.y = cover.height + _H * 0.005
    shadow.alpha = 1
    
    latest_issue_btn = display.newRoundedRect(0, 0, _W * 0.4, _W * 0.12, _H * 0.008)
    latest_issue_btn.x = _W * 0.5
    latest_issue_btn.y = _H * 0.66
    latest_issue_btn.anchorX = 0.5
    latest_issue_btn.anchorY = 0.5
    latest_issue_btn:setFillColor(unpack(orange))
    --latest_issue_btn:setStrokeColor(1, 0.45, 0)
    --latest_issue_btn.strokeWidth = 3
    
    the_mask_logo = display.newImageRect("white_logo_mask.png", _W * 0.85, _W * 0.16)
    the_mask_logo.anchorX = 0.5
    the_mask_logo.anchorY = 0
    the_mask_logo.x = _W * 0.5
    the_mask_logo.y = _H * 0.265
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
    
    archivio_numeri_txt = display.newText( "Archivio numeri", 0, 0, native.systemFontBold, _W * 0.034 )
    archivio_numeri_txt:setFillColor( 0.2, 0.2, 0.2)
    archivio_numeri_txt.y = latest_issue_btn.y + _H * 0.09
    archivio_numeri_txt.x = _W * 0.5
    archivio_numeri_txt.anchorX = 0.5
    archivio_numeri_txt.anchorY = 0.5
    
    social_media = create_social_media_group()
    social_media.y = _H * 0.92
    
    spinner.y = (cover.height + latest_issue_btn.y) * 0.5
    
    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
    sceneGroup:insert(background)
    sceneGroup:insert(shadow)
    sceneGroup:insert(cover)
    sceneGroup:insert(latest_issue_btn)
    sceneGroup:insert(the_mask_logo)
    sceneGroup:insert(the_mask_motto)
    sceneGroup:insert(latest_issue_txt)
    sceneGroup:insert(archivio_numeri_txt)
    sceneGroup:insert(social_media)
    sceneGroup:insert(spinner)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        display.setStatusBar( display.TranslucentStatusBar )
        latest_issue_btn:addEventListener("tap", on_click_btn)
        archivio_numeri_txt:addEventListener("tap", on_click_archivio)
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
        if not is_content_downloaded then
          start_spinner()
          get_data()
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
