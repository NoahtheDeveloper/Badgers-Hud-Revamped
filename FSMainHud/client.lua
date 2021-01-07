--------------------
--- Badssentials ---
--------------------
function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
ann = nil;
announcement = false;
header = Config.AnnouncementHeader;
displayTime = Config.AnnounceDisplayTime;
timer = 0;
anns = {};
RegisterNetEvent('Badssentials:Announce')
AddEventHandler('Badssentials:Announce', function(msg)
	timer = 0;
	announcement = true;
	ann = msg;
	if #ann > 70 then 
		-- Needs to be split up 
		local words = split(ann, " ");
		local charCount = 0;
		local curAnn = "";
		for i = 1, #words do 
			local word = words[i];
			if charCount >= 70 then
				table.insert(anns, curAnn);
				curAnn = "" .. word .. " "; 
				charCount = 0;
			else 
				charCount = charCount + #word;
				curAnn = curAnn .. word .. " ";
			end
		end
		table.insert(anns, curAnn);
	end
end)
function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait((1000)); -- Every second 
		if ann ~= nil and announcement then 
			timer = timer + 1;
			if timer >= displayTime then 
				ann = nil;
				announcement = false;
				timer = 0;
			end
		end
	end
end)
RegisterNetEvent('AOP:PTSound')
AddEventHandler('AOP:PTSound', function()
    PlaySoundFrontend(-1,"CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET",1)
end)

Citizen.CreateThread(function()
	while true do 
		Wait(0);
		if ann ~= nil and announcement then 
			-- 70 character limit per announcement using .8
			Draw2DText(.5, .3, header, 1.5, true);
			--Draw2DText(.5, .5, ann, 0.8, true);
			local cout = .4;
			if #ann > 70 then 
				for i = 1, #anns do 
					Draw2DText(.5, cout, anns[i], 0.8, true);
					cout = cout + .05;
				end
			else 
				Draw2DText(.5, cout, ann, 0.8, true);
			end
		end
	end
end)




tickDegree = 0;
local nearest = nil;
local postals = Postals;
function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
currentTime = "0:00";
RegisterNetEvent('Badssentials:SetTime')
AddEventHandler('Badssentials:SetTime', function(time)
	currentTime = time;
end)
currentDay = 1;
RegisterNetEvent('Badssentials:SetDay')
AddEventHandler('Badssentials:SetDay', function(day)
	currentDay = day;
end)
currentMonth = 1;
RegisterNetEvent('Badssentials:SetMonth')
AddEventHandler('Badssentials:SetMonth', function(month)
	currentMonth = month;
end)
currentYear = "2021";
RegisterNetEvent('Badssentials:SetYear')
AddEventHandler('Badssentials:SetYear', function(year)
	currentYear = year;
end)
peacetime = false;
function ShowInfo(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(true, false)
end
currentAOP = "Sandy Shores"
RegisterNetEvent('Badssentials:SetAOP')
AddEventHandler('Badssentials:SetAOP', function(aop)
	currentAOP = aop;
end)
RegisterNetEvent('Badssentials:SetPT')
AddEventHandler('Badssentials:SetPT', function(pt)
	peacetime = pt;
end)
currentAOP1 = "Sandy Shores"

displaysHidden = false;


RegisterCommand("toggle-hud", function()
	displaysHidden = not displaysHidden;
	TriggerEvent('Badger-Priorities:HideDisplay')
	if displaysHidden then 
		DisplayRadar(false);
	else 
		DisplayRadar(true);
	end
end)
Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/toggle-hud", "Removes the server hud. This helps take clean pictures!", {

    })
    Citizen.Trace(" ")
end)
RegisterCommand("postal", function(source, args, raw)
	if #args > 0 then 
		local postalCoords = getPostalCoords(args[1]);
		if postalCoords ~= nil then 
			-- It is valid 
			SetNewWaypoint(postalCoords.x, postalCoords.y);
			TriggerEvent('chatMessage', Config.Prefix .. "Your waypoint has been set to ^5" .. args[1]);
		else 
			TriggerEvent('chatMessage', Config.Prefix .. "^1[ERROR:] ^0That is not a valid Postal...");
		end
	else 
		SetWaypointOff();
		TriggerEvent('chatMessage', Config.Prefix .. "Your waypoint has been reset!");
	end
end)

Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/postal", "Get a direct waypoint to a postal. ", {

    })
    Citizen.Trace(" ")
end)

function getPostalCoords(postal)
	for _, v in pairs(postals) do 
		if v.code == postal then 
			return {x=v.x, y=v.y};
		end
	end
	return nil;
