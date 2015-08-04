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
local img_shadow
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
local params = {}
local author
local author_name
local summary
local title_text
local img_path
local category
local social_options

local scrollView = widget.newScrollView
{
    top = 0,
    left = 0,
    width = _W,
    height = _H * 0.895,
    bottomPadding = _H * 0.1
}

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

local function get_content(name)
	local path = system.pathForFile( name, system.DocumentsDirectory )
	local fh = io.open( path, "r" )
  if not fh then
    return ""
  end
	return fh:read( "*a" )
end

local function on_click_fb(e)
  native.showPopup( "social", social_options )
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



local function show_image()

  image = display.newImageRect(img_path, system.DocumentsDirectory, _W , _W * 0.5)
  image.x = 0
  image.y = _H * 0.02 + author.y + author.height
  image.anchorX = 0
  image.anchorY = 0
  image.alpha = 0
  
  img_shadow = display.newImageRect("gradient3.png", _W, _W * 0.02)
  img_shadow.anchorX = 0.5
  img_shadow.anchorY = 0
  img_shadow.rotation = 180
  img_shadow.x = _W * 0.5
  img_shadow.y = image.y + image.height + _H * 0.005
  img_shadow.alpha = 0
  scrollView:insert(img_shadow)
  scrollView:insert(image)
  transition.to(image, {alpha = 1, time = 500, transition = easing.outExpo})
  transition.to(img_shadow, {alpha = 1, time = 500, transition = easing.outExpo})
end

local function img_networkListener( event )
    if ( event.isError ) then
        print( "Network error - download failed" )
    elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
        print("Image downloaded")
        img_path =  event.response.filename
        show_image()
        social:addEventListener("tap", on_click_fb)
    end
end

local function decode_issue(response)
  local json_response = json.decode(response)
  author_name = json_response["author"]
  content = json_response["content"]
  image_link = json_response["link"]
end

local function get_category_title(category)
  if category == "a" then
    return "Arte"
  elseif category == "b" then
    return "Attualità"
  elseif category == "c" then
    return "Cibo"
  elseif category == "d" then
    return "Economia"
  elseif category == "e" then
    return "Editoriale"
  elseif category == "f" then
    return "Film"
  elseif category == "g" then
    return "Locali"
  elseif category == "h" then
    return "Moda"
  elseif category == "i" then
    return "Musica"
  elseif category == "j" then
    return "Rubrica"
  elseif category == "k" then
    return "Scienza"
  elseif category == "l" then
    return "Scuola"
  elseif category == "m" then
    return "Tecnologia"
  else
    return "Viaggi"
  end
end
---------------------------------------------------------------------------------


function scene:create( event )
    local sceneGroup = self.view
    title_text = event.params.title
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
    title.y = _H * 0.02
    title.x = _W * 0.05
    title.anchorX = 0
    title.anchorY = 0
    title.alpha = 1
    
    author = display.newText( "di "..author_name, 0, 0, _W * 0.9, 0, "Roboto Light", _W * 0.034 )
    author:setFillColor( 0.4, 0.4, 0.4)
    author.y = title.y + title.height + _H * 0.015
    author.x = _W * 0.05
    author.anchorX = 0
    author.anchorY = 0
    author.alpha = 1
    
    body = display.newText( content, 0, 0, _W * 0.9, 0, "Roboto Bold", _W * 0.050 )
    body:setFillColor( 0.2, 0.2, 0.2)
    body.y = author.y + author.height + _H * 0.045 + _W * 0.5
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
    
    category = display.newText( get_category_title(event.params.category), 0, 0, native.systemFontBold, _W * 0.05 )
    category:setFillColor(1)
    category.y = social.y
    category.x = _W * 0.5
    category.anchorX = 0.5
    category.anchorY = 0.5
    category.alpha = 1
    
    scrollView.y = divisor.y
    scrollView.height = _H - divisor.y
    scrollView.anchorY = 0
    
    options = {
        service = "facebook",
        message = title_text,
        image = {
            { filename = string.gsub(title_text, " ", "_")..".jpg", baseDir = system.DocumentsDirectory }
        },
        url = "http://themask.liceomascheroni.it/"
    }
    
    sceneGroup:insert(background)
    sceneGroup:insert(shadow)
    sceneGroup:insert(dock)
    sceneGroup:insert(back_icon)
    sceneGroup:insert(social)
    sceneGroup:insert(category)
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
        if not does_exist(string.gsub(title_text, " ", "_")..".jpg") then
          network.download(
                  image_link,
                  "GET",
                  img_networkListener,
                  params,
                  string.gsub(title_text, " ", "_")..".jpg",
                  system.DocumentsDirectory
              )
        else
          img_path =  string.gsub(title_text, " ", "_")..".jpg"
          show_image()
          social:addEventListener("tap", on_click_fb)
        end
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
        social:removeEventListener("tap", on_click_fb)
        back_title:removeEventListener("tap", on_click_back)
        transition.to(social, {alpha = 0, time = 150})
        transition.to(back_icon, {alpha = 0, time = 150})
        transition.to(back_title, {alpha = 0, time = 150})
    elseif phase == "did" then
        -- Called when the scene is now off screen
        
        composer.removeScene("article")
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
