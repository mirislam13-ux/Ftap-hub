
-- FTAP SERVER
-- For your own Roblox Studio test game
-- Throws only players who have enabled consent.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("FTAPRemote")

if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "FTAPRemote"
    remote.Parent = ReplicatedStorage
end

local THROW_POWER = 95
local MAX_DISTANCE = 20
local COOLDOWN = 2

local lastThrow = {}

remote.OnServerEvent:Connect(function(player, action, target)
    if action == "Consent" then
        if typeof(target) == "boolean" then
            player:SetAttribute("FTAPConsent", target)
        end
        return
    end

    if action == "Throw" then
        if not player:GetAttribute("FTAPConsent") then
            return
        end

        if typeof(target) ~= "Instance"
            or not target:IsA("Player")
            or target == player then
            return
        end

        if not target:GetAttribute("FTAPConsent") then
            return
        end

        local now = os.clock()
        if lastThrow[player] and now - lastThrow[player] < COOLDOWN then
            return
        end

        local attackerCharacter = player.Character
        local targetCharacter = target.Character

        if not attackerCharacter or not targetCharacter then return end

        local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

        if not attackerRoot or not targetRoot then return end

        if (attackerRoot.Position - targetRoot.Position).Magnitude > MAX_DISTANCE then
            return
        end

        lastThrow[player] = now

        local direction = targetRoot.Position - attackerRoot.Position
        if direction.Magnitude < 0.01 then return end

        direction = direction.Unit

        targetRoot:ApplyImpulse(
            (direction * THROW_POWER + Vector3.new(0, THROW_POWER * 0.5, 0))
            * targetRoot.AssemblyMass
        )
    end

    if action == "Recover" then
        local character = player.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastThrow[player] = nil
end)
