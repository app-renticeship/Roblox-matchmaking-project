

local UIC = script.Parent.Parent
local color = Color3.new(255,0,0) --red
local initialized = false
-----Handles UI things----
local UIHandler = {}
function UIHandler.Initialize(start)
	if start then
		print("[L] Initialized UI")		
		local RefreshQueueF=Instance.new("Frame")
		local QueueListF=Instance.new("Frame")
		

			QueueListF.Parent 					= UIC
			QueueListF.Size 					= UDim2.new(0,138,0,191)
			QueueListF.Position					= UDim2.new(0,0,1, -230)
			QueueListF.BackgroundTransparency	= 0
			QueueListF.Name 					= "QueueListF"
			QueueListF.Active					= false
		
		initialized = true
		
	elseif not start then
		pcall(function()
			UIC:FindFirstChild("QueueListF"):ClearAllChildren()
			UIC:FindFirstChild("QueueListF"):Destroy()
		end)
		print("[L] Terminated UI")
		initialized =false
	end
end
function UIHandler.Queuelist(sec,par,drei)
	if par~=nil then
		local tl = Instance.new("Message",script.Parent.Parent.Parent)
		tl.Text = sec
		wait(par)
		tl:Destroy()
		return
	end
	if initialized then
	local frame = UIC:WaitForChild("QueueListF")
		if frame:FindFirstChild(sec) then							--check for dupe	
			UIC.QueueListF[sec]:Destroy()
			return
		else
		wait()
		local tl = Instance.new("TextLabel")						--make new txtlabel for every queued person in the table from da server data
		tl.Name = sec
		tl.Text = sec												--\/\/ UI shit here \/\/
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.Size = UDim2.new(1, 0, 0,24)
		tl.Parent = frame											-- add to the parent frame
			if not frame:FindFirstChildOfClass("UIListLayout") then	-- Layout the frames in a list if they arent alr
				Instance.new("UIListLayout", frame)
			end	
			
		end
	end
end
return UIHandler
