--[[
	* Copyright (c) 2019 by Antoine Desmarets.
	* Cixi of Remulos Oceanic / WoW Classic
	*
	* Puggle is distributed in the hope that it will be useful and entertaining,
	* but WITHOUT ANY WARRANTY
]]--


local version = "2.1"  --change here, and in TOC
local reqPrefix = "Puggle;"
local dispFrequency = 5  -- display refresh every x seconds
local whoFrequency = 10  -- seconds before allowing another /who
local idleTimeout = 300	 --remove entries after x seconds

--local wholib		--library to process /who requests

local _G = getfenv(0)

local users = {}
local zones = {}
local nbUsers = 0

local frames = {} --frames created (to reuse them later)
local groupframes = {} --frames created (to reuse them later)
local playerframes = {} --frames created (to reuse them later)

local dungeonNames = {}
-- Name defaults
dungeonNames["VC"] = 	"死亡矿井"
dungeonNames["WC"] = 	"哀嚎洞穴"
dungeonNames["RFC"] = 	"怒焰裂谷"
dungeonNames["SFK"] = 	"影牙城堡"
dungeonNames["STK"] = 	"监狱"
dungeonNames["BFD"] = 	"黑暗深渊"
dungeonNames["GNO"] = 	"诺莫瑞根"
dungeonNames["RFK"] = 	"剃刀沼泽"
dungeonNames["SMG"] = 	"血色修道院: 墓地"
dungeonNames["SML"] = 	"血色修道院: 图书馆"
dungeonNames["SMA"] = 	"血色修道院: 武器库"
dungeonNames["SMC"] = 	"血色修道院: 大教堂"
dungeonNames["RFD"] = 	"剃刀高地"
dungeonNames["ULD"] = 	"奥达曼"
dungeonNames["ZF"] = 	"祖尔法拉克"
dungeonNames["MAR"] = 	"玛拉顿"
dungeonNames["ST"] = 	"沉没的神庙"
dungeonNames["BRD"] = 	"黑石深渊"
dungeonNames["DME"] = 	"厄运之槌: 东"
dungeonNames["DMN"] = 	"厄运之槌: 北"
dungeonNames["DMW"] = 	"厄运之槌: 西"
dungeonNames["STL"] = 		"斯坦索姆: 血色区"
dungeonNames["STU"] = 	"斯坦索姆: DK区"
dungeonNames["SCH"] = 	"通灵学院"
dungeonNames["LBRS"] = 	"黑石塔下层"
dungeonNames["UBRS"] = 	"黑石塔上层"
dungeonNames["ONY"] = 	 "奥妮克希亚巢穴"
dungeonNames["MC"] = 		"熔火之心"
dungeonNames["ZG"] = 		"祖尔格拉布"
dungeonNames["AQ20"] = 	"安琪拉废墟"
dungeonNames["BWL"] = 	"黑翼之巢"
dungeonNames["AQ40"] = 	"安其拉神殿"
dungeonNames["NAX"] = 	"纳克萨玛斯"
dungeonNames["WSG"] = 	"战歌峡谷"
dungeonNames["AB"] = 		"阿拉希盆地"
dungeonNames["AV"] = 		"奥特兰克山谷"
dungeonNames["MISC"] = 	"其他" 

dungeonNames["BT"] = 	"黑色神庙"
dungeonNames["HS"] = 	"海山"
dungeonNames["ZAM"] = 	"祖阿曼"
dungeonNames["DS"] = 	"毒蛇神殿"
dungeonNames["KLZ"] = 	"卡拉赞"
dungeonNames["WL"] = 	"奴隶围栏"
dungeonNames["SW"] = 	"太阳井高地"
dungeonNames["FB"] = 	"风暴要塞"
dungeonNames["18M"] = 	"黑色沼泽"
dungeonNames["GLR"] = 	"格鲁尔巢穴"
dungeonNames["ZQ"] = 	"蒸汽地窖"
dungeonNames["jjc"] = 	"竞技场"
dungeonNames["ZZ"] = 	"幽暗沼泽"


local dungeonTags = {}
-- Search tags defaults
dungeonTags["RFC"] = 	{ "怒焰", "NY","怒焰裂谷", "怒焰峡谷"} 
dungeonTags["WC"] = 	{ "哀嚎", "AH", "哀嚎洞穴"} 
dungeonTags["VC"] = 	{ "SW", "SK", "死矿", "死亡矿井"} 
dungeonTags["SFK"] = 	{ "影牙", "YY"} 
dungeonTags["STK"] = 	{ "监狱", "JY"} 
dungeonTags["BFD"] = 	{ "黑暗深渊"} 
dungeonTags["GNO"] =  	{"矮子", "诺莫瑞根"} 
dungeonTags["RFK"] = 	{"剃刀沼泽", "剃刀"} 
dungeonTags["SMG"] = 	{"血色", "墓地"} 
dungeonTags["SML"] = 	{"血色", "图书馆"} 
dungeonTags["SMA"] = 	{"血色", "武器库", "兵器库"} 
dungeonTags["SMC"] =  	{"血色", "教堂", "大教堂"}
dungeonTags["RFD"] = 	{"剃刀", "高地"} 
dungeonTags["ULD"] = 	{"奥达曼", "ADM", "adm"} 
dungeonTags["ZF"] = 		{ "祖尔", "祖尔法拉克"} 
dungeonTags["MAR"] = 	{"玛拉顿", "mara", "MLD", "mld" } 
dungeonTags["ST"] = 	 	{ "神庙"} 
dungeonTags["BRD"] = 	{"黑石", "黑石深渊", "深渊"}
dungeonTags["DME"] =  	{"厄运", "东"}
dungeonTags["DMN"] = 	{"厄运", "北"}
dungeonTags["DMW"] = 	{"厄运", "西"}
dungeonTags["STL"] = 	{"stsm", "血色区", "STSM"}
dungeonTags["STU"] = 	{"stsm", "DK", "STSM"}
dungeonTags["SCH"] = 	{"通灵"}
dungeonTags["LBRS"] = 	{"黑下"}
dungeonTags["UBRS"] =  {"黑上"}
dungeonTags["ONY"] = 	{"onyxia", "ony"}
dungeonTags["MC"] = 		{"molten", "core", "mc"}
dungeonTags["ZG"] = 	 	{"zg", "gurub", "zul'gurub", "zulgurub"}
dungeonTags["AQ20"] = 	{"ruins", "aq20"}
dungeonTags["BWL"] = 	{"blackwing", "lair", "bwl"}
dungeonTags["AQ40"] =  {"temple", "aq40"}
dungeonTags["NAX"] = 	{"naxxramas", "nax", "naxx"}
dungeonTags["WSG"] = 	{"wsg", "warsong"}
dungeonTags["AB"] = 		{"ab", "arathi", "basin"}
dungeonTags["AV"] = 		{"av", "alterac", "valley"}
dungeonTags["MISC"] = 	{}   
dungeonTags["BT"] = 	{"BT", "黑庙"}
dungeonTags["HS"] = 	{"hs","HS","海山"} 
dungeonTags["ZAM"] = 	{"ZAM","zam", "祖阿曼"}
dungeonTags["DS"] = 	{"DS", "毒蛇", "WMM"}
dungeonTags["KLZ"] = 	{"KLZ", "klz", "卡拉赞"}
dungeonTags["WL"] = 	{"WL", "围栏", "wl"}
dungeonTags["SW"] = 	{"SW", "太阳井", "sw"}
dungeonTags["FB"] = 	{"风暴", "风暴要塞"}
dungeonTags["18M"] = 	{"18m", "18M"}
dungeonTags["GLR"] = {"GLR", "glr","格鲁尔"}
dungeonTags["ZQ"] = {"蒸汽"}
dungeonTags["jjc"] = {"混分",'jjc','JJC','韧','3v3','2v2','3V3','2V2'}
dungeonTags["ZZ"] = {"沼泽"}

