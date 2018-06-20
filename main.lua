
local pushwoosh = require( "pushwoosh" )
local json = require "json"

local background = display.newImage( "pw_logo.png", display.contentCenterX, display.contentCenterY )


local function onNotification( event )
	if event.title == nil then
		event.title = "push notification"
	end
	native.showAlert( event.title, event.alert, { "OK" } )
	print("[Pushwoosh] Received push notification" .. json.encode( event.payload ))
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
