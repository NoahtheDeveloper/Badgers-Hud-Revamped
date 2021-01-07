--------------------
--- Badssentials ---
--------------------
function sendMsg(src, msg)
  TriggerClientEvent('chat:addMessage', src, {args = {Config.Prefix .. msg} });
end


function GetDiscordPermissionSet(src)
	if usingDiscordPerms then
		local identifierDiscord = nil
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				identifierDiscord = v
			end
		end

		if identifierDiscord then
			for i = 1, #discordRoleNames do
				if exports.:IsRolePresent(src, discordRoleNames[i]) then
					return true
				else
					return false
				end
			end
		elseif identifierDiscord == nil then
			print("[NoahsDeveloping] No Discord ID found for '" .. GetPlayerName(src) .. "'")
			return false
		end
	end
end


Citizen.CreateThread(function()
  while true do 
    Wait(1000);
    TriggerClientEvent('Badssentials:SetAOP', -1, currentAOP);
    TriggerClientEvent('Badssentials:SetPT', -1, peacetime);
    local time = format_time(os.time(), "%H:%M", "+01:00", "PST");
    local date = format_time(os.time(), "%m %d %Y", "+01:00", "PST");
    local timeHour = split(time, ":")[1]
    local dateData = split(date, " ");
    TriggerClientEvent('Badssentials:SetMonth', -1, dateData[1])
    TriggerClientEvent('Badssentials:SetDay', -1, dateData[2])
    TriggerClientEvent('Badssentials:SetYear', -1, dateData[3])
    if tonumber(timeHour) > 12 then 
      local timeStr = tostring(tonumber(timeHour) - 12) .. ":" .. split(time, ":")[2]
      TriggerClientEvent('Badssentials:SetTime', -1, timeStr);
    end
    if timeHour == "00" then 
      local timeStr = "12" .. ":" .. split(time, ":")[2]
      TriggerClientEvent('Badssentials:SetTime', -1, timeStr);
    end 
    if timeHour ~= "00" and tonumber(timeHour) <= 12 then 
      TriggerClientEvent('Badssentials:SetTime', -1, time);
    end
  end
end)
peacetime = false;
currentAOP = "Unicom"; -- By default 

RegisterCommand("status", function(source, args, rawCommand)
  local src = source;
if source == 0 or IsPlayerAceAllowed(source, "faxes.aopcmds") or GetDiscordPermissionSet(source) or not usingPerms then
    -- Allowed to use /aop <aop>
    if #args > 0 then 
      currentAOP = table.concat(args, " ");
      sendMsg(src, "You have set the ATC Status to: " .. currentAOP);
      print("^0[^1IN-Log-Status^0] ^1Status has been changed by:^9 '" .. GetPlayerName(src) .. "' ^1to:^9 "  .. currentAOP)
      TriggerClientEvent('Badssentials:SetAOP', -1, currentAOP);
      print("^0[^1IN-Log-Status^0] ^1Discord ID:^9" .. discordId)
    else 
      -- Not enough arguments
      sendMsg(src, "^1ERROR: Proper usage: /status <Airport>");
    end
  end
end)
Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/status", "Changes status", {

    })
    Citizen.Trace(" ")
end)







RegisterCommand("pt", function(source, args, rawCommand)
  local src = source;
if source == 0 or IsPlayerAceAllowed(source, "faxes.aopcmds") or GetDiscordPermissionSet(source) or not usingPerms then
    peacetime = not peacetime;
    TriggerClientEvent('Badssentials:SetPT', -1, peacetime);
    if peacetime then 
      sendMsg(src, "You have set emergencies to ^2ON^7"); 
      print("^0[^1IN-Log-PT^0]  ^1Emergencies have been toggled to ^9Enabled^1 by: ^9'" .. GetPlayerName(src) .. "'")
    else 
      sendMsg(src, "You have set emergencies to ^1OFF^7");
      print("^0[^1IN-Log-PT^0]  ^1Emergencies have been toggled to ^9Disabled^1 by: ^9'" .. GetPlayerName(src) .. "'")
    end
  end
end)
Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/pt", "Emergency enable and disable command.", {

    })
    Citizen.Trace(" ")
end)


function split(source, sep)
    local result, i = {}, 1
    while true do
        local a, b = source:find(sep)
        if not a then break end
        local candidat = source:sub(1, a - 1)
        if candidat ~= "" then 
            result[i] = candidat
        end i=i+1
        source = source:sub(b + 1)
    end
    if source ~= "" then 
        result[i] = source
    end
    return result
end
function format_time(timestamp, format, tzoffset, tzname)
   if tzoffset == "local" then  -- calculate local time zone (for the server)
      local now = os.time()
      local local_t = os.date("*t", now)
      local utc_t = os.date("!*t", now)
      local delta = (local_t.hour - utc_t.hour)*60 + (local_t.min - utc_t.min)
      local h, m = math.modf( delta / 60)
      tzoffset = string.format("%+.4d", 100 * h + 60 * m)
   end
   tzoffset = tzoffset or "PST"
   format = format:gsub("%%z", tzname or tzoffset)
   if tzoffset == "PST" then
      tzoffset = "+0000"
   end
   tzoffset = tzoffset:gsub(":", "")

   local sign = 1
   if tzoffset:sub(1,1) == "-" then
      sign = -1
      tzoffset = tzoffset:sub(2)
   elseif tzoffset:sub(1,1) == "+" then
      tzoffset = tzoffset:sub(2)
   end
   tzoffset = sign * (tonumber(tzoffset:sub(1,2))*60 +
tonumber(tzoffset:sub(3,4)))*60
   return os.date(format, timestamp + tzoffset)
end



























