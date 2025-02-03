### Overview
The Shrimp Game anticheat is very basic and has very little detections. It's purpose seems to be to stop low effort cheaters rather than be a challenging system.

It hides it's code in a ModuleScript called `Main`, inside of the `AnimationHandler` LocalScript under the `LocalCharacter`. The `AnimationHandler` LocalScript requires the module, calls it's only exported function called `run` and passes the LocalCharacter.

Once the anticheat is loaded, the module `Main` is destroyed to presumably prevent analysis.

```lua
local LocalClient = game:GetService("Players").LocalPlayer
local LocalCharacter = LocalClient.Character or LocalClient.CharacterAdded:Wait()
require(script:WaitForChild("Main")).run(LocalCharacter)
script:WaitForChild("Main"):Destroy()
```

### Analysis
Even though the anticheat deletes `Main`, we can still recover it from another player. When `AnimationHandler` deletes the module, it does so locally - so the change is not replicated. The same is true for when other clients delete their own `Module` script, which means their module is still visible and replicated to us.

When recovering the `Main` ModuleScript source, we can clean it up a bit for an easier understanding:
```lua
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
				Memer:FireServer(Descendant) -- Descendant will be received as nil for the server if it was created locally. This is how the server knows if we are cheating or not.
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
```

### Bypassing
There are many ways to bypass these detections, but the simplest is to simply delete `AnimationHandler`. When the script is deleted, the connections will get garbage collected resulting in the anticheat being completely removed.

The anticheat is purposefully inserted into the character on every respawn, so we must detect the character being respawned and delete it again to consistently bypass.

Some other methods that could bypass are:
1. Block the `Memer` remote from firing
2. Retrieve the connections and disable them manually
3. Hook the functions and instantly return

But again, the simplest method to get rid of the anticheat is to just delete it.