end
zone = nil;
streetName = nil;
postal = nil;
postalDist = nil;
degree = nil;
Citizen.CreateThread(function()
	while true do 
		Wait(150);
		local pos = GetEntityCoords(PlayerPedId())
		local playerX, playerY = table.unpack(pos)
		local ndm = -1 -- nearest distance magnitude
		local ni = -1 -- nearest index
		for i, p in ipairs(postals) do
			local dm = (playerX - p.x) ^ 2 + (playerY - p.y) ^ 2 -- distance magnitude
			if ndm == -1 or dm < ndm then
				ni = i
				ndm = dm
			end
		end

		--setting the nearest
		if ni ~= -1 then
			local nd = math.sqrt(ndm) -- nearest distance
			nearest = {i = ni, d = nd}
		end
		postal = postals[nearest.i].code;
		postalDist = round(nearest.d, 2);
		local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
		zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z));
		degree = degreesToIntercardinalDirection(GetCardinalDirection());
		streetName = GetStreetNameFromHashKey(var1);
	end 
end)
Citizen.CreateThread(function()
	Wait(800);
	while true do 
		Wait(0);
		if peacetime then 
			if IsControlPressed(0, 106) then
                ShowInfo("~r~Please keep the RP Realistic")
            end
            SetPlayerCanDoDriveBy(player, false)
            
            DisableControlAction(0, 140) -- Melee R
		end
		for _, v in pairs(Config.Displays) do 
			local x = v.x;
			local y = v.y;
			local enabled = v.enabled;
			if enabled and not displaysHidden then 
				local disp = v.display;
				if (disp:find("{NEAREST_POSTAL}") or disp:find("{NEAREST_POSTAL_DISTANCE}")) then 
					disp = disp:gsub("{NEAREST_POSTAL}", postal);
					disp = disp:gsub("{NEAREST_POSTAL_DISTANCE}", postalDist)
				end
				if (disp:find("{STREET_NAME}")) then 
					disp = disp:gsub("{STREET_NAME}", streetName);
				end 
				if (disp:find("{CITY}")) then 
					disp = disp:gsub("{CITY}", zone);
				end
				if (disp:find("{COMPASS}")) then 
					disp = disp:gsub("{COMPASS}", degree);
				end
				disp = disp:gsub("{PST_TIME}", currentTime);
				disp = disp:gsub("{US_DAY}", currentDay);
				disp = disp:gsub("{US_MONTH}", currentMonth);
				disp = disp:gsub("{US_YEAR}", currentYear);			
				disp = disp:gsub("{CURRENT_AOP}", currentAOP);
			
				if (disp:find("{PEACETIME_STATUS}")) then 
					if peacetime then 
						disp = disp:gsub("{PEACETIME_STATUS}", "~g~Enabled")
					else 
						disp = disp:gsub("{PEACETIME_STATUS}", "~r~Disabled")
					end
				end
				local scale = v.textScale;
				Draw2DText(x, y, disp, scale, false);
			end
			tickDegree = tickDegree + 9.0;
		end
	end
end)

function GetCardinalDirection()
	local camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
    local playerHeadingDegrees = 360.0 - ((camRot.z + 360.0) % 360.0)
    local tickDegree = playerHeadingDegrees - 180 / 2
    local tickDegreeRemainder = 9.0 - (tickDegree % 9.0)
   
    tickDegree = tickDegree + tickDegreeRemainder
    return tickDegree;
end
function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return " E "
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "SE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return " S "
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SW"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return " W "
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "NW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return " N "
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NE"
	end
end

-- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS  SCRIPT---- COMPASS--









function drawText( str, x, y, style )
	if style == nil then
		style = {}
	end
	
	SetTextFont( (style.font ~= nil) and style.font or 0 )
	SetTextScale( 0.0, (style.size ~= nil) and style.size or 1.0 )
	SetTextProportional( 1 )
	
	if style.colour ~= nil then
		SetTextColour( style.colour.r ~= nil and style.colour.r or 255, style.colour.g ~= nil and style.colour.g or 255, style.colour.b ~= nil and style.colour.b or 255, style.colour.a ~= nil and style.colour.a or 255 )
	else
		SetTextColour( 255, 255, 255, 255 )
	end
	
	if style.shadow ~= nil then
		SetTextDropShadow( style.shadow.distance ~= nil and style.shadow.distance or 0, style.shadow.r ~= nil and style.shadow.r or 0, style.shadow.g ~= nil and style.shadow.g or 0, style.shadow.b ~= nil and style.shadow.b or 0, style.shadow.a ~= nil and style.shadow.a or 255 )
	else
		SetTextDropShadow( 0, 0, 0, 0, 255 )
	end
	
	if style.border ~= nil then
		SetTextEdge( style.border.size ~= nil and style.border.size or 1, style.border.r ~= nil and style.border.r or 0, style.border.g ~= nil and style.border.g or 0, style.border.b ~= nil and style.border.b or 0, style.border.a ~= nil and style.shadow.a or 255 )
	end
	
	if style.centered ~= nil and style.centered == true then
		SetTextCentre( true )
	end
	
	if style.outline ~= nil and style.outline == true then
		SetTextOutline()
	end
	
	SetTextEntry( "STRING" )
	AddTextComponentString( str )
	
	DrawText( x, y )