local dungeons = {}
-- SortOrder, LvlRange Low, LvlRange High, LvlMin
dungeons["RFC"] = 	{ 1, 	13, 	18, 	8	 }
dungeons["WC"] = 	{ 2, 	17, 	24, 	10 }
dungeons["VC"] = 	{ 3, 	17, 	26, 	10 }
dungeons["SFK"] = 	{ 4,  	22, 	30, 	14 }
dungeons["STK"] = 	{ 5,	24, 	32, 	15 }
dungeons["BFD"] = 	{ 6, 	24, 	32, 	15 }
dungeons["GNO"] = 	{ 7, 	29, 	38, 	19 }
dungeons["RFK"] = 	{ 8, 	29, 	38, 	19 }
dungeons["SMG"] = 	{ 9, 	34, 	45, 	21 }
dungeons["SML"] = 	{ 10, 	36, 	45, 	21 }
dungeons["SMA"] = 	{ 11, 	38, 	45, 	21 }
dungeons["SMC"] = 	{ 12, 	40, 	45, 	21 }
dungeons["RFD"] = 	{ 14,	37, 	46, 	25 }
dungeons["ULD"] = 	{ 15, 	41, 	51, 	30 }
dungeons["ZF"] = 	{ 16, 	42, 	46, 	35 }
dungeons["MAR"] = 	{ 17, 	46, 	55, 	35 }
dungeons["ST"] = 	{ 18, 	50, 	55, 	35 }
dungeons["BRD"] = 	{ 19, 	52, 	60, 	40 }
dungeons["DME"] = 	{ 20, 	55, 	60, 	45 }
dungeons["DMN"] = 	{ 21, 	55, 	60, 	45 }
dungeons["DMW"] = 	{ 22, 	55, 	60, 	45 }
dungeons["STL"] = 	{ 23, 	58, 	60, 	45 }
dungeons["STU"] = 	{ 24, 	58, 	60, 	45 }
dungeons["SCH"] = 	{ 25, 	58, 	60, 	45 }
dungeons["LBRS"] = 	{ 26, 	55, 	60, 	45 }
dungeons["UBRS"] = 	{ 27, 	58, 	60, 	45 }
dungeons["ONY"] = 	{ 28, 	60, 	60, 	50 }
dungeons["MC"] = 	{ 29, 	60, 	60, 	58 }	
dungeons["ZG"] = 	{ 30, 	60, 	60, 	60 }
dungeons["AQ20"] = 	{ 31, 	60, 	60, 	60 }
dungeons["BWL"] = 	{ 32, 	60, 	60, 	60 }
dungeons["AQ40"] = 	{ 33, 	60, 	60, 	60 }
dungeons["NAX"] = 	{ 34, 	60, 	60, 	60 }
dungeons["WSG"] = 	{ 35, 	10, 	60, 	10 }
dungeons["AB"] = 	{ 36, 	20, 	60, 	20 }
dungeons["AV"] = 	{ 37, 	51, 	60, 	51 } 
dungeons["BT"] = 	{ 42, 	70, 	70, 	70	 }
dungeons["HS"] = 	{ 43, 	70, 	70, 	70	 }
dungeons["ZAM"] = 	{ 44, 	70, 	70, 	70	 }
dungeons["MISC"] = 	{ 45, 	70, 	70, 	70	 }
dungeons["DS"] = 	{ 46, 	70, 	70, 	70	 }
dungeons["KLZ"] = 	{ 47, 	70, 	70, 	70	 }
dungeons["WL"] = 	{ 48, 	70, 	70, 	70	 }
dungeons["SW"] = 	{ 49, 	70, 	70, 	70	 }
dungeons["FB"] = 	{ 50, 	70, 	70, 	70	 }
dungeons["18M"] = 	{ 51, 	70, 	70, 	70	 }
dungeons["GLR"] = 	{ 52, 	70, 	70, 	70	 }
dungeons["ZQ"] = 	{ 53, 	70, 	70, 	70	 }
dungeons["jjc"] = 	{ 54, 	70, 	70, 	70	 }
dungeons["ZZ"] = 	{ 54, 	70, 	70, 	70	 }

local searchTags = { "来","=1","=2","=3","=4","=5","=6" }


local playerLevel = 1;

local loadTime = 0	-- time addon loaded
local dispTime = 0	-- time of last UI List display
local whoTime = 0
local elapsed = 0
local whoOk = true 	-- ok to run a /who

local curGroupId = -1	--timestamp/id of the current group
local lastGroupId = -1	--latest grouo id (default to show)
local playerToon = -1	-- current toon being played
local ratingPage = "groupMember"	-- prefix of the star object
local sortPlayersBy = "race"
local sortPlayersAsc = true

local tabShown = 1	--tab currently being shown
-------------------------------------------------------------------------

function Puggle_OnLoad()
	--wholib = wholib or LibStub:GetLibrary("LibWho-2.0", true)
	Puggle_ContainerFrame:RegisterEvent("ADDON_LOADED");				--Initialisation
	Puggle_ContainerFrame:RegisterEvent("CHAT_MSG_CHANNEL");			--Get Puggle requests
	Puggle_ContainerFrame:RegisterEvent("CHAT_MSG_SYSTEM");			--To retrieve /who results		
	Puggle_ContainerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");			--Whenever someone joins/leaves group

--	Puggle_ContainerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA", "GroupChanged")
	Puggle_ContainerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")	
	Puggle_ContainerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");			--To detect entrance into an instance
	Puggle_AdjustScrollSizes() -- in case default size were changed	

end

-------------------------------------------------------------------------

