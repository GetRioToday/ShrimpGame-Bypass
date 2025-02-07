local LocalClient = game:GetService("Players").LocalPlayer
local LocalCharacter = LocalClient.Character

local function DestroyAntiCheat()
	LocalCharacter = LocalClient.Character or LocalClient.CharacterAdded:Wait()
	LocalClient.CharacterAdded:Connect(DestroyAntiCheat)

	if LocalCharacter:WaitForChild("AnimationHandler", 60) then
		LocalCharacter.AnimationHandler:Destroy()
	end
end

DestroyAntiCheat()
