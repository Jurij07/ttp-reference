--!strict
-- Net.lua
-- Kleiner Helfer für RemoteEvents / RemoteFunctions.
-- Auf dem Server werden die Remotes erstellt, auf dem Client wird auf sie gewartet.
-- So muss man Remotes nie manuell in Studio anlegen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local Net = {}

local folder: Folder
if IS_SERVER then
	folder = ReplicatedStorage:FindFirstChild("Remotes") :: Folder
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

-- Holt (oder erstellt auf dem Server) ein RemoteEvent mit dem gegebenen Namen.
function Net.Event(name: string): RemoteEvent
	if IS_SERVER then
		local ev = folder:FindFirstChild(name)
		if not ev then
			ev = Instance.new("RemoteEvent")
			ev.Name = name
			ev.Parent = folder
		end
		return ev :: RemoteEvent
	else
		return folder:WaitForChild(name) :: RemoteEvent
	end
end

-- Holt (oder erstellt auf dem Server) eine RemoteFunction mit dem gegebenen Namen.
function Net.Function(name: string): RemoteFunction
	if IS_SERVER then
		local fn = folder:FindFirstChild(name)
		if not fn then
			fn = Instance.new("RemoteFunction")
			fn.Name = name
			fn.Parent = folder
		end
		return fn :: RemoteFunction
	else
		return folder:WaitForChild(name) :: RemoteFunction
	end
end

return Net
