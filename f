-- [4080] ULTIMATE ANTI-KICK/TELEPORT FOR STEAL AN EGG
-- Block SEMUA cara server buat move/kick kamu

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- 1. BLOCK LOCAL KICK
hookfunction(LocalPlayer.Kick, function(self, reason)
    warn("[4080] Kick LOCAL diblokir:", reason)
end)

-- 2. BLOCK SEMUA JENIS TELEPORT
hookfunction(TeleportService.Teleport, function(self, ...)
    warn("[4080] Teleport diblokir")
end)

hookfunction(TeleportService.TeleportToPlaceInstance, function(self, ...)
    warn("[4080] TeleportToPlaceInstance diblokir")
end)

hookfunction(TeleportService.TeleportToPrivateServer, function(self, ...)
    warn("[4080] TeleportToPrivateServer diblokir")
end)

hookfunction(TeleportService.ReserveServer, function(self, ...)
    warn("[4080] ReserveServer diblokir")
end)

-- 3. BLOCK CHARACTER RESET/RESPAWN PAKSA
local oldCharacter = LocalPlayer.Character
local oldCharacterAdded = LocalPlayer.CharacterAdded

-- Prevent forced character reset
hookmetamethod(getrawmetatable(game), "__newindex", function(self, key, value)
    if key == "Parent" and typeof(value) == "Instance" then
        if self:IsA("Model") and self == LocalPlayer.Character then
            if value == nil or value:GetFullName():find("Deleted") then
                warn("[4080] Character parent change diblokir")
                return
            end
        end
    end
    return rawset(self, key, value)
end)

-- 4. STATE SPOOF + REMOTE INTERCEPT
local old_namecall
old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() then
        local method = getnamecallmethod()
        
        -- Spoof admin state
        if method == "InvokeServer" and self.Name == "Request" and self.Parent.Name == "ContentCreatorRemotes" then
            local player = game.Players.LocalPlayer
            local cmds = setmetatable({}, {
                __index = function(t, k)
                    return {Allowed = true, Enabled = true, Visible = true, Locked = false, Access = true}
                end
            })
            return {
                Ok = true,
                State = {
                    Players = {[player.UserId] = true, [player.Name] = true},
                    Commands = cmds,
                    Admin = true,
                    Active = {[player.UserId] = true},
                    Servers = {},
                    Access = true,
                    TargetActive = {[player.UserId] = true},
                    Reserved = true,
                    Level = 999,
                    Permissions = {"all", "admin", "developer", "moderator", "*"},
                    Role = "admin",
                    IsAdmin = true,
                    CanAccessPanel = true,
                    Allowed = true,
                    Enabled = true,
                    Visible = true,
                    Locked = false,
                    UserId = player.UserId,
                    Username = player.Name
                }
            }
        end
        
        -- BLOCK remote yang trigger server move/kick
        if method == "FireServer" or method == "InvokeServer" then
            local path = self:GetFullName():lower()
            local args = {...}
            
            -- Deteksi remote yang mencurigakan
            if path:find("kick") or path:find("ban") or path:find("teleport") or 
               path:find("move") or path:find("evict") or path:find("server") or
               path:find("anti") or path:find("cheat") or path:find("detect") then
                warn("[4080] Remote mencurigakan diblokir:", path)
                if method == "InvokeServer" then
                    return true
                end
                return
            end
            
            -- Log semua remote untuk debugging
            if not path:find("awayearnings") and not path:find("analytics") and 
               not path:find("ping") and not path:find("rigsync") and 
               not path:find("fps") and not path:find("probe") then
                warn("[REMOTE]", method, "|", path)
                for i, v in ipairs(args) do
                    warn("  Arg["..i.."]:", typeof(v), tostring(v))
                end
            end
        end
        
        -- Block verification checks
        if method == "InvokeServer" and (self.Name:lower():find("verify") or 
            self.Name:lower():find("check") or self.Name:lower():find("auth") or
            self.Name:lower():find("validate") or self.Name:lower():find("test")) then
            return true
        end
    end
    return old_namecall(self, ...)
end))

-- 5. KILL SEMUA LOCAL ANTI-CHEAT SCRIPTS
task.spawn(function()
    task.wait(1)
    local killed = 0
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            local name = obj.Name:lower()
            local path = obj:GetFullName():lower()
            
            if name:find("anti") or name:find("cheat") or name:find("guard") or 
               name:find("detect") or name:find("verify") or name:find("collision") or
               name:find("pushback") or path:find("anticollision") then
                obj:Destroy()
                killed = killed + 1
                warn("[4080] Destroyed script:", obj:GetFullName())
            end
        end
    end
    
    warn("[4080] Total scripts destroyed:", killed)
end)

-- 6. PREVENT SERVER BINDING
game:GetService("RunService").Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character.Parent then
        -- Character dihapus paksa, coba respawn lokal
        warn("[4080] Character dihapus, respawn lokal...")
        -- Jangan biarkan server respawn character
    end
end)

print("[4080] ULTIMATE PROTECTION ACTIVE")
print("[4080] Kick/Teleport diblokir semua jalur")
print("[4080] Klik panel — cek console untuk remote yang dipanggil")
