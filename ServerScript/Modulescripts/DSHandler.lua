local DSHandler = {}
--[[
	
	Credits: 
	Dante (selfhood)
	--------------
	so this is my data architecture
	basically: 2 ds key types
	
	1. matchid data
	has data of match table that consists of
	player1 and player2 
	this will then get updated by who's the winner
	winner value will be 1 
	example:
	{
	player1 = 1,  -- player1 won
	player2	
	}
	
	2. Player matches
	each player that's in a match will have a
	match id data for each matches they played
	the key would be player_"userid"
	example:
	player_userid will have a table of matchids
	matches = {
	matchid,
		
	}
	
	
--]]
------- iniializing roblox data storage------
local DS = game:GetService("DataStoreService")
local MatchIDUnranked = DS:GetDataStore("MatchID","Unranked")
local PlayermatchesUnranked = DS:GetDataStore("Players","Unranked")

local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx' --uuid template
local tries = 3
local random = math.random

--[[
	
	my matchid data structure:
	matchdata = { p1=value,p2=value}
	value will be 
	1 = winner
	0 = loser
	
--]]
local function userIDToKey(userid)
	return 'player_'..userid
end
---------datahandle wrapper---------------
local function retryData(dsfunction)
	local try = 0
	local success = true
	local data = nil
	repeat
		try = try+1
		success = pcall(function() data = dsfunction() end)
		if not success then wait(1) end	
	until try > tries or success
	if not success then
		print(success)
		--error("[S]DataStore Failed to connect!")
		--success = false
	end
	return success,data
end
---------get playermatches----------------
function DSHandler.getAsyncPlayermatch(player)
	local data = false
	local success = retryData(function()
		local getData = PlayermatchesUnranked:GetAsync(userIDToKey(player))
		data = getData 
		if data == nil then
			print("[S] Data is nil")
		end
		return true
	end)
	if not success then
		data = false
	end
	return data
end

------------update playermatches------------------
function DSHandler.updateAsyncPlayermatch(playerid,matchid,win)
	local success = retryData(function()
		if win~=nil then
			PlayermatchesUnranked:UpdateAsync(userIDToKey(playerid),function(updateddata)
				table.insert(updateddata,matchid)
				print("[S] Successfully Saved "..playerid.." Playermatch DS")
				return updateddata
			end)
		else
			PlayermatchesUnranked:UpdateAsync(userIDToKey(playerid),function(updateddata)
				table.insert(updateddata,matchid)
				print("[S] Successfully Saved "..playerid.." Playermatch DS")
				return updateddata
			end)
		end
	end)
	return success
end
	
-------------First time data playermatches----------
function DSHandler.setAsyncPlayermatch(player)
	local key = userIDToKey(player)
	local matches = 
	{
		
	}
	local success = retryData(function()
		PlayermatchesUnranked:SetAsync(userIDToKey(player),matches)
	end)

	return success
end
-----------------------------------------------------
local function setAsyncMatchID(matchid,p1,p2)
	local matchdata = 									-- data structure
	{
	p1 = nil,
	p2 = nil
	}
	local success = retryData(function()
		print("[S]Generated MatchID\n"..matchid)
		print("[S] Saving MatchID")
		MatchIDUnranked:SetAsync(matchid,matchdata)
	end)
	return success
end
----------- save matchID data-----
--edit table from matchid key
function DSHandler.updateMatchID(matchid,winner)
	local success = retryData(function()
		MatchIDUnranked:UpdateAsync(matchid,function(updateddata)
			for k,v in pairs(updateddata)do
				if k==winner then
					v = 1	
					return updateddata
				end
			end
		end)
		return true	
	end)
	return success
end
--------------Match id generate UUID---------------
function DSHandler.getMatchID (p1,p2)
	-- generate UUID key yang unique per match 
	math.randomseed(os.time())								-- initialize pseudo generate
	math.random() math.random() math.random()
	local function uuid()
		return (string.gsub(template, '[xy]', function (c)	-- start generating uuid
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
		end))
		
	end
	local id = uuid()
	if setAsyncMatchID(id,p1,p2) then
		print("[S] MatchID Saved")
		spawn(function() 
			if not DSHandler.updateAsyncPlayermatch(p1,id)then
				print("[S] Failed Saving Playermatch")
			end
			end)
		spawn(function() 
			if not DSHandler.updateAsyncPlayermatch(p2,id)then
			print("[S] Failed Saving Playermatch")
			end
			end)
		return id
	else 
		print("[S] Failed Saving MatchID")	
		return "fail"
	end
end
--print(_G.getMatchID().. " test")
--print(_G.getMatchID())




return DSHandler
