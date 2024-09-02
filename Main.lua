local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local C = Knit.CreateController {
	Name = `{script.Name}`,
	
	Alerts = false,
}

local Functions
local TempFunctions

local TestService

function C.KnitInit()
	Functions = {}
	TempFunctions = {}
	
	TestService = game:GetService("TestService")
end

function C.KnitStart()
	game:GetService("RunService").RenderStepped:Connect(function(Delta)
		for Name,Data in pairs(Functions) do
			xpcall(Data._func, Data.Error, Delta)
		end
	end)
end

function Alert(Message)
	if not C.Alert then return end
	
	warn(Message)
	
	return false
end

function C:Create(Name, _func, Error, Enabled)
	if not _func then return Alert("Renderstepped Function '" .. Name .. "' Does Not Have A Function To Run.") end
	if not Name or (Functions[Name] or TempFunctions[Name]) then return Alert("Renderstepped Function '" .. Name .. "' Already Exists.") end
	
	((Enabled == nil and true or false) and Functions or TempFunctions)[Name] = {
		_func = _func,
		Error = Error and Error or function(err) TestService:Message(debug.traceback("		| RenderStepped |\nError: "..err.."\n",2)) end
	}
	
	return true
end

function C:Delete(Name)
	if not Name then return end
	if Functions[Name] and not TempFunctions[Name] then return Alert("Renderstepped Function '" .. Name .. "' Must Be Disabled Before Deletion.") end
	
	TempFunctions[Name] = nil
	
	Alert("Renderstepped Function '" .. Name .. "' Has Been Deleted.")
	
	return true
end

function C:ForceDelete(Name)
	if C:Disable(Name) then return C:Delete(Name) end
end

function C:Enable(Name)
	if not Name then return end
	if not Functions[Name] and not TempFunctions[Name] then return Alert("Renderstepped Function '" .. Name .. "' Does Not Exist.") end
	if Functions[Name] then return Alert("Renderstepped Function '" .. Name .. "' Is Already Enabled.") end
	
	Functions[Name] = TempFunctions[Name]
	TempFunctions[Name] = nil
	
	Alert("Renderstepped Function '" .. Name .. "' Has Been Enabled.")
	
	return true
end

function C:Disable(Name)
	if not Name then return end
	if not Functions[Name] and not TempFunctions[Name] then return Alert("Renderstepped Function '" .. Name .. "' Does Not Exist.") end
	if TempFunctions[Name] then return Alert("Renderstepped Function '" .. Name .. "' Is Already Disabled.") end
	
	TempFunctions[Name] = Functions[Name]
	Functions[Name] = nil
	
	Alert("Renderstepped Function '" .. Name .. "' Has Been Disabled.")
	
	return true
end

return C
