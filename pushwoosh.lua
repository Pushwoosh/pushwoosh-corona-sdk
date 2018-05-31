
local pushwoosh = {}

local json = require "json"

local pw_app_code = {}

local TAG = "[Pushwoosh] "

local function getTimezoneOffset(ts)
	local utcdate   = os.date("!*t", ts)
	local localdate = os.date("*t", ts)
	localdate.isdst = false -- this is the trick
	return os.difftime(os.time(localdate), os.time(utcdate))
end


local function sendRequest( method, args, success, fail )
	local PW_URL = "https://cp.pushwoosh.com/json/1.3/" .. method

	local function networkListener( event )
		if ( event.isError ) then
			if ( error ~= nil ) then
				error( event )
			end
			print( TAG .. PW_URL .. " request failed: " .. json.encode(event) )
		else
			if ( success ~= nil ) then
				success( event )
			end
			print ( TAG .. PW_URL .. " Response: " .. json.encode(event.response) )
		end
	end

	local jsonvar = {}
	jsonvar = json.encode(args)

	local post = jsonvar 
	local headers = {} 
	headers["Content-Type"] = "application/json"
	headers["Accept-Language"] = "en-US"
	local params = {}
	params.headers = headers
	params.body = post 

	print( TAG .. "Sending request " ..  jsonvar .. " to " .. PW_URL )

	network.request ( PW_URL, "POST", networkListener, params )
end

local function registerDevice( pushToken, app_code )
	local deviceType = 1 -- default to iOS
	if ( system.getInfo("platform") == "android" ) then
			deviceType = 3
	end

	local commands_json = {
		 ["request"] = {
			["application"] = app_code,
			["push_token"] = pushToken,
			["language"] = system.getPreference("ui", "language"),
			["hwid"] = system.getInfo("deviceID"),
			["timezone"] = getTimezoneOffset(os.time()),
			["device_type"] = deviceType
		}
	}

	local function onSuccess( event )
		local registrationEvent = { name="pushwoosh-registration-success" }
		Runtime:dispatchEvent( registrationEvent )
	end

	local function onError( event )
		local registrationEvent = { name="pushwoosh-registration-fail" }
		Runtime:dispatchEvent( registrationEvent )
	end
	  
	sendRequest( "registerDevice", commands_json, onSuccess, onError)
end

local function sendAppOpen( app_code )
	local commands_json = {
		 ["request"] = {
			["application"] = app_code,
			["hwid"] = system.getInfo("deviceID")
		}
	}

	sendRequest( "applicationOpen", commands_json, nil, nil)
end

local function sendPushStat( app_code, hash )
	local commands_json = {
		 ["request"] = {
			["application"] = app_code,
			["hwid"] = system.getInfo("deviceID"),
			["hash"] = hash
		}
	}

	sendRequest( "pushStat", commands_json, nil, nil)
end

local function sendDeliveryMessage( app_code, hash )
	local commands_json = {
		 ["request"] = {
			["application"] = app_code,
			["hwid"] = system.getInfo("deviceID"),
			["hash"] = hash
		}
	}

	sendRequest( "messageDeliveryEvent", commands_json, nil, nil)
end

local function sendStat( event )
	hash = event.p

	if ( hash ~= nil ) then
		-- We cannot track message delivery until user opens it
		-- But if it is opened it is definitely delivered
		sendDeliveryMessage ( pw_app_code, hash )

		sendPushStat( pw_app_code, hash )
	else
		print( TAG .. "Error! Missing hash in push payload" )
	end
end

local function onNotification( event )
	print( TAG .. "onNotification: " .. json.encode(event) )
	if event.type == "remoteRegistration" then
		print( TAG .. "Recived push token: " .. event.token )
 		registerDevice( event.token, pw_app_code )
	elseif ( event.type == "remote" ) then
		-- filter out GCM service notification
		if ( event.androidGcmBundle ~= nil and event.androidGcmBundle.from == "google.com/iid" ) then
			print( TAG .. "Warning! GCM registration token may be invalid. Try reregister with GCM." )
		else
			payload = nil
			alert = nil
			if ( system.getInfo("platform") == "ios" ) then
				payload = json.decode(event.iosPayload)
				alert = payload.aps.alert
			elseif ( system.getInfo("platform") == "android" ) then
				payload = event.androidPayload
				alert = payload.title
			end

			sendStat(payload)

			local notificationEvent = { name="pushwoosh-notification", data=event, payload=payload, alert=alert }
			Runtime:dispatchEvent( notificationEvent )
		end
	end
end

-- public methods --

function pushwoosh.registerForPushNotifications( app_code, launchArgs )
	pw_app_code = app_code

	sendAppOpen( app_code )

	if launchArgs and launchArgs.notification then
		print( TAG .. "Application was launched from a cold start in response to push notification" )
		onNotification( launchArgs.notification )
	end
 
	Runtime:addEventListener( "notification", onNotification )

	-- For iOS, the app must explicitly register for push notifications 
	if ( system.getInfo("platform") == "ios" ) then
		local notifications = require( "plugin.notifications.v2" )
		notifications.registerForPushNotifications()
	end
end

return pushwoosh
