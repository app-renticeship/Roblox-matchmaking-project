----- just functions for managing the queue
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RE = ReplicatedStorage:WaitForChild("MMRemoteE")
local RF = ReplicatedStorage:WaitForChild("MMRemoteF")
 _G.gaming = {}              ---- queued players table
local QueueHandler = {}
--============================--
function QueueHandler.Iterate(target,exception,req)
	wait()
	if exception ~= nil then
		for k,v in pairs(_G.gaming) do
			if v == exception then
				pcall(function()RE:FireClient(target,req,v.Name)end)
			else
				pcall(function()RE:FireClient(target,req,v.Name)end)
				RE:FireClient(v,req,exception.Name)
			end
		end
	else
		for k, player in pairs(_G.gaming) do
			RE:FireClient(target,req,player.Name)
		end
	end
end
--============================--
function QueueHandler.RemoveQueue(player)
	wait()
	for k, v in pairs(_G.gaming) do
		if v == player then
			table.remove(_G.gaming, k)
			return true
		end
	end
end
--============================--
function QueueHandler.AddQueue(player)
	wait()
	
	table.insert(_G.gaming, player)
end
--===========================--
function QueueHandler.QueueCount()
	wait()
	local count = 0
	for _ in pairs(_G.gaming) do count = count+1 end
	return count
end
--===========================--
function QueueHandler.inQueue(player)
	wait()
	for _,v in pairs(_G.gaming)do
		
		if v==player then
			return true
		end
	end
	return false
end
return QueueHandler
