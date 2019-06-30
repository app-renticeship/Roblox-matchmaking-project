--[[ 
	
	Credits: 
	Dante (selfhood)
	
--]]
----------Initializing Variables and loading in assets--------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RF 				= ReplicatedStorage:WaitForChild("MMRemoteF")
local RE 				= ReplicatedStorage:WaitForChild("MMRemoteE")
local UI 				= require(script:WaitForChild("UIHandler"))
local frame 			= script.Parent:FindFirstChild("QueueListF")
local mmButton 			= script.Parent.MatchMakeButton.MatchMakeButton
local refreshQ 			= script.Parent:FindFirstChild("RefreshQueueB")
queued 					= false
--------------------------------------------------------------
--[[
	(0) = sent
	(1) = match
	(2) = unmatch
	(3) = refresh
	(4) = inmatch
--]]
-------------Dictionary---------------
local dict = 
{
	[1] = "Finding Opponent...",
	[0] = "Find Match",
	[2] = "In Match"
}
-----------------------Functions to make my life easier -------------------
function purgeMEM(...)			--- clear temp obj n tables
	UI.Initialize(false)
	if ... then
		queued = false			-- toggle button
	end
	wait(1)
end
------Request Matchup Button / Invoke RF------
mmButton.MouseButton1Click:Connect(function()		---on button click
	if not queued then							-- variable to toggle button
		print("[L]Request Matchup")					---debug messages
		mmButton.Text = dict[1]
		UI.Initialize(true)
		RF:InvokeServer(1)
		queued=true									-- toggles the button
	elseif queued then								-- variable to toggle button
		print("[L]Request Unmatchup")					--debug messages
		mmButton.Text = dict[RF:InvokeServer(2)]
		purgeMEM(true)
	end
end)

---------------- Server Listener RF (UNUSED ATM)-------
--[[local function onMatched()						---- basically listens if the server sends data if the player is matched
		frame:ClearAllChildren()				-- again clear textlables
		queued=false							--- toggles the button off
		--todo--
end
RF.OnClientInvoke = onMatched
--]]
------ RE DATA HANDLER ------
RE.OnClientEvent:Connect(function(req,sec,par,vier)					
	if req == 0  then						 
		spawn(function() UI.Queuelist(sec)end)
	elseif req == 4 then
		spawn(function()purgeMEM(true)end)
		mmButton.Text = dict[2]
		UI.Queuelist("Found Match\nOpponent: "..sec.."\nMatchID: "..vier,par)
		
	else
		spawn(function() UI.Queuelist(req,sec,par)end) 
		if par ==0 then
			mmButton.Text = dict[par]
		end		
	end
end)