function Puggle_OnEvent(event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg, arg9 = ...
	
	if event == "ADDON_LOADED" and arg1 == "Puggle" then
		DEFAULT_CHAT_FRAME:AddMessage("Puggle v."..version.." by Cixi@Remulos. Type /puggle or /pug to get started,")
		DEFAULT_CHAT_FRAME:AddMessage("or use the minimap button to toggle the app.")
		loadTime = time()
		
		if (Puggle_minimapPos == nil) then Puggle_minimapPos = 30; end
--		if (Puggle_windowHeight== nil) then Puggle_windowHeight = 500; end
--		if Puggle_windowHeight < 500 then Puggle_windowHeight = 500 end
		if (Puggle_showMinimapButton == nil) then Puggle_showMinimapButton = true; end
		if (Puggle_showMessageOnNewRequest == nil) then Puggle_showMessageOnNewRequest = false; end
		if (Puggle_playSoundOnNewRequest== nil) then Puggle_playSoundOnNewRequest = true; end
		if (Puggle_showLevelColorCoding== nil) then Puggle_showLevelColorCoding = true; end
		if (Puggle_showOnlyRelevant== nil) then Puggle_showOnlyRelevant = false; end
		if (Puggle_idleTimeout == nil) then Puggle_idleTimeout = idleTimeout; end
		if (Puggle_sortLatestFirst== nil) then Puggle_sortLatestFirst = false; end
		if (Puggle_allowSendWho== nil) then Puggle_allowSendWho = true; end
				
		--check new install (all variables empty)
		if (Puggle_dungeonTags == nil) then Puggle_dungeonTags = dungeonTags;	end
		if (Puggle_dungeonNames == nil) then Puggle_dungeonNames = dungeonNames;	end
		if (Puggle_searchTags == nil) then Puggle_searchTags = searchTags;	end
		if (Puggle_dungeonShow == nil) then 
			Puggle_dungeonShow = {} 
			for is, s in pairs(Puggle_dungeonNames) do Puggle_dungeonShow[is] = true;	end 
		end
		
		if (Puggle_pastGroups == nil) then Puggle_pastGroups = {};	end
		if (Puggle_pastPlayers == nil) then Puggle_pastPlayers = {};	end
		
		--check updates -- get all customised ones, and add new ones with defaults
		for is, s in pairs(dungeonNames) do if Puggle_dungeonNames[is] == nil then Puggle_dungeonNames[is] = dungeonNames[is]	end end
		for is, s in pairs(dungeonTags) do 
			if Puggle_dungeonTags[is] == nil then Puggle_dungeonTags[is] = dungeonTags[is]	end
			if Puggle_dungeonShow[is] == nil then Puggle_dungeonShow[is] = true	end 
		end

		playerLevel = UnitLevel("player")

		-- add the current toon being played to the list of past players
		for ip, p in pairs(Puggle_pastPlayers) do
			if p.name == UnitName("player") then playerToon = ip end
		end
		--add player to invariable meta if not found
		if playerToon == -1 then
			playerToon = count(Puggle_pastPlayers)+1 --increment Id
			print("Puggle: Adding "..UnitName("player") .. " to Puggle data")
			_, classFile = UnitClass("player")
			_, raceFile = UnitRace("player")
			Puggle_pastPlayers[playerToon] = {}
			Puggle_pastPlayers[playerToon].name = UnitName("player")
			Puggle_pastPlayers[playerToon].class = classFile
			Puggle_pastPlayers[playerToon].race = raceFile   --Scourge, Troll, etc
			Puggle_pastPlayers[playerToon].gender = UnitSex("player")
			Puggle_pastPlayers[playerToon].faction = UnitFactionGroup("player")
			Puggle_pastPlayers[playerToon].player = true
			Puggle_pastPlayers[playerToon].realm = GetRealmName()
		end

		--pingTime = loadTime
		Puggle_MinimapButton_Reposition()
		
		if Puggle_showMinimapButton then Puggle_MinimapButton:Show() else Puggle_MinimapButton:Hide() end
		Puggle_ShowEditTags()
		
		Puggle_loadGroups()
		Puggle_UpdateCurrentGroup() -- in case we are already in a group when we start
	end

	if event == "CHAT_MSG_CHANNEL" then
			Puggle_ProcessRandom(arg1, arg2)
	end
	
	if event == "CHAT_MSG_SYSTEM" then
		--only look at results from /who
		if string.find(arg1, " 等级 ") then
			Puggle_ExtractWho(arg1)
		end
	end
	
	if event == "GROUP_ROSTER_UPDATE" then
		Puggle_loadGroups()
		Puggle_UpdateCurrentGroup()
	end
	
	
	if event == "ZONE_CHANGED_NEW_AREA" then
	end
	

	if event == "PLAYER_ENTERING_WORLD" then
	end
	
end

-------------------------------------------------------------------------

function Puggle_ExtractWho(arg1) 
	arg1 = gsub(arg1, "Night Elf", "NightElf")
	t = split(arg1, " ");
	DEFAULT_CHAT_FRAME:AddMessage("test002: "..arg1)		
	local toon  = string.gsub(t[1], "|", "!")	-- unescape player link
	toon  = string.sub(toon, string.find(toon, "%[") +1, string.len(toon)) -- remove front
	toon  = string.sub(toon, 1, string.find(toon, "%]")-1 ) -- remove back
	
	--find the toons request and update his level/class
	for iu, u in pairs(users) do
		users[iu] = string.gsub(u, toon..":0:0:", toon..":"..t[3]..":"..string.upper(t[5])..":"); 	
	end
	Puggle_UpdateList()
end

-------------------------------------------------------------------------

function Puggle_UpdateCurrentGroup()

	
	if GetRealNumRaidMembers() > 0 then
		--Check if really in a group.
		-- The event triggers even if nobody has acceptd an invite yet
		local inGroup = false
		--for i=1,GetNumGroupMembers() do
		for i=1, 4 do 
			if UnitName("party"..i) ~= nil and UnitName("party"..i) ~= "Unknown" then 
				inGroup = true 
			end
		end

		if inGroup then 
			--if we just joined that group, prepare the group meta
			if curGroupId == -1 then 
				curGroupId = time()

				Puggle_pastGroups[curGroupId] = {}
				Puggle_pastGroups[curGroupId].cmt = ""
				Puggle_pastGroups[curGroupId].loc = GetZoneText()
				Puggle_pastGroups[curGroupId].realm = GetRealmName()
				Puggle_pastGroups[curGroupId].party = {}
				myTabPage2_delete:Disable()
				lastGroupId = curGroupId --if entering a group, make it the new default shown
				UIDropDownMenu_SetText(_G["Puggle_DropDownGroups"], Puggle_pastPlayers[playerToon].name .. " - " .. date("%A %B %d, %Y at %H:%M", lastGroupId) .. " - " .. Puggle_pastGroups[lastGroupId].loc )

			end

			
			-- add me to the group
			Puggle_pastGroups[curGroupId].party[1] = {}
			Puggle_pastGroups[curGroupId].party[1].id = playerToon 
			Puggle_pastGroups[curGroupId].party[1].level = UnitLevel("player") --this might change while in group
			Puggle_pastGroups[curGroupId].party[1].guild = "" -- and so might this
			local guildName = GetGuildInfo("player")
			if guildName ~= nil and guildName ~= "" then 
				Puggle_pastGroups[curGroupId].party[1].guild = guildName 
			end
			Puggle_pastGroups[curGroupId].party[1].star = 0
			Puggle_pastGroups[curGroupId].party[1].cmt = ""
			Puggle_pastGroups[curGroupId].party[1].time = curGroupId
			Puggle_pastGroups[curGroupId].party[1].dur = 0



			-- parse all players in group
			--for i=1,GetNumGroupMembers() do
			for i=1, 4 do 
				if UnitName("party"..i) ~= nil and UnitName("party"..i) ~= "Unknown" then 
					--check if we already got this player's invariable meta
					local pId = -1
					for ip, p in pairs(Puggle_pastPlayers) do
						if p.name == UnitName("party"..i) then pId = ip end
					end
					--add player to invariable meta if not found
					if pId == -1 then
						pId = count(Puggle_pastPlayers)+1 --increment Id
						print("Puggle: Adding "..UnitName("party"..i) .. " to Puggle data")
						_, classFile = UnitClass("party"..i)
						_, raceFile = UnitRace("party"..i)
						Puggle_pastPlayers[pId] = {}
						Puggle_pastPlayers[pId].name = UnitName("party"..i)
						Puggle_pastPlayers[pId].class = classFile
						Puggle_pastPlayers[pId].race = raceFile   --Scourge, Troll, etc
						Puggle_pastPlayers[pId].gender = UnitSex("party"..i)
						Puggle_pastPlayers[pId].faction = UnitFactionGroup("party"..i)
						Puggle_pastPlayers[pId].player = false
						Puggle_pastPlayers[pId].realm = GetRealmName()
					end
					
					-- check if player is already listed in group
					local pInd = -1  --check if doesn't already exist
					for ipp, pp in pairs(Puggle_pastGroups[curGroupId].party) do
						if pp.id == pId then 
							pInd = ipp 
						end
					end

					if pInd == -1 then 
						--new player, add him to the party
						pInd = count(Puggle_pastGroups[curGroupId].party)+1 --increment Id, but check if doesn't already exist
						Puggle_pastGroups[curGroupId].party[pInd] = {}
						Puggle_pastGroups[curGroupId].party[pInd].star = 0
						Puggle_pastGroups[curGroupId].party[pInd].cmt = ""
						Puggle_pastGroups[curGroupId].party[pInd].id = pId 
					end 

					Puggle_pastGroups[curGroupId].party[pInd].level = UnitLevel("party"..i) --this might change while in group
					Puggle_pastGroups[curGroupId].party[pInd].guild = "" -- and so might this
					local guildName = GetGuildInfo("party"..i)
					if guildName == nil then guildName = "" end
					Puggle_pastGroups[curGroupId].party[pInd].guild = guildName 
					if Puggle_pastGroups[curGroupId].party[pInd].time == nil then Puggle_pastGroups[curGroupId].party[pInd].time = curGroupId end
					Puggle_pastGroups[curGroupId].party[pInd].dur = time() - Puggle_pastGroups[curGroupId].party[pInd].time
					
				end
			end

			

			--update location name if step into an instance
			--overwrite with Instance, rather than normal zone
			inInstance, instanceType = IsInInstance()
			if instanceType ~= "none" then 
				Puggle_pastGroups[curGroupId].loc = GetZoneText()
				if lastGroupId == curGroupId then
					UIDropDownMenu_SetText(_G["Puggle_DropDownGroups"], Puggle_pastPlayers[playerToon].name .. " - " .. date("%A %B %d, %Y at %H:%M", lastGroupId) .. " - " .. Puggle_pastGroups[curGroupId].loc )
				end

			end
	
			Puggle_pastGroups[curGroupId].dur = time() - curGroupId
			Puggle_displayGroup(lastGroupId)
		end
	else 
		--not in a group 

		-- did we just leave one?
		if curGroupId ~= -1 then 

			--close off group timer
			Puggle_pastGroups[curGroupId].dur = time() - curGroupId
			--close off group party timers
			for ip, p in pairs(Puggle_pastGroups[curGroupId].party) do
				p.dur = time() - p.time
			end
			lastGroupId = curGroupId
			curGroupId = -1  --group indicator reset
			Puggle_displayGroup(lastGroupId)
			myTabPage2_delete:Enable()
		end
	end
end

-------------------------------------------------------------------------

function Puggle_loadGroups() 

	if Puggle_pastGroups ~= nil and count(Puggle_pastGroups) ~= 0 then 

		Puggle_showMyGroupsInterface()

		-- Create the dropdown, and configure its appearance
		--local dropDown = CreateFrame("FRAME", "Puggle_DropDownGroups", Puggle_ScrollChildFrameGroups, "UIDropDownMenuTemplate")
		local dropDown = _G["Puggle_DropDownGroups"]
		dropDown:SetPoint("CENTER")
		UIDropDownMenu_SetWidth(dropDown, 400)
		UIDropDownMenu_SetText(dropDown, "Select a group event:")

		-- Create and bind the initialization function to the dropdown menu
		UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			if (level or 1) == 1 then


				local realm = GetRealmName()
				-- Display the day groups
				for ig, g in spairs(Puggle_pastGroups, function(t,a,b) 	return a > b end) do

					if g.realm == realm then 
						local me = ""
						for ip, p in pairs(g.party) do 
							if Puggle_pastPlayers[p.id].player then me = Puggle_pastPlayers[p.id].name end 
						end
						info.text = me .. " - " .. date("%A %B %d, %Y at %H:%M", ig) .. " - " .. g.loc 
						info.checked = true
						info.menuList = ig
						info.hasArrow = false
						info.arg1 = ig
						info.func = self.SetValue
						UIDropDownMenu_AddButton(info)
						if lastGroupId == -1 then
							lastGroupId = ig 
							UIDropDownMenu_SetText(dropDown, Puggle_pastPlayers[playerToon].name .. " - " .. date("%A %B %d, %Y at %H:%M", lastGroupId) .. " - " .. Puggle_pastGroups[lastGroupId].loc )
						end
						Puggle_displayGroup(lastGroupId)
					end
				end
				
			end
		end)

		-- Implement the function to change the favoriteNumber
		function dropDown:SetValue(newValue)
			lastGroupId = newValue
			--local gdate = date("*t", newValue)
			UIDropDownMenu_SetText(dropDown, Puggle_pastPlayers[playerToon].name .. " - " .. date("%A %B %d, %Y at %H:%M", lastGroupId) .. " - " .. Puggle_pastGroups[lastGroupId].loc )
			Puggle_displayGroup(lastGroupId)
			CloseDropDownMenus()
		end
	else
		
		Puggle_hideMyGroupsInterface()
	end
