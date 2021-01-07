Config = {
	Prefix = '^1[^0System^1] ^0',
	AnnouncementHeader = '~b~[~b~ Announcement~b~]',
	AnnounceDisplayTime = 15, -- How many seconds should announcements display for?
	Revive_Delay = 0, -- Set to 0 to disable 
	Respawn_Delay = 0, -- Set to 0 to disable 
	Displays = {
		['Noir RP Server | Discord'] = {
			x = .800,
			y = .01,
			display = "~b~Noir RP ~w~| discord.gg/BB68c3d",
			textScale = .55,
			enabled = false
		},
		['Compass Location'] = {
			x = .170,
			y = .85,
			display = "~w~| ~b~{COMPASS} ~w~|",
			textScale = 1.0,
			enabled = true
		},
		['Street Location'] = {
			x = .22,
			y = .855,
			display = "~b~{STREET_NAME}",
			textScale = .45,
			enabled = true
		},
		['City Location'] = {
			x = .22,
			y = .875,
			display = "~w~{CITY}",
			textScale = .45,
			enabled = true
		},
		['Nearest Airport'] = {
			x = .170,
			y = .91,
			display = "~b~Nearest ~b~Airport: ~w~{NEAREST_POSTAL} (~w~{NEAREST_POSTAL_DISTANCE}m~w~)",
			textScale = .4,
			enabled = true
		},
		['Time & Date'] = {
			x = .170,
			y = .93,
			display = "~b~Time (CEST): ~w~{PST_TIME} ~b~| Date: ~w~{US_MONTH}~b~/~w~{US_DAY}~b~/~w~{US_YEAR}",
			textScale = .4,
			enabled = true
		},
		['AOP & PeaceTime'] = {
			x = .170,
			y = .95,
			display = "~b~Current ~b~Status: ~w~{CURRENT_AOP} ~b~| ~w~Emergencies: {PEACETIME_STATUS}",
			textScale = .4,
			enabled = true
		}
		
	


	}
}
Postals = {
{code="SSIA",y=3907,x=1049.71},{code="PIA",y=6735.41,x=1177.79},{code="LSIA",y=-3042.43,x=-1336.76},{code="TIA",y=1719.83,x=3445.58}, {code="LIA",y=6990.83,x=5159.94}
}



    usingDiscordPerms = true
    
	discordRoleNames = {"ATC", "GC", "Staff", "USCG"}