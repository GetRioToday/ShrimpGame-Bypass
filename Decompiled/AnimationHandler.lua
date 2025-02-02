local LocalClient = game:GetService("Players").LocalPlayer
local LocalCharacter = LocalClient.Character or LocalClient.CharacterAdded:Wait()
require(script:WaitForChild("Main")).run(LocalCharacter)
script:WaitForChild("Main"):Destroy()