end

-------------------------------------------------------------------------

function Puggle_showMyGroupsInterface()
	myTabPage2_nobody:Hide()
	
	if myTabPage2_delete ~= nil then
		myTabPage2_delete:Show()
		myTabPage2_duration:Show()
		myTabPage2_groupComment:Show()
		myTabPage2_commentText:Show()
		myTabPage2_text1:Show()
		Puggle_DropDownGroups:Show()
		Puggle_ScrollFrameGroups:Show()
	end

end

-------------------------------------------------------------------------

function Puggle_hideMyGroupsInterface()

	if myTabPage2_delete ~= nil then
		myTabPage2_delete:Hide()
		myTabPage2_duration:Hide()
		myTabPage2_groupComment:Hide()
		myTabPage2_commentText:Hide()
		Puggle_DropDownGroups:Hide()
		Puggle_ScrollFrameGroups:Hide()
		myTabPage2_text1:Hide()

		myTabPage2_nobody:Show()
	end

end

-------------------------------------------------------------------------

function Puggle_displayGroup(groupId)
	
	if Puggle_pastGroups ~= nil and count(Puggle_pastGroups) ~= 0 then 
		Puggle_showMyGroupsInterface()

		--Hiding all frames
		for i, f in pairs(groupframes) do
			_G[f]:Hide()
		end

		local yy = -10

		myTabPage2_duration:SetText("Duration: " .. formatTime(Puggle_pastGroups[groupId].dur)) --duration
		myTabPage2_commentText:SetText(Puggle_pastGroups[groupId].cmt)
		for ip, p in pairs(Puggle_pastGroups[groupId].party) do
			-- let's find out if we need to create this groupframe or if we can reuse it
			local exist = false
			for _, f in ipairs(groupframes) do if f == "groupMember-"..ip then exist = true end end
			
			if exist == false then 
				CreateFrame("Frame", "groupMember-"..ip, Puggle_ScrollChildFrameGroups, "Puggle_GroupMemberTemplate")
				table.insert(groupframes, "groupMember-"..ip)
			
			end
			local member = Puggle_pastPlayers[p.id]
			_G["groupMember-"..ip.."_last"]:Hide()
			_G["groupMember-"..ip.."_level"]:SetText(p.level)
			_G["groupMember-"..ip.."_name"]:SetText(split(member.name, "-")[1])
			if p.guild ~= "" then _G["groupMember-"..ip.."_guild"]:SetText("< " .. p.guild .. " >") else  _G["groupMember-"..ip.."_guild"]:SetText("") end
			_G["groupMember-"..ip.."_raceIcon"]:SetNormalTexture(Puggle_Icons(member.race, member.gender));
			_G["groupMember-"..ip.."_classIcon"]:SetNormalTexture(Puggle_Icons(member.class, ''));
			if member.player then
				_G["groupMember-"..ip.."_star1"]:Hide()
				_G["groupMember-"..ip.."_star2"]:Hide()
				_G["groupMember-"..ip.."_star3"]:Hide()
				_G["groupMember-"..ip.."_star4"]:Hide()
				_G["groupMember-"..ip.."_star5"]:Hide()
				_G["groupMember-"..ip.."_comment"]:Hide()
			else 
				if p.star == nil then p.star = 0 end
				Puggle_ShowStars(ip, p.star)
			end
			
			_G["groupMember-"..ip]:SetParent(Puggle_ScrollChildFrameGroups)
			_G["groupMember-"..ip]:SetPoint("TOPLEFT", Puggle_ScrollChildFrameGroups, "TOPLEFT", 40, yy);			
			_G["groupMember-"..ip]:Show()
			yy = yy - 35

		end
		Puggle_ScrollChildFrameGroups:SetHeight(-yy)
		Puggle_ScrollChildFrameGroups:SetWidth(676)	
		Puggle_ScrollFrameGroups:SetScrollChild(Puggle_ScrollChildFrameGroups)

	else
		Puggle_hideMyGroupsInterface()
	end 

end 

-------------------------------------------------------------------------

function Puggle_displayPlayers()


	local tempPlayers = {}
	local realm = GetRealmName()
	for ip, p in pairs(Puggle_pastPlayers) do
		if p.player == false and p.realm == realm then -- don't list myself, or toons from other realms

			tempPlayers[ip] = {}
			tempPlayers[ip].name = p.name
			tempPlayers[ip].race = p.race
			tempPlayers[ip].class = p.class
			tempPlayers[ip].gender = p.gender

			--retrieve latest rating/level/guild
			--for ig, g in spairs(Puggle_pastGroups, function(t,a,b) return b > a end) do
			local maxLevel = 0
			local maxTime = 0
			local maxGuild = ""
			local maxStar = 0
			for ig, g in pairs(Puggle_pastGroups) do
				--dont get overwritten
				if tempPlayers[ip].level == "" or tempPlayers[ip].level == nil then
					for igp, gp in pairs(g.party) do
						if gp.id == ip then
							if gp.level > maxLevel then maxLevel = gp.level end
							if ig > maxTime then 
								maxTime = ig 
								maxGuild = gp.guild
								maxStar = gp.star
							end
						end
					end
				end
			end 
			if maxGuild ~= "" then maxGuild = "< " .. maxGuild .. " >" end
			tempPlayers[ip].guild = maxGuild
			tempPlayers[ip].level = maxLevel
			tempPlayers[ip].last = maxTime
			tempPlayers[ip].rating = maxStar
		end
	end


	--Hiding all frame
	for i, f in pairs(playerframes) do
		_G[f]:Hide()
	end

	local yy = -10

	local count = 0

	for ip, p in spairs(tempPlayers, function(t,a,b) 
			if (sortPlayersAsc) then return t[b][sortPlayersBy] > t[a][sortPlayersBy]
			else 	return t[b][sortPlayersBy] < t[a][sortPlayersBy]
			end
		end) do
		-- let's find out if we need to create this playerframe or if we can reuse it
		local exist = false
		for _, f in ipairs(playerframes) do if f == "player-"..ip then exist = true end end
			
		if exist == false then 
			CreateFrame("Frame", "player-"..ip, Puggle_ScrollChildFramePlayers, "Puggle_GroupMemberTemplate")
			table.insert(playerframes, "player-"..ip)
		end
		
		_G["player-"..ip.."_name"]:SetText(split(p.name, "-")[1])
		_G["player-"..ip.."_raceIcon"]:SetNormalTexture(Puggle_Icons(p.race, p.gender));
		_G["player-"..ip.."_classIcon"]:SetNormalTexture(Puggle_Icons(p.class, ''));
		_G["player-"..ip.."_comment"]:Hide()

		_G["player-"..ip.."_level"]:SetText(p.level)
		_G["player-"..ip.."_guild"]:SetText(p.guild) 
		_G["player-"..ip.."_last"]:SetText(""..date("%d %b %y", p.last))
		_G["player-"..ip.."_last"]:Show()
		Puggle_ShowStars(ip, p.rating)

		_G["player-"..ip]:SetParent(Puggle_ScrollChildFramePlayers)
		_G["player-"..ip]:SetPoint("TOPLEFT", Puggle_ScrollChildFramePlayers, "TOPLEFT", 40, yy);			
		_G["player-"..ip]:Show()
		yy = yy - 35
		count = count + 1
	end


	Puggle_ScrollChildFramePlayers:SetHeight(-yy)
	Puggle_ScrollChildFramePlayers:SetWidth(676)	
	Puggle_ScrollFramePlayers:SetScrollChild(Puggle_ScrollChildFramePlayers)

	if count > 0 then
		myTabPage3_nobody:Hide()
	end 
end 

-------------------------------------------------------------------------

function Puggle_ShowStars(pid, nb)
	for i = 1,5 do
		if _G[ratingPage.."-"..pid.."_star"..i] ~= nil then 
			if i <= nb then 
				_G[ratingPage.."-"..pid.."_star"..i]:SetNormalTexture("Interface\\AddOns\\Puggle\\Images\\star-on")
			else 
				_G[ratingPage.."-"..pid.."_star"..i]:SetNormalTexture("Interface\\AddOns\\Puggle\\Images\\star-off")
			end
			_G[ratingPage.."-"..pid.."_star"..i]:Show()
		end
	end
end

-------------------------------------------------------------------------

function Puggle_sortPlayersBy(sortField)
	if sortField == sortPlayersBy then 
		sortPlayersAsc = not sortPlayersAsc 
	else 
		sortPlayersBy = sortField
	end
	Puggle_displayPlayers()
end

-------------------------------------------------------------------------

function Puggle_rateHover(self, nb)
	if ratingPage ~= "player" then
		local s = split(self:GetName(), "_")  --remove "_star" from last bit
		local c = split(s[1], "-")	--retrieve party id 
		local pid = tonumber(c[2])
		if nb == -1 then 
			nb = Puggle_pastGroups[lastGroupId].party[pid].star 
		end --restore saved value
		Puggle_ShowStars(pid, nb)
	end
