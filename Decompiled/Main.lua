local SharedStorage = game:GetService("ReplicatedStorage")
local LocalClient = game:GetService("Players").LocalPlayer
local Memer = SharedStorage:WaitForChild("Memer") -- The anticheat remote. When fired, it kicks the player.

return {
	["run"] = function(LocalCharacter: Model) -- .run() is called by the anticheat loader
		-- upvalues: (copy) v_u_3, (copy) v_u_1, (copy) v_u_2
		local DiedCon = nil
		local NameChangeCon = nil
		local MemerDeletedCon = nil
		local GravityChangedCon = nil
		local CollideStateChangedCon = nil
		local DetectBToolsCon = nil
		local FlingCheckCon = nil

		local function CheckStrangeMovers(Descendant: Instance)
			-- upvalues: (ref) v_u_3
			if Descendant:IsA("BodyVelocity") or (Descendant:IsA("BodyForce") or (Descendant:IsA("BodyGyro") or (Descendant:IsA("BodyAngularVelocity") or Descendant:IsA("BodyThrust")))) then
				Memer:FireServer(Descendant)
			end
		end
		
		local function LocalClientDied()
			-- upvalues: (ref) v_u_12, (ref) v_u_5, (ref) v_u_6, (ref) v_u_8, (ref) v_u_7, (ref) v_u_9, (ref) v_u_10
			FlingCheckCon:Disconnect()
			DiedCon:Disconnect()
			NameChangeCon:Disconnect()
			GravityChangedCon:Disconnect()
			MemerDeletedCon:Disconnect()
			CollideStateChangedCon:Disconnect()
			DetectBToolsCon:Disconnect()
		end

		local function CreateBodyVelocity()
			-- upvalues: (copy) p_u_4
			Instance.new("BodyVelocity").Parent = LocalCharacter
		end

		local function GravityCheck()
			-- upvalues: (copy) p_u_4
			if workspace.Gravity <= 0 then
				CreateBodyVelocity()
			end
		end

		local function CheckMemerDeleted(Child: Instance)
			-- upvalues: (ref) v_u_3
			if Child == Memer then
				task.spawn(function()
					while true do
						Instance.new("Part", workspace)
					end
				end)
			end
		end

		local function CollisionChangedCheck()
			-- upvalues: (copy) p_u_4
			if not LocalCharacter:WaitForChild("UpperTorso").CanCollide then
				Instance.new("BodyVelocity").Parent = LocalCharacter
			end
		end

		local function CheckBTools(Child: Instance)
			-- upvalues: (ref) v_u_3
			if Child:IsA("HopperBin") then
				Memer:FireServer(Instance.new("BodyVelocity"), "BTOOLS")
			end
		end

		FlingCheckCon = LocalCharacter.DescendantAdded:Connect(CheckStrangeMovers)
		DiedCon = LocalCharacter:WaitForChild("Humanoid").Died:Connect(LocalClientDied)
		NameChangeCon = Memer:GetPropertyChangedSignal("Name"):Connect(CreateBodyVelocity)
		GravityChangedCon = workspace:GetPropertyChangedSignal("Gravity"):Connect(GravityCheck)
		MemerDeletedCon = SharedStorage.ChildRemoved:Connect(CheckMemerDeleted)
		CollideStateChangedCon = LocalCharacter:WaitForChild("UpperTorso"):GetPropertyChangedSignal("CanCollide"):Connect(CollisionChangedCheck)
		DetectBToolsCon = LocalClient:WaitForChild("Backpack").ChildAdded:Connect(CheckBTools)
	end
}