end

function degreesToIntercardinalDirection( dgr )
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return "N "
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "NE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return "E"
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SE"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return "S"
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "SW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return "W"
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NW"
	end
end





local compass = { cardinal={}, intercardinal={}}

-- Configuration. Please be careful when editing. It does not check for errors.
compass.show = true
compass.position = {x = 0.5, y = 0.006, centered = true}
compass.width = 1
compass.fov = 180
compass.followGameplayCam = true

compass.ticksBetweenCardinals = 9.0
compass.tickColour = {r = 0, g = 0, b = 0, a = 255}
compass.tickSize = {w = 0.002, h = 0.006}

compass.cardinal.textSize = 0.25
compass.cardinal.textOffset = 0.015
compass.cardinal.textColour = {r = 255, g = 255, b = 255, a = 255}

compass.cardinal.tickShow = true
compass.cardinal.tickSize = {w = 0.001, h = 0.012}
compass.cardinal.tickColour = {r = 0, g = 0, b = 0, a = 255}

compass.intercardinal.show = true
compass.intercardinal.textShow = true
compass.intercardinal.textSize = 0.3
compass.intercardinal.textOffset = 0.015
compass.intercardinal.textColour = {r = 255, g = 255, b = 255, a = 255}

compass.intercardinal.tickShow = true
compass.intercardinal.tickSize = {w = 0.002, h = 0.006}
compass.intercardinal.tickColour = {r = 0, g = 0, b = 0, a = 255}
-- End of configuration





Citizen.CreateThread( function()
	if compass.position.centered then
		compass.position.x = compass.position.x - compass.width / 2
	end
	
	while compass.show do
		Wait( 0 )
		
		local pxDegree = compass.width / compass.fov
		local playerHeadingDegrees = 0
		
		if compass.followGameplayCam then
			-- Converts [-180, 180] to [0, 360] where E = 90 and W = 270
			local camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
			playerHeadingDegrees = 360.0 - ((camRot.z + 360.0) % 360.0)
		else
			-- Converts E = 270 to E = 90
			playerHeadingDegrees = 360.0 - GetEntityHeading( GetPlayerPed( -1 ) )
		end
		
		local tickDegree = playerHeadingDegrees - compass.fov / 2
		local tickDegreeRemainder = compass.ticksBetweenCardinals - (tickDegree % compass.ticksBetweenCardinals)
		local tickPosition = compass.position.x + tickDegreeRemainder * pxDegree
		
		tickDegree = tickDegree + tickDegreeRemainder
		
		while tickPosition < compass.position.x + compass.width do
			if (tickDegree % 90.0) == 0 then
				-- Draw cardinal
				if compass.cardinal.tickShow then
					DrawRect( tickPosition, compass.position.y, compass.cardinal.tickSize.w, compass.cardinal.tickSize.h, compass.cardinal.tickColour.r, compass.cardinal.tickColour.g, compass.cardinal.tickColour.b, compass.cardinal.tickColour.a )
				end
				
				drawText( degreesToIntercardinalDirection( tickDegree ), tickPosition, compass.position.y + compass.cardinal.textOffset, {
					size = compass.cardinal.textSize,
					colour = compass.cardinal.textColour,
					outline = true,
					centered = true
				})
			elseif (tickDegree % 45.0) == 0 and compass.intercardinal.show then
				-- Draw intercardinal
				if compass.intercardinal.tickShow then
					DrawRect( tickPosition, compass.position.y, compass.intercardinal.tickSize.w, compass.intercardinal.tickSize.h, compass.intercardinal.tickColour.r, compass.intercardinal.tickColour.g, compass.intercardinal.tickColour.b, compass.intercardinal.tickColour.a )
				end
				
				if compass.intercardinal.textShow then
					drawText( degreesToIntercardinalDirection( tickDegree ), tickPosition, compass.position.y + compass.intercardinal.textOffset, {
						size = compass.intercardinal.textSize,
						colour = compass.intercardinal.textColour,
						outline = true,
						centered = true
					})
				end
			else
				-- Draw tick
				DrawRect( tickPosition, compass.position.y, compass.tickSize.w, compass.tickSize.h, compass.tickColour.r, compass.tickColour.g, compass.tickColour.b, compass.tickColour.a )
			end
			
			-- Advance to the next tick
			tickDegree = tickDegree + compass.ticksBetweenCardinals
			tickPosition = tickPosition + pxDegree * compass.ticksBetweenCardinals
		end
	end
end)


RegisterCommand("toggle-hud", function()
	displaysHidden = not displaysHidden;
	TriggerEvent('Badger-Priorities:HideDisplay')
	if displaysHidden then 
		DisplayRadar(false);
	else 
		DisplayRadar(true);
	end
end)
Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/toggle-hud", "Removes the server hud. This helps take clean pictures!", {

    })
    Citizen.Trace(" ")
end)