end

-------------------------------------------------------------------------

function Puggle_ratePlayer(self, nb)
	if ratingPage ~= "player" then
		local s = split(self:GetName(), "_")  --remove "_star" from last bit
		local c = split(s[1], "-")	--retrieve party id 
		local pid = tonumber(c[2])
		Puggle_rateHover(self, nb)

		print("Puggle: Giving " .. nb .. " stars to " .. Puggle_pastPlayers[Puggle_pastGroups[lastGroupId].party[pid].id].name)
		Puggle_pastGroups[lastGroupId].party[pid].star = nb
	end
end

-------------------------------------------------------------------------

function Puggle_updateGroupComment(self)

	if (self:GetText() == nil) then 
		Puggle_pastGroups[lastGroupId].cmt = ""
	else 
		Puggle_pastGroups[lastGroupId].cmt = "" .. self:GetText()
	end
end

-------------------------------------------------------------------------

function Puggle_deleteGroup() 

	StaticPopupDialogs["CONFIRM_DELETE"] = {
		text = "Are you sure you want to delete this group?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			Puggle_pastGroups[lastGroupId] = nil
			lastGroupId = -1
			Puggle_loadGroups() 
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show ("CONFIRM_DELETE")
end

-------------------------------------------------------------------------

function Puggle_addComment(self) 

	local s = split(self:GetName(), "_")  --remove "_star" from last bit
	local c = split(s[1], "-")	--retrieve party id 
	local pid = tonumber(c[2])
	local pInd = 0
	for ip, p in pairs(Puggle_pastGroups[lastGroupId].party) do
		if ip == pid then pInd = p.id 	end
	end

	StaticPopupDialogs["ADD_COMMENT"] = {
		text = "Add a comment for " .. Puggle_pastPlayers[pInd].name,
		button1 = "Save",
		button2 = "Cancel",
		OnShow = function (self, data)
    		self.editBox:SetText(""..Puggle_pastGroups[lastGroupId].party[pid].cmt)
		end,
		OnAccept = function (self, data, data2)
    		local text = self.editBox:GetText()
    		Puggle_pastGroups[lastGroupId].party[pid].cmt = text
		end,
		timeout = 0,
		hasEditBox = true,
		editBoxWidth = 350,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show ("ADD_COMMENT")
end


-------------------------------------------------------------------------

function Puggle_addGroupComment(self) 

	StaticPopupDialogs["ADD_GROUP_COMMENT"] = {
		text = "Add a comment for this group",
		button1 = "Save",
		button2 = "Cancel",
		OnShow = function (self, data)
    		self.editBox:SetText(""..Puggle_pastGroups[lastGroupId].cmt)
		end,
		OnAccept = function (self, data, data2)
    		local text = self.editBox:GetText()
			Puggle_pastGroups[lastGroupId].cmt = text
			myTabPage2_commentText:SetText(text)
		end,
		maxLetters = 400,
		timeout = 0,
		hasEditBox = true,
		editBoxWidth = 350,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show ("ADD_GROUP_COMMENT")
end

-------------------------------------------------------------------------

function Puggle_exportGroupData(self)
	local ser = serialize(Puggle_pastGroups)
	local encoded = enc(ser)

	StaticPopupDialogs["EXPORT_GROUP"] = {
		text = "Copy the text below",
		button1 = "Done",
		OnShow = function (self, data)
    		self.editBox:SetText(""..encoded)
		end,
		timeout = 0,
		hasEditBox = true,
		editBoxWidth = 350,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopup_Show ("EXPORT_GROUP")

end

-------------------------------------------------------------------------

function serialize (o)
	local res = ""
	if type(o) == "number" then
	  res = res .. o
	elseif type(o) == "string" then
		res = res .. string.format("%q", o)
	elseif type(o) == "table" then
		res = res .. "{ "
	  for k,v in pairs(o) do
		res = res .. "  " .. k .. " = "
		res = res .. serialize(v)
		res = res .. ", "
	  end
	  res = res ..  "}"
	else
	  error("cannot serialize a " .. type(o))
	end
	return res
  end

-------------------------------------------------------------------------

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-------------------------------------------------------------------------
-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

-------------------------------------------------------------------------

function Puggle_SetStarSource(source)
	ratingPage = source
	if ratingPage == "groupMember" then 
		Puggle_UpdateCurrentGroup()
	else 
		Puggle_displayPlayers()
	end
end

-------------------------------------------------------------------------

function Puggle_UpdateList()
	
	Puggle_cleanRequests()
	
	--Hiding all frames
	for i, f in pairs(frames) do
		_G[f]:Hide()
		--_G[f]:SetParent(nil)
		--	table.remove(frames, i)
	end
	
	
	
	if (#users == 0) then 
		DEFAULT_CHAT_FRAME:AddMessage("Count of Players: "..#users)	
		myTabPage1_nobody:Show()
		myTabPage1_synopsis:SetText("0 个玩家对下面的副本表示了兴趣 (有些可能被你的设置隐藏):")
		
	else 
		myTabPage1_nobody:Hide()
		zones = {}
		if #users == 1 then myTabPage1_synopsis:SetText("1 个玩家对下面的副本表示了兴趣 (有些可能被你的设置隐藏):")
		else myTabPage1_synopsis:SetText((#users) .. " 个玩家对下面的副本表示了兴趣 (有些可能被你的设置隐藏):")
		end
		
		DEFAULT_CHAT_FRAME:AddMessage("Count of Players: "..#users)	
		for iu, u in pairs(users) do
			-- DEFAULT_CHAT_FRAME:AddMessage("test001: "..u)	
			local chat = split(u, ";")
			--local tag = chat[1]
		
			local player = split(chat[2], ":")
			--local pRoles  = split(chat[3], ":")
			local pSelected = split(chat[4], ":")
			local pTime = chat[6]
			local pElapsed = time() - pTime	--request elapsed time
			-- DEFAULT_CHAT_FRAME:AddMessage("test1: "..chat[4])	
			--Add players to the right zones
			for iz, z in pairs(pSelected) do
				local show = true 
				if (playerLevel < dungeons[z][2] or playerLevel > dungeons[z][3]) and Puggle_showOnlyRelevant then show = false end
		
				if show then 
					-- only show if the user has selected that zone
					if Puggle_dungeonShow[z] then 
						if zones[z] == nil then zones[z] = {} end
						zones[z][#zones[z]+1] = u..";"..pElapsed
					end 
				end 
			end
		end
		
		
		local atLeastOneMisc = false
		
		table.sort(zones)
		local str = ""
		local yy = 0
		
		-- this uses an custom sorting function ordering by zone ascending
		szones = spairs(zones, function(t,a,b) 
			return dungeons[b][1] > dungeons[a][1]
		end)
		
		
		for iz, z in szones do
					
			local ft = nil
			
			-- let's find out if we need to create this tite frame or if we can reuse it
			local exist = false
			for _, f in ipairs(frames) do if f == "title-"..iz then exist = true end end
			
			if exist == false then 
				CreateFrame("Frame", "title-"..iz, Puggle_ScrollChildFrame, "Puggle_TitleTemplate")
				table.insert(frames, "title-"..iz)
			end
			
			local prefix = ""
			local suffix = ""
	
			-- color off those instances the player is not in the level bracket of
			if Puggle_showLevelColorCoding then   --check setting first
				if playerLevel < dungeons[iz][2] then 
					prefix = "|cffff4040"
					suffix = "|r"
				end
				if playerLevel > dungeons[iz][3] then 
					prefix = "|cff00ff00"
					suffix = "|r"
				end
			end
			
			if (iz ~= "MISC") then 
				_G["title-"..iz.."_title"]:SetText(prefix..Puggle_dungeonNames[iz].."  (等级 "..dungeons[iz][2].."-"..dungeons[iz][3]..")"..suffix)
			else 
				_G["title-"..iz.."_title"]:SetText(prefix..Puggle_dungeonNames[iz]..suffix) -- Misc category doesn't need level range
			end
			_G["title-"..iz.."_title"]:SetPoint("TOPLEFT", Puggle_ScrollChildFrame, "TOPLEFT", 40, yy);
			_G["title-"..iz]:Show()
			_G["title-"..iz]:SetParent(Puggle_ScrollChildFrame)
			yy = yy - 20
			
			-- custom sort to show players who have been waiting the most first.
			for is, s in spairs(zones[iz], function(t,a,b) 
					local chata = split(t[a], ";")
					reqTimea = chata[6]
					local chatb = split(t[b], ";")
					reqTimeb = chatb[6]
					--DEFAULT_CHAT_FRAME:AddMessage("Comparing " .. reqTimeb .. " with " .. reqTimea)	
					if Puggle_sortLatestFirst then return reqTimea > reqTimeb end
					return reqTimeb > reqTimea end) do

				local chat = split(s, ";")
				local player = split(chat[2], ":")
				local playername = split(player[1], "-")[1]  --remove realm name
				local pRoles  = split(chat[3], ":")
				local pTime = chat[6]
				local pElapsed = time() - pTime	--request elapsed time
				
				
				--depending on setting, might not show MISC request if not within 5levels of player
				--if not misc or no setting, then go through
				if (iz ~= "MISC") or (player[2] == "0") or (not Puggle_showOnlyRelevant) or (Puggle_showOnlyRelevant and (playerLevel >= player[2] - 5 and playerLevel <= player[2] +5)) then
					
					if iz=="MISC" then atLeastOneMisc = true end  --this is to know whether or not to show the MISC title, or to hide it later on
				
					local exist = false
					for _, f in ipairs(frames) do if f == "toon:"..iz..":"..is then exist = true end end
					if exist == false then 
						CreateFrame("Frame", "toon:"..iz..":"..is, Puggle_ScrollChildFrame, "Puggle_CharTemplate") 
						table.insert(frames, "toon:"..iz..":"..is)
					end 
					_G["toon:"..iz..":"..is]:SetParent(Puggle_ScrollChildFrame)
					if (player[4] == "0" or player[4] == nil) then 
						_G["toon:"..iz..":"..is.."_name"]:SetText(""..playername)
					else 
						_G["toon:"..iz..":"..is.."_name"]:SetText(""..playername .. "  (+" .. player[4] .. ")")
					end
					_G["toon:"..iz..":"..is.."_msg"]:SetText(""..string.sub(chat[3], 1, 55))
					_G["toon:"..iz..":"..is.."_level"]:SetText(""..player[2])
					_G["toon:"..iz..":"..is.."_classIcon"]:SetNormalTexture(Puggle_Icons(player[3], ''));
						
					_G["toon:"..iz..":"..is.."_time"]:SetText(""..formatTime(pElapsed))
					if (UnitName("player") == player[1]) then 
						_G["toon:"..iz..":"..is.."_whisper"]:Disable()
					else 
						_G["toon:"..iz..":"..is.."_whisper"]:Enable()

					end 
					
					if player[2] ~= "0" then 	
						_G["toon:"..iz..":"..is.."_requestWho"]:Hide() 
						_G["toon:"..iz..":"..is.."_classIcon"]:Show() 
					else 
						_G["toon:"..iz..":"..is.."_requestWho"]:Show() 
						if whoOk then _G["toon:"..iz..":"..is.."_requestWho"]:Enable() 
						else _G["toon:"..iz..":"..is.."_requestWho"]:Disable() end
						_G["toon:"..iz..":"..is.."_classIcon"]:Hide() 
					end
							
					_G["toon:"..iz..":"..is]:SetPoint("TOPLEFT", Puggle_ScrollChildFrame, "TOPLEFT", 60, yy);			
					_G["toon:"..iz..":"..is]:Show()
				
					yy = yy - 25
				end
			end
			yy = yy - 15
		end
		
		
		-- check if we removed all MISC requests (because of level filter). If none left, remove title
		if not atLeastOneMisc then 
			if _G["title-MISC"] ~= nil then 
				_G["title-MISC"]:Hide()  -- call in protected mode as there might not be a MISC yet
				yy = yy + 20
			end
		end
		
		Puggle_ScrollChildFrame:SetHeight(-yy)
		Puggle_ScrollChildFrame:SetWidth(676)	
		Puggle_ScrollFrame:SetScrollChild(Puggle_ScrollChildFrame)
	
	end
end 

-------------------------------------------------------------------------

function Puggle_SendWhisper(self)
	local s = split(self:GetName(), ":")
	local c = split(s[3], "_")	--remove "_invite" from last bit
	local ind = tonumber(c[1])
	local chat = split(zones[s[2]][ind], ";")
	local player = split(chat[2], ":")

	ChatFrame_OpenChat("/w "..player[1].." ") --open whisper chat
end

-------------------------------------------------------------------------

function Puggle_ShowEditTags()

	CreateFrame("Frame", "tags_LFG", myTabPage5, "Puggle_EditTagsTemplate")

	_G["tags_LFG_instCode"]:SetText("求组关键字")
	_G["tags_LFG_instName"]:Hide()
	_G["tags_LFG_instName2"]:SetText("    (每个关键字需空格分隔)")
	_G["tags_LFG_instName2"]:Show()
	_G["tags_LFG_pick"]:Hide()
	

	local allTags = "";
	for idt, dt in pairs(Puggle_searchTags) do
		allTags = allTags .. dt .. " "
	end
	_G["tags_LFG_instTags"]:SetText(allTags)
	
	_G["tags_LFG"]:SetPoint("TOPLEFT", myTabPage5, "TOPLEFT", 30, -150);			
	_G["tags_LFG"]:Show()


	local yy = -10	
	--DEFAULT_CHAT_FRAME:AddMessage("Count of Players: "..#users)	
	for id, d in spairs(dungeons, function(t,a,b) 
			return dungeons[b][1] > dungeons[a][1]
		end)
		do

		if id ~= "MISC"  then 
			CreateFrame("Frame", "tags_"..id, Puggle_ScrollChildFrameEditTags, "Puggle_EditTagsTemplate")

			_G["tags_"..id.."_instCode"]:SetText(id)
			if Puggle_dungeonNames[id] == nil then 
				_G["tags_"..id.."_instName"]:SetText(dungeonNames[id])
				_G["tags_"..id.."_pick"]:SetChecked(true)
			else 
				_G["tags_"..id.."_instName"]:SetText(Puggle_dungeonNames[id])
				_G["tags_"..id.."_pick"]:SetChecked(Puggle_dungeonShow[id])
			end
			_G["tags_"..id.."_pickText"]:SetText("显示")
			
	
			
			if Puggle_dungeonTags[id] ~= nil then --safeguarding for newer (empty) dungeons
				allTags = "";
				for idt, dt in pairs(Puggle_dungeonTags[id]) do
					allTags = allTags .. dt .. " "
				end	
				_G["tags_"..id.."_instTags"]:SetText(allTags)
				
				_G["tags_"..id]:SetPoint("TOPLEFT", Puggle_ScrollChildFrameEditTags, "TOPLEFT", 40, yy);			
				_G["tags_"..id]:Show()
			end		
			yy = yy - 40
		end 
	end
	
	Puggle_ScrollChildFrameEditTags:SetHeight(-yy)
	Puggle_ScrollChildFrameEditTags:SetWidth(676)	
	Puggle_ScrollFrameEditTags:SetScrollChild(Puggle_ScrollChildFrameEditTags)

end 

-------------------------------------------------------------------------

function Puggle_ValidateInstName(self) 

	local code = split(self:GetName() , "_")[2]
	
	if (self:GetText() == nil) then 
		Puggle_dungeonNames[code] = dungeonNames[code]
	else 
		if (self:GetText() == "") then 
			Puggle_dungeonNames[code] = dungeonNames[code]
			_G["tags_"..code.."_instName"]:SetText(Puggle_dungeonNames[code])
			print("Puggle: Resetting dungeon name for "..code.. " to its default")
		else
			Puggle_dungeonNames[code] = self:GetText()
		end
	end
end 

-------------------------------------------------------------------------

function Puggle_TogglePickInstance(self) 

	local code = split(self:GetName() , "_")[2]
	Puggle_dungeonShow[code] = self:GetChecked();
end 

-------------------------------------------------------------------------

function Puggle_ValidateInstTags(self) 

	local code = split(self:GetName() , "_")[2]
	local search = false;
	if code == "LFG" then search = true end
	
	if (self:GetText() == nil) then 
		if search then Puggle_searchTags = searchTags
		else Puggle_dungeonTags[code] = dungeonTags[code] end
	else 
		if (self:GetText() == "") then 
			if search then 
				Puggle_searchTags = searchTags
				local allTags = "";
				for idt, dt in pairs(Puggle_searchTags) do allTags = allTags .. dt .. " "	end

				_G["tags_LFG_instTags"]:SetText(allTags)
				print("Puggle: Resetting search tags to their defaults")	
			else 
				Puggle_dungeonTags[code] = dungeonTags[code] 
				local allTags = "";
				for idt, dt in pairs(Puggle_dungeonTags[code]) do allTags = allTags .. dt .. " "	end

				_G["tags_"..code.."_instTags"]:SetText(allTags)
				print("Puggle: Resetting tags for "..code.. " to their defaults")
			end
		else
			if search then 
				Puggle_searchTags = split(self:GetText(), " ")
			else 
				Puggle_dungeonTags[code] = split(self:GetText(), " ") 
			end
		end
	end

end 

-------------------------------------------------------------------------

function formatTime(sec) 

	local minutes, hours
	local str = ""
	if (sec<60) then 
		str = ""..sec.."秒"
	else
		minutes = math.floor(sec/60)
		sec = sec - (minutes*60)
		if (minutes<60) then 
			str =  ""..minutes.."分"
		else 
			hours = math.floor(minutes/60)
			minutes = minutes - (hours*60)
			str = ""..hours.."h"
			if (minutes > 0) then str = str .. " "..minutes.."分" end
		end
		if (sec > 0) then str = str .. " "..sec.."秒" end
	end
	return str
end

-------------------------------------------------------------------------

function Puggle_ProcessRandom(req, sender) 
	--DEFAULT_CHAT_FRAME:AddMessage("" .. sender .. " : " .. req)
	
	local playername = split(sender, "-")[1]
	
	local newUser = true
	local newInst = true
	local userDetails = ""
	local existingReq = -1
	local existingStart = 0
	
	req = string.gsub(req, ";", "%.");		--remove semicolons as they break the string 
	local sel = Puggle_ExtractDungeon(string.lower(req))
	
	--if request is valid, proceed
	if next(sel) ~= nil then
	
		for is, s in pairs(sel) do

			--check if user is already listed
			if (#users==0) then
				--no one there, add it
				newUser = true
				newInst = true
			else
				for iu, u in pairs(users) do
					local chat = split(u, ";")
					local user = split(chat[2], ":")
					local inst = chat[4];
					
					if (playername == user[1]) then
						-- already there, exists
						newUser = false
						userDetails = chat[2]
						if inst == s then
							newInst = false
							existingReq = iu
							existingStart = chat[5]
							break
						end 
					else
						-- new user, add
						newUser = true
						newInst = true
					end
				end
			end
			
			if  (newUser) then 
				users[nbUsers] = reqPrefix..playername..":0:0:0;"..req..";" .. s .. ";"..time()..";"..time() --adding a timestamp of last ping
				nbUsers = nbUsers + 1		
				DEFAULT_CHAT_FRAME:AddMessage("test003 " .. s)
				if Puggle_dungeonShow[s] then 
					if Puggle_showMessageOnNewRequest then DEFAULT_CHAT_FRAME:AddMessage("New Puggle request by " .. playername .. " for " .. Puggle_dungeonNames[s]) end 
					if Puggle_playSoundOnNewRequest then   PlaySoundFile("sound/interface/pickup/putdownring.ogg") end
				end
			
			else 
				--player reapplyin LFG. can be same instance or an new one
				if newInst then
					-- add new request, but no need to get the /who details. retrieve from earlier request
					users[nbUsers] = reqPrefix..userDetails..";"..req..";" .. s .. ";"..time()..";"..time() -- new request
					nbUsers = nbUsers + 1		

					if Puggle_dungeonShow[s] then 
						if Puggle_showMessageOnNewRequest then DEFAULT_CHAT_FRAME:AddMessage("New Puggle request by " .. playername .. " for " .. Puggle_dungeonNames[s]) end 
						if Puggle_playSoundOnNewRequest then   PlaySoundFile("sound/interface/pickup/putdownring.ogg") end				
					end
				else 
					-- refresh timeer and message on current request
					users[existingReq] = reqPrefix..userDetails..";"..req..";" .. s .. ";"..existingStart..";"..time() --refreshing timestamp of last ping
				end
			
			end
		end
		
		Puggle_UpdateList()  --refresh displayed list
	end	
end

-------------------------------------------------------------------------

function Puggle_requestWho(whofor) 
	if whoOk then 
		whoOk = false
		whoTime = time()
		Puggle_UpdateList()

--[[		if wholib then
			wholib:Who("x-".. whofor, {
				queue = wholib.WHOLIB_QUEUE_QUIET,
				flags = 0,
				callback = Puggle_ExtractWhoLibResults
			})
		else
--]]

		if Puggle_allowSendWho then 
			DEFAULT_CHAT_FRAME.editBox:SetText("/who " .. "x-".. whofor) 
			ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0) 
		else
			ChatFrame_OpenChat("/who " .. "x-".. whofor) --open whisper chat
		end
	end
end 

-------------------------------------------------------------------------

function Puggle_requestWhoClicked(self) 

	local s = split(self:GetName(), ":")
	local c = split(s[3], "_")	
	local ind = tonumber(c[1])
	local chat = split(zones[s[2]][ind], ";")
	local player = split(chat[2], ":")
	Puggle_requestWho(player[1]) 
	
end

-------------------------------------------------------------------------

function Puggle_ExtractDungeon(req) 

	local sel = {}
	
	-- req = string.gsub(req, " ", "+");
	-- req = string.gsub(req, "%.", "+");
	-- req = string.gsub(req, ",", "+");
	-- req = string.gsub(req, "%/", "+");
	-- req = string.gsub(req, "'", "+");
	-- req = string.gsub(req, "?", "+");
	-- req = string.gsub(req, "!", "+");
	-- local parts = split(req, "+")
	DEFAULT_CHAT_FRAME:AddMessage("test004 收到字符串:"..req);	
	local valid = false;
	-- Two pass request parsing. lfg tags,  then dungeon
		
	-- First check that this is an actual request for group
	for il, l in pairs(Puggle_searchTags) do --check all LFG tags
		local  start_index, end_index = string.find(req, l)
		if start_index ~= nil and start_index > 0 then
			DEFAULT_CHAT_FRAME:AddMessage("test005 匹配到查询关键字:"..l);	
			valid = true
			break
		end
	end
	
	if valid then  
		for id, d in pairs(dungeons) do --check all dungeons 
		--	for is, s in pairs(d[7]) do --check all acronyms
			-- DEFAULT_CHAT_FRAME:AddMessage("test008 循环没有:"..id);	
			for is, s in pairs(Puggle_dungeonTags[id]) do --check all acronyms

				local  start_index2, end_index2 = string.find(req, s)
				if start_index2 ~= nil and start_index2 > 0 then
					DEFAULT_CHAT_FRAME:AddMessage("test007 匹配到副本关键字:"..s);	
					local found = false
						--check the dungeon isn't already in the selection (prevent dupes like "lfg wailing caverns") 
					for iss, ss in pairs(sel) do --check selection
						if ss == id then found = true end
					end
					if not found then table.insert(sel, id) end
				end
				-- for ip, p in pairs(parts) do
					
				-- 	if (p == s) then 
				-- 		local found = false
				-- 		--check the dungeon isn't already in the selection (prevent dupes like "lfg wailing caverns") 
				-- 		for iss, ss in pairs(sel) do --check selection
				-- 			if ss == id then found = true end
				-- 		end
				-- 		if not found then table.insert(sel, id) end
				-- 	end
				-- end
			end	
		end
		if next(sel) == nil then table.insert(sel, "MISC") end 
		
	end
	
	return sel
end 

-------------------------------------------------------------------------

function Puggle_Show()
		local class, classCode = UnitClass("player");
		-- charName:SetText(UnitName("player"))
		-- charInfo:SetText("Level " ..  UnitLevel("player") .. " " .. class )
		Puggle_ContainerFrame:Show() 

		myTabPage1:Show();
		myTabPage2:Hide();		
		myTabPage3:Hide();		
		myTabPage4:Hide();
		myTabPage5:Hide();
		
		maintitle:SetText("Puggle  v"..version)
		myTabPage4_version:SetText("Version "..version)
		_G["myTabPage4_showMinimapButtonText"]:SetText(myTabPage4_showMinimapButton:GetText())
		_G["myTabPage4_showMessageOnNewRequestText"]:SetText(myTabPage4_showMessageOnNewRequest:GetText())
		_G["myTabPage4_playSoundOnNewRequestText"]:SetText(myTabPage4_playSoundOnNewRequest:GetText())
		_G["myTabPage4_showLevelColorCodingText"]:SetText(myTabPage4_showLevelColorCoding:GetText())
		_G["myTabPage4_sortLatestFirstText"]:SetText(myTabPage4_sortLatestFirst:GetText())
		_G["myTabPage4_showOnlyRelevantText"]:SetText(myTabPage4_showOnlyRelevant:GetText())		
		_G["myTabPage4_allowSendWhoText"]:SetText(myTabPage4_allowSendWho:GetText())		
		
		myTabPage4_showMinimapButton:SetChecked(Puggle_showMinimapButton)
		myTabPage4_showMessageOnNewRequest:SetChecked(Puggle_showMessageOnNewRequest)
		myTabPage4_playSoundOnNewRequest:SetChecked(Puggle_playSoundOnNewRequest)
		myTabPage4_showLevelColorCoding:SetChecked(Puggle_showLevelColorCoding)
		myTabPage4_showOnlyRelevant:SetChecked(Puggle_showOnlyRelevant)
		myTabPage4_sortLatestFirst:SetChecked(Puggle_sortLatestFirst)
		myTabPage4_idleTimeout:SetText(Puggle_idleTimeout)
		myTabPage4_allowSendWho:SetChecked(Puggle_allowSendWho)
		
		myTabPage4_note:SetText("I hope this will help you get a group, while still keep the social element that was\nunfortunately lost with the LFG feature introduced in the later expansions.\n\nQuestions, suggestions, praise or rant can be sent to \124cffffd100\124hCixi@WarcraftRatings.com\124h\124r\nJust remember I did this addon as a fun little project, and am forcing nobody to use it :-)\n\nNo animal was harmed during the development of this addon.\nWell, apart from that kitten I punched while trying to get the scrollframe to work.\n\nSpecial thanks to \124cffffd100\124hKagerX\124h\124r, \124cffffd100\124hRiot\124r, \124cffffd100\124hItzachu\124h\124r, \124cffffd100\124hMauridius\124h\124r and \124cffffd100\124hThawe\124h\124r for their help and ideas.")
			
end

-------------------------------------------------------------------------

function Puggle_Icons(what, gender) 
	local icon = "Interface/Icons/inv_misc_questionmark"
	if (what == "DRUID") 	then icon = "Interface\\Icons\\inv_misc_monsterclaw_04" end
	if (what == "HUNTER") 	then icon = "Interface\\Icons\\inv_weapon_bow_07" end
	if (what == "MAGE") 	then icon = "Interface\\Icons\\inv_staff_13" end
	if (what == "PALADIN") then icon = "Interface\\AddOns\\Puggle\\Images\\class_paladin" end
	if (what == "PRIEST") 	then icon = "Interface\\AddOns\\Puggle\\Images\\class_priest" 	end
	if (what == "ROGUE") 	then icon = "Interface\\AddOns\\Puggle\\Images\\class_rogue" end
	if (what == "SHAMAN") 	then icon = "Interface\\Icons\\spell_nature_bloodlust" end
	if (what == "WARLOCK") then icon = "Interface\\Icons\\spell_nature_drowsy" end
	if (what == "WARRIOR") then icon = "Interface\\Icons\\inv_sword_27" end

	local g = 'male'
	if gender == 3 then g = 'female' end
	if (what == "Dwarf") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_dwarf_"..g end
	if (what == "Gnome") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_gnome_"..g end
	if (what == "Human") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_human_"..g end
	if (what == "NightElf") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_nightelf_"..g end
	if (what == "Orc") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_orc_"..g end
	if (what == "Tauren") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_tauren_"..g end
	if (what == "Troll") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_troll_"..g end
	if (what == "Scourge") then icon = "Interface\\AddOns\\Puggle\\Images\\achievement_character_undead_"..g end
	return icon
end 

-------------------------------------------------------------------------

function Puggle_OnUpdate(self, elapsed)
	--DEFAULT_CHAT_FRAME:AddMessage("Puggle_OnUpdate");
	local dispElapsed = time() - dispTime
	local whoElapsed = time() - whoTime

	if (whoElapsed >= whoFrequency) and not whoOk then 
		whoOk = true
		Puggle_UpdateList()
	end 


	if (dispElapsed >= dispFrequency) then 
		playerLevel = UnitLevel("player")  -- refresh player level in case they ding'd
		dispTime = time()
		Puggle_UpdateList()
		if ratingPage == "groupMember" and curGroupId ~= -1 then 
		--	Puggle_UpdateCurrentGroup()  --comment that as it prevent typing of
			if curGroupId == lastGroupId then -- only refresh the time instead
				Puggle_pastGroups[curGroupId].dur = time() - curGroupId
				myTabPage2_duration:SetText("Ongoing: " .. formatTime(Puggle_pastGroups[curGroupId].dur)) --duration
			end
		--else 
			--Puggle_displayPlayers()
		end
	end 
	
end

-------------------------------------------------------------------------

function Puggle_cleanRequests() 
		
		local toKeep = {}
		local nbToKeep = 0
	
		--Keeping only users that are still pinging, discard others
		for iu, u in pairs(users) do
			local remove = false
			local chat = split(u, ";")
			local player = split(chat[2], ":")
			local reqTime = chat[6]
	
			local reqElapsed = time() - reqTime
		
			--random req, remove after 5min
			if (reqElapsed > tonumber(Puggle_idleTimeout)) then remove = true end
		
			if (not remove) then 
				--DEFAULT_CHAT_FRAME:AddMessage("Keeping ".. player[1] .. "/" .. u)
				toKeep[nbToKeep] = u
				nbToKeep = nbToKeep + 1
			end
		end

		users = toKeep
end

-------------------------------------------------------------------------

function split(str, sep)
	local t = {}
	local ind = string.find(str, sep)
	while (ind ~= nil) do 	
		table.insert(t, string.sub(str, 1, ind-1))
		str = string.sub(str, ind+1)
		ind = string.find(str, sep, 1, true)
	end
	if (str ~="") then table.insert(t, str) end
	return t
end

-------------------------------------------------------------------------

function count(tab)
	Count = 0
	for Index, Value in pairs(tab) do
		--DEFAULT_CHAT_FRAME:AddMessage("parsing: " .. Index)
		Count = Count + 1
	end
	--DEFAULT_CHAT_FRAME:AddMessage("Return: " .. Count)
	return Count
	
end

-------------------------------------------------------------------------

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-------------------------------------------------------------------------

function stringify(tbl, sep)
	local res
	for k, v in pairs(tbl) do
		res = res .. v .. sep
	end
	res = string.sub(res, 1, string.len(sub)-1)
	return res
end

-------------------------------------------------------------------------

function Puggle_ShowResizeMessage(show)

	if show then 
		Puggle_ShowTab(-1)
		Puggle_Resizing:Show()
	else 
		Puggle_Resizing:Hide()
		Puggle_ShowTab(tabShown)
	end
end

-------------------------------------------------------------------------

function Puggle_ShowTab(tab)

	for t = 1, 5 do
		_G["myTabPage" .. t]:Hide()
	end
	if tab ~= -1 then
		 tabShown = tab
		_G["myTabPage" .. tabShown]:Show()
	end 
end 

-------------------------------------------------------------------------

function Puggle_AdjustScrollSizes() 
	local newHeight = Puggle_ContainerFrame:GetHeight()
	Puggle_ScrollFrameEditTags:SetHeight(newHeight - 225)
	Puggle_ScrollFrame:SetHeight(newHeight - 80)
	Puggle_ScrollFrameGroups:SetHeight(newHeight - 270)
	Puggle_ScrollFramePlayers:SetHeight(newHeight - 100)
	Puggle_ScrollFrameEditTags:Show()
end

-------------------------------------------------------------------------

-- Call this in a mod's initialization to move the minimap button to its saved position (also used in its movement)
-- ** do not call from the mod's OnLoad, VARIABLES_LOADED or later is fine. **
function Puggle_MinimapButton_Reposition()
	Puggle_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(Puggle_minimapPos)),(80*sin(Puggle_minimapPos))-52)
end

-- Only while the button is dragged this is called every frame
function Puggle_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	Puggle_minimapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	Puggle_MinimapButton_Reposition() -- move the button
end

-------------------------------------------------------------------------

-- Put your code that you want on a minimap button click here.  arg1="LeftButton", "RightButton", etc
function Puggle_MinimapButton_OnClick()
	--DEFAULT_CHAT_FRAME:AddMessage("Is shown?" .. "was clicked.")
	
	if Puggle_ContainerFrame == nil then 
		Puggle:Show()
	else
		if  myTabPage5:IsShown() then
			myTabPage5:Hide();
			myTabPage4:Show();
		else 						
			if (Puggle_ContainerFrame:IsShown()) then 
				Puggle_ContainerFrame:Hide()
				myTabPage5:Hide();
			else
				Puggle_Show()
			end
		end
	end
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(arg1).." was clicked.")
end

-------------------------------------------------------------------------

-- normal tooltip for options
function Puggle_ShowTooltip(self)
	
	local s = split(self:GetName(), ":")
	local c = split(s[3], "_")	--remove "_invite" from last bit
	local ind = tonumber(c[1])
	local chat = split(zones[s[2] ] [ind], ";")
	local player = split(chat[2], ":")
	local req = chat[3]

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 26, -72	)
	GameTooltip:AddLine(split(player[1], "-")[1])
	GameTooltip:AddLine(req,.8,.8,.8,1)
	GameTooltip:AddLine(" ",.8,.8,.8,1)
	GameTooltip:AddLine("玩家在队列中 ".. formatTime(time()-chat[5]),1,1,1,1)
	GameTooltip:AddLine("最新请求 "..formatTime(time()-chat[6]).." 之前",.6,.6,.6,1)
	GameTooltip:Show()

end 

-------------------------------------------------------------------------

function Puggle_ToggleSound()
	Puggle_playSoundOnNewRequest = not Puggle_playSoundOnNewRequest
	myTabPage4_playSoundOnNewRequest:SetChecked(Puggle_playSoundOnNewRequest)
	if Puggle_playSoundOnNewRequest then print("Puggle: Notification sound ON") else print("Puggle: Notification sound OFF") end
end

-------------------------------------------------------------------------

function Puggle_SlashCommandHandler( msg )
	local args = split(msg, " ")
		
	if args[1] == "sound" then 
		Puggle_ToggleSound()
	else 
		Puggle_MinimapButton_OnClick()
	end
	
end

-------------------------------------------------------------------------

SlashCmdList["Puggle"] = Puggle_SlashCommandHandler
SLASH_Puggle1 = "/puggle"
SLASH_Puggle2 = "/pug"
