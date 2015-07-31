---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- require the composer library
local composer = require "composer"
local sqlite = require "sqlite3"

local path = system.pathForFile("db.sqlite", system.DocumentsDirectory);
local db = sqlite.open(path);

	db:exec("CREATE TABLE IF NOT EXISTS issues (id INTEGER UNIQUE PRIMARY KEY, name TEXT, link TEXT);")
  db:close()

-- load scene1
composer.gotoScene( "scene1" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)