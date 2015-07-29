
local pushwoosh = require( "pushwoosh" )
local json = require "json"

local background = display.newImage( "pw_logo.png", display.contentCenterX, display.contentCenterY )


local function onNotification( event )
	native.showAlert( "remote notification", json.encode( event.data ), { "OK" } )
end

local function onRegistrationSuccess( event )
	print( "Registered on Pushwoosh" )
end

local function onRegistrationFail( event )
	native.showAlert( "Notification Registration Failed", "An Error Contacting the Server has Occurred. Please try again later from the application settings.", { "OK" } )                  
end

Runtime:addEventListener( "pushwoosh-notification", onNotification )
Runtime:addEventListener( "pushwoosh-registration-success", onRegistrationSuccess )
Runtime:addEventListener( "pushwoosh-registration-fail", onRegistrationFail )

local launchArgs = ...

pushwoosh.registerForPushNotifications( "PUSHWOOSH_APPLICATION_ID", launchArgs )
