--[[ 
	
	Credits: 
	Dante (selfhood)
	
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RF 				= ReplicatedStorage:WaitForChild("MMRemoteF")
local RE 				= ReplicatedStorage:WaitForChild("MMRemoteE")

----- initializing modulescripts -----
local DSHandler 		= require(script:WaitForChild("DSHandler"))
local QueueHandler 		= require(script:WaitForChild("QueueHandler"))
local Dict 				= require(script:WaitForChild("Dictionary"))
game.Players.CharacterAutoLoads = false
--[[
	0 = sent
	1 = match
	2 = unmatch
	3 = refresh
	4 = inmatch
--]]

---------------------functions----------------------
function unauthorized(player,kickqueue)						
	RE:FireClient(player,Dict[12],5,0)
	warn("[S] "..player.Name..Dict[13])
	if(kickqueue)then
		QueueHandler.RemoveQueue(player)
	end
end
local function HandleDataJoin(player)
	
		local Data = DSHandler.getAsyncPlayermatch(player.UserId)
		if Data==nil then 
				------ First time join insert empty matches table to playermatches Datastore---
			if DSHandler.setAsyncPlayermatch(player.UserId)then
				print("[S] "..player.Name..Dict[1])
			else 
				print("[S] "..player.Name..Dict[2])
				player:Kick(Dict[5])
			end
		elseif not Data then
				print("[S] "..player.Name..Dict[3])
				player:Kick(Dict[5])
		
		elseif Data~=nil then
			print("[S] "..player.Name..Dict[4])
			for k,v in pairs(Data)do
				print(v)
			end
			DSHandler.setAsyncPlayermatch(player.UserId)
		end
	
end
local function HandleGuiJoin(player)
	
	local ui = player:WaitForChild("PlayerGui")
	for _,v in pairs(game.StarterGui:GetChildren())do
		v:Clone().Parent = ui
	end
	
end
----------------------------------------------------
game.Players.PlayerAdded:Connect(function(player)
	HandleDataJoin(player)
	HandleGuiJoin(player)
end)
----------------------Player leaving----------------------------

game.Players.PlayerRemoving:Connect(function(player)
	if(QueueHandler.RemoveQueue(player))then
		QueueHandler.Iterate(nil,player,0)
	end
end)
--------------------update local queue-------------------------


------------------REMOTE FUNCTION ASSIGN TO QUEUE --------------
function RF.OnServerInvoke(player,...)
	
	if(...==1)then
		spawn(function()
			if not QueueHandler.inQueue(player)then				-- not in queue
				QueueHandler.AddQueue(player)
				print("[S] "..player.Name ..Dict[6])
				QueueHandler.Iterate(player,player,0)				-- send other player in queued that there's a new player
				--RE:FireClient() 

			else
				--unauthorized RF invoke----
				unauthorized(player,true)
				
			end
		wait()
		end)	
	elseif(...==2)then
		spawn(function()
			if(QueueHandler.RemoveQueue(player))then
				QueueHandler.Iterate(nil,player,0)
			end
			print("[S]"..player.Name ..Dict[7])
		end)
		return 0
	else
		----unauthorized unidentified rf invoke--
		unauthorized(player,false)
	end
		
end
--=======================================================================---
--[[----------------REMOTE EVENT QUEUED PLAYERS ------------------------------
	
	DEPRECATED
RE.OnServerEvent:connect(function(player, req, ...)
	wait()
	spawn(function()		
		if QueueHandler.inQueue(player)then
			if(req==3)then
				------ request refresh data--------
				QueueHandler.Iterate(player,nil,3)
				--RE:FireClient(player, 3,QueueHandler.Iterate().Name)
			else
				----unauthorized unidentified RE fire(queued)---
				unauthorized(player,true)
				return
			end	
		return
		else
			-----unauthorized RE fire (not in q ueue)
			unauthorized(player,false)
			return
		end
		wait()
	end)
end)
--]]
--=================================================--
------------MATCHMAKING EXPERIMENTAL BTW-------------
----------Search opponent and exclude self func------
function SearchOpponent(id)	
	for k, v in pairs(_G.gaming) do
		print(Dict[10])
		if v~= id then					--self explanatory btw
			return v
		else
			return  nil
		end
	end
end
----------------------------------------------------
-----------Match make core process -----------------
local a = false
while a do
	if QueueHandler.QueueCount()>1 then
		spawn(function()
			for k, p1 in pairs(_G.gaming)do
				print(Dict[0]..Dict[8])
				local opponent = SearchOpponent(p1)
					if opponent then
						print(Dict[9].. p1.Name.." VS " .. opponent.Name)	
						QueueHandler.RemoveQueue(p1)
						QueueHandler.RemoveQueue(opponent)							

						spawn(function()
							local matchid = DSHandler.getMatchID(p1.UserId,opponent.UserId)
							if matchid~="fail" then
								----- data store saved---
								spawn(function()RE:FireClient(p1, 4,opponent.Name,5,matchid)end) 			-- send server-client data on matched
								RE:FireClient(opponent, 4,p1.Name,5,matchid)
							else
								-- when datastore cannot save --
								--do something
								RE:FireClient(p1,Dict[14],5)	
								RE:FireClient(opponent,Dict[14],5)
							end
						end)
						--onMatched(p1,p2)
						--	RF:InvokeClient(p1) 		--- invoke clients are yield still trying to figure out task scheduler]]//todo
						--	RF:InvokeClient(p2) 		--- for coroutine n shit ionno tho ]] //todo
					
					else
						print(Dict[11]..Dict[0])
					end
			end
		wait()
		end)
	end
	wait(5)
end
--[[spawn(Matchmake) ---- 
wait()						TODO
]]--
