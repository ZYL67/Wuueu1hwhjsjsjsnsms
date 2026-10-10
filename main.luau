--[[
    xyl.lol — custom library UI
    target aim (L) | camlock (R)
    aim options (L) | aim checks (R)
    auto shoot (L) | triggerbot (R)
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tungtungisclosetcheating/atlas-modified/refs/heads/main/main.luau"))()

-- ============================================================
-- NOTIFICATION FIX
-- ============================================================
do
    local TweenService = game:GetService("TweenService")
    local notifHost = Library.Screen and Library.Screen:FindFirstChild("Notifications")
    if notifHost then
        for _, c in ipairs(notifHost:GetChildren()) do
            if c:IsA("UIListLayout") then c:Destroy() end
        end
        notifHost.Size = UDim2.new(0, 260, 0, 900)
    end

    local notifStack = {}
    local function reposition()
        local y = 0
        for _, e in ipairs(notifStack) do
            e.row.Position = UDim2.fromOffset(0, y)
            y = y + e.height + 4
        end
    end

    local FONT      = Enum.Font.SourceSans
    local FONT_BOLD = Enum.Font.SourceSansBold

    function Library:Notify(title, body, duration, accent)
        if not notifHost then return end
        accent   = accent or Library.Theme.Accent
        duration = duration or 4

        local W = 260
        local H = body and 46 or 26

        local row = Instance.new("Frame")
        row.Name = "Notif"
        row.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        row.BorderSizePixel = 0
        row.Size = UDim2.fromOffset(W, H)
        row.Position = UDim2.fromOffset(-W - 20, 0)
        row.ZIndex = 421
        row.Parent = notifHost

        local innerB = Instance.new("Frame")
        innerB.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
        innerB.BorderSizePixel = 0
        innerB.Position = UDim2.fromOffset(1, 1)
        innerB.Size = UDim2.new(1, -2, 1, -2)
        innerB.ZIndex = 421
        innerB.Parent = row

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        fill.BorderSizePixel = 0
        fill.Position = UDim2.fromOffset(2, 2)
        fill.Size = UDim2.new(1, -4, 1, -4)
        fill.ZIndex = 421
        fill.Parent = row

        local strip = Instance.new("Frame")
        strip.BackgroundColor3 = accent
        strip.BorderSizePixel = 0
        strip.Position = UDim2.fromOffset(2, 2)
        strip.Size = UDim2.new(0, 3, 1, -4)
        strip.ZIndex = 422
        strip.Parent = fill

        local titleLbl = Instance.new("TextLabel")
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tostring(title or "notice")
        titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_BOLD
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextYAlignment = Enum.TextYAlignment.Center
        titleLbl.TextStrokeTransparency = 1
        titleLbl.Position = UDim2.fromOffset(12, 4)
        titleLbl.Size = UDim2.new(1, -18, 0, 14)
        titleLbl.ZIndex = 425
        titleLbl.Parent = fill

        if body then
            local bodyLbl = Instance.new("TextLabel")
            bodyLbl.BackgroundTransparency = 1
            bodyLbl.Text = tostring(body)
            bodyLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
            bodyLbl.TextSize = 11
            bodyLbl.Font = FONT
            bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
            bodyLbl.TextYAlignment = Enum.TextYAlignment.Center
            bodyLbl.TextStrokeTransparency = 1
            bodyLbl.Position = UDim2.fromOffset(12, 22)
            bodyLbl.Size = UDim2.new(1, -18, 0, 14)
            bodyLbl.ZIndex = 425
            bodyLbl.Parent = fill
        end

        local entry = { row = row, height = H }
        table.insert(notifStack, 1, entry)
        reposition()

        local slideIn = TweenService:Create(row,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.fromOffset(0, 0) })
        slideIn:Play()

        task.delay(duration, function()
            if not row.Parent then return end
            local targetY = row.Position.Y.Offset
            local slideOut = TweenService:Create(row,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.fromOffset(-W - 20, targetY) })
            slideOut:Play()
            task.delay(0.28, function()
                for i, e in ipairs(notifStack) do
                    if e == entry then table.remove(notifStack, i); break end
                end
                reposition()
                if row.Parent then row:Destroy() end
            end)
        end)
    end
end

-- ============================================================
-- ACCENT → WHITE (accent only)
-- ============================================================
Library.SetAccent(Color3.fromRGB(255, 255, 255))

-- ============================================================
-- WATERMARK → "xylo.lol beta free"
-- ============================================================
if Library.Watermark then
    Library.Watermark.label1 = "xylo.lol"
    Library.Watermark.label2 = "beta"
    Library.Watermark.label3 = "free"
    if Library.Watermark.refresh then Library.Watermark.refresh() end
end

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local Workspace      = game:GetService("Workspace")
local UIS            = game:GetService("UserInputService")
local GuiService     = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats          = game:GetService("Stats")
local LP             = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local player, camera, workspace = LP, Camera, Workspace
local UserInputService = UIS

-- ============================================================
-- HELPERS
-- ============================================================
local HITPART_MAP = {
    ["head"]="Head",["neck"]="Neck",["uppertorso"]="UpperTorso",["lowertorso"]="LowerTorso",
    ["leftupperarm"]="LeftUpperArm",["leftlowerarm"]="LeftLowerArm",["lefthand"]="LeftHand",
    ["rightupperarm"]="RightUpperArm",["rightlowerarm"]="RightLowerArm",["righthand"]="RightHand",
    ["leftupperleg"]="LeftUpperLeg",["leftlowerleg"]="LeftLowerLeg",["leftfoot"]="LeftFoot",
    ["rightupperleg"]="RightUpperLeg",["rightlowerleg"]="RightLowerLeg",["rightfoot"]="RightFoot",
    ["humanoidrootpart"]="HumanoidRootPart",["closest part"]="Closest Part",
}
local HitParts = {
    "head","neck","uppertorso","lowertorso","leftupperarm","leftlowerarm","lefthand",
    "rightupperarm","rightlowerarm","righthand","leftupperleg","leftlowerleg","leftfoot",
    "rightupperleg","rightlowerleg","rightfoot","humanoidrootpart","closest part",
}
local CLOSEST_PART_NAMES = {
    "Head","Neck","UpperTorso","LowerTorso","HumanoidRootPart",
    "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand",
    "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot",
}
local function ResolveClosestPart(character, requestedPart)
    if not character then return nil end
    if requestedPart ~= "Closest Part" then
        return character:FindFirstChild(requestedPart) or character:FindFirstChild("HumanoidRootPart")
    end
    local camPos = Camera.CFrame.Position
    local best, bestDist = nil, math.huge
    for _, name in ipairs(CLOSEST_PART_NAMES) do
        local part = character:FindFirstChild(name)
        if part then
            local d = (part.Position - camPos).Magnitude
            if d < bestDist then bestDist = d; best = part end
        end
    end
    return best or character:FindFirstChild("HumanoidRootPart")
end

local Checks = {
    has_char = function(p) return p and p.Character and p.Character:FindFirstChild("Humanoid") ~= nil end,
    is_knocked = function(p)
        if not (p and p.Character) then return false end
        local be = p.Character:FindFirstChild("BodyEffects")
        if be then
            local ko = be:FindFirstChild("K.O")
            if ko and ko:IsA("BoolValue") and ko.Value then return true end
        end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then return true end
        return false
    end,
    is_grabbed = function(p) if not (p and p.Character) then return false end; return p.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil end,
    is_seated = function(p)
        if not (p and p.Character) then return false end
        local h = p.Character:FindFirstChildOfClass("Humanoid")
        return h and h.SeatPart ~= nil
    end,
    is_friend = function(p) local ok, r = pcall(function() return LP:IsFriendsWith(p.UserId) end); return ok and r end,
    is_team = function(p) return LP.Team and p.Team and LP.Team == p.Team end,
    in_vehicle = function(p) if not (p and p.Character) then return false end; return p.Character:FindFirstChild("[CarHitBox]") ~= nil end,
    is_visible = function(targetChar, targetPart)
        if not targetChar or not targetPart then return false end
        local origin = Camera.CFrame.Position
        local dir = targetPart.Position - origin
        if dir.Magnitude < 0.1 then return true end
        local params = RaycastParams.new()
        local ok = pcall(function() params.FilterType = Enum.RaycastFilterType.Exclude end)
        if not ok then pcall(function() params.FilterType = Enum.RaycastFilterType.Blacklist end) end
        local exclude = { Camera, targetChar }
        if LP.Character then
            table.insert(exclude, LP.Character)
            for _, d in ipairs(LP.Character:GetDescendants()) do table.insert(exclude, d) end
        end
        for _, d in ipairs(targetChar:GetDescendants()) do table.insert(exclude, d) end
        params.FilterDescendantsInstances = exclude
        params.IgnoreWater = true
        local result = Workspace:Raycast(origin, dir, params)
        if not result then return true end
        return result.Instance and result.Instance:IsDescendantOf(targetChar) or false
    end,
    is_in_air = function(p)
        if not (p and p.Character) then return false end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        return root and math.abs(root.AssemblyLinearVelocity.Y) > 1 or false
    end,
    get_state = function(p)
        if not (p and p.Character) then return nil end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local ok, st = pcall(function() return hum:GetState() end)
        if not ok then return nil end
        return st
    end,
}

-- ============================================================
-- AIMLOCK
-- ============================================================
local Aimlock = (function()
    local M = {
        enabled = false, initialized = false,
        onLockChange = nil,
        lockKey = Enum.KeyCode.Insert,
        state = { locked_target = nil, isTargetting = false, predicted_position = Vector3.new(1,1,1) },
        autoAir = true, autoAirDelay = 0.2,
        lookAt = false, viewTarget = false,
        lockMethod = "Namecall",
        stickyTarget = true, targetSwitchDelay = 0.15, targetSwitchPriority = 0.5,
        aimSmooth = false, aimSmoothValue = 0.35,
    }
    local lastAutoAir, last_target_switch, last_predicted = 0, 0, nil
    local Settings = {
        HPrediction = 0.134, VPrediction = 0.134,
        ResolverEnabled = false, ResolverMethod = "Recalculate",
        AutoPrediction = false, AutoPredMethod = "Calculate",
        JumpOffset = 0.06, FallOffset = 0.270,
        AirPart = "RightFoot", RealPart = "Closest Part",
        AimPart = "Closest Part", MaxDistance = 500, LookConeDot = 0.90,
        FOVRadius = 250, UseChecks = true,
        Checks = { Knocked = true, Grabbed = true, Friend = false, Wall = false, Vehicle = false, Team = false, Seated = false },
        AntiGroundShots = true, AntiGroundMult = 0.2,
        ShowTargetDot = true,
        TargetDotColor = Color3.fromRGB(255,255,255), TargetDotColor2 = Color3.fromRGB(255,255,255),
        TargetDotSize = 12, TargetDotOffset = 1.2,
    }
    if game.PlaceId == 9825515356 or game.PlaceId == 2788229376 then M.lockMethod = "Index" end

    local Argumen = { "UpdateMousePos", "GetMousePos", "MousePos", "MOUSE", "MousePosUpdate", "UpdateMousePosI2", "UpdateMousePosI", "UpdateAim" }
    local hooks, last_pos, last_tick = {}, nil, nil
    local predictionTable = {
        {20,0.0896},{30,0.1125},{50,0.1354},{65,0.1264},{70,0.1253},{80,0.1393},
        {100,0.1419},{110,0.1446},{120,0.1472},{130,0.1499},{140,0.1525},{150,0.1552},
        {160,0.1578},{170,0.1605},{180,0.1631},{190,0.1658},{200,0.1684},{210,0.1711},
        {220,0.1737},{230,0.1763},{240,0.1790},{250,0.1816},{260,0.1843},{270,0.1869},
        {280,0.1896},{290,0.1922},{300,0.1949},
    }

    local function get_ping()
        local ok, pingStr = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
        if not ok or not pingStr then return 50 end
        return tonumber(string.split(pingStr, "(")[1]) or 50
    end
    local function update_auto_prediction()
        if not Settings.AutoPrediction then return end
        local ping = get_ping()
        if Settings.AutoPredMethod == "Calculate" then
            local v = (ping / 1000) + 0.037
            Settings.HPrediction = v; Settings.VPrediction = v
        elseif Settings.AutoPredMethod == "Sets Based" then
            local best, bestDiff = nil, math.huge
            for _, e in ipairs(predictionTable) do
                local diff = math.abs(ping - e[1])
                if diff < bestDiff then bestDiff = diff; best = e[2] end
            end
            if best then Settings.HPrediction = best; Settings.VPrediction = best * 0.910 end
        elseif Settings.AutoPredMethod == "Math Based" then
            local function gePr(fa, ad) return fa * math.log(ping + 1) + ad end
            Settings.HPrediction = gePr(0.105, -0.342665)
            Settings.VPrediction = gePr(0.100, -0.3405)
        end
    end
    local function resolve_velocity(part)
        if not part then return Vector3.zero end
        if not Settings.ResolverEnabled then return part.AssemblyLinearVelocity end
        if Settings.ResolverMethod == "MoveDirection" then
            local char = part.Parent
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then return hum.MoveDirection * (hum.WalkSpeed or 16) end
            return part.AssemblyLinearVelocity
        elseif Settings.ResolverMethod == "LookVector" then
            return part.CFrame.LookVector * (Settings.HPrediction * 1.5)
        else
            local now = tick()
            local cur = part.CFrame
            local vel = Vector3.zero
            if last_pos and last_tick then
                local dt = now - last_tick
                if dt > 0 then vel = (cur.Position - last_pos) / dt end
            end
            last_pos, last_tick = cur.Position, now
            return vel
        end
    end
    local function get_best_target(force)
        local now = tick()
        local current = M.state.locked_target
        if M.stickyTarget and current and not force then
            if Checks.has_char(current) and (now - last_target_switch) < 0.08 then return current end
        end
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local best, bestScore = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            if not Checks.has_char(p) then continue end
            local head = ResolveClosestPart(p.Character, Settings.AimPart)
            if not head then continue end
            local dist3d = (head.Position - myRoot.Position).Magnitude
            if dist3d > Settings.MaxDistance then continue end
            if Settings.UseChecks then
                if Settings.Checks.Knocked and Checks.is_knocked(p) then continue end
                if Settings.Checks.Grabbed and Checks.is_grabbed(p) then continue end
                if Settings.Checks.Friend  and Checks.is_friend(p)  then continue end
                if Settings.Checks.Team    and Checks.is_team(p)    then continue end
                if Settings.Checks.Vehicle and Checks.in_vehicle(p) then continue end
                if Settings.Checks.Seated  and Checks.is_seated(p)  then continue end
            end
            if Settings.Checks.Wall and not Checks.is_visible(p.Character, head) then continue end
            local sp, on = Camera:WorldToViewportPoint(head.Position)
            if not on or sp.Z <= 0 then continue end
            local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
            if screenDist > Settings.FOVRadius then continue end
            local score = screenDist + (dist3d * 0.5)
            if current and p == current then score = score * (1 - M.targetSwitchPriority) end
            if score < bestScore then bestScore = score; best = p end
        end
        if best ~= current and current and Checks.has_char(current) then
            if (now - last_target_switch) < M.targetSwitchDelay then return current end
        end
        if best ~= current then last_target_switch = now end
        return best
    end
    local function compute_prediction()
        local target = M.state.locked_target
        if not Checks.has_char(target) then return nil end
        local state = Checks.get_state(target)
        local is_airborne = (state == Enum.HumanoidStateType.Freefall)
        local is_jumping  = (state == Enum.HumanoidStateType.Jumping)
        local partName = Settings.AimPart
        if is_airborne then partName = Settings.AirPart
        elseif not is_jumping then partName = Settings.RealPart end
        local part = ResolveClosestPart(target.Character, partName)
        if not part then part = ResolveClosestPart(target.Character, Settings.AimPart) end
        if not part then return nil end
        local pos = part.Position
        local vel = resolve_velocity(part)
        local px = pos.X + vel.X * Settings.HPrediction
        local pz = pos.Z + vel.Z * Settings.HPrediction
        local py = pos.Y + vel.Y * Settings.VPrediction
        if Settings.AntiGroundShots and Checks.is_in_air(target) then
            py = pos.Y + math.abs(vel.Y * Settings.AntiGroundMult) * Settings.VPrediction
        end
        if is_jumping then py = py + Settings.JumpOffset
        elseif is_airborne then py = py + Settings.FallOffset end
        if py < pos.Y - 0.1 then py = pos.Y end
        local raw = Vector3.new(px, py, pz)
        if M.aimSmooth and last_predicted then raw = last_predicted:Lerp(raw, M.aimSmoothValue) end
        last_predicted = raw
        return raw
    end

    local dot_frame
    local function ensure_dot()
        if dot_frame and dot_frame.Parent then return end
        local gui = LP:FindFirstChild("PlayerGui"); if not gui then return end
        local sg = gui:FindFirstChild("XylLockGui")
        if not sg then
            sg = Instance.new("ScreenGui"); sg.Name = "XylLockGui"
            sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
            sg.DisplayOrder = 999; sg.Parent = gui
        end
        dot_frame = Instance.new("Frame")
        dot_frame.AnchorPoint = Vector2.new(0.5, 0.5)
        dot_frame.Size = UDim2.new(0, Settings.TargetDotSize, 0, Settings.TargetDotSize)
        dot_frame.BackgroundColor3 = Color3.fromRGB(255,255,255); dot_frame.BorderSizePixel = 0
        dot_frame.Visible = false; dot_frame.ZIndex = 50; dot_frame.Parent = sg
        Instance.new("UICorner", dot_frame).CornerRadius = UDim.new(1, 0)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Settings.TargetDotColor2),
            ColorSequenceKeypoint.new(0.50, Settings.TargetDotColor),
            ColorSequenceKeypoint.new(1.00, Settings.TargetDotColor),
        })
        gradient.Rotation = 45; gradient.Parent = dot_frame
        _G.__xyl_dot_gradient = gradient
    end

    local function do_lock(force)
        if not M.enabled then return end
        local target = get_best_target(force)
        if target then
            local isNew = target ~= M.state.locked_target
            M.state.locked_target = target
            local ok, pp = pcall(compute_prediction)
            M.state.predicted_position = (ok and typeof(pp) == "Vector3") and pp or Vector3.new(0, 0, 0)
            M.state.isTargetting = true
            if isNew and M.onLockChange then pcall(M.onLockChange, true, target) end
        else
            if M.state.locked_target and M.onLockChange then pcall(M.onLockChange, false, nil) end
            M.state.locked_target = nil
            M.state.isTargetting = false
            last_predicted = nil
        end
    end
    local function do_unlock()
        local had = M.state.locked_target ~= nil
        M.state.locked_target = nil
        M.state.isTargetting = false
        last_predicted = nil
        if dot_frame then dot_frame.Visible = false end
        if had and M.onLockChange then pcall(M.onLockChange, false, nil) end
    end
    function M.toggleLock()
        if not M.enabled then return end
        if M.state.locked_target then do_unlock() else do_lock(true) end
    end

    local function install_namecall_lock()
        if hooks.namecall then return end
        local mt = getrawmetatable(game); if not mt then return end
        local old = mt.__namecall
        if setreadonly then setreadonly(mt, false) end
        hooks.namecall = old
        mt.__namecall = newcclosure(function(...)
            local args = {...}
            local ok, result = pcall(function()
                if checkcaller() then return nil end
                if M.lockMethod ~= "Namecall" then return nil end
                if not (M.enabled and M.state.isTargetting and M.state.locked_target) then return nil end
                if typeof(M.state.predicted_position) ~= "Vector3" then return nil end
                if getnamecallmethod() ~= "FireServer" then return nil end
                for _, methodName in ipairs(Argumen) do
                    if args[2] == methodName then
                        args[3] = M.state.predicted_position
                        return args
                    end
                end
                return nil
            end)
            if ok and result then return old(unpack(result)) end
            return old(...)
        end)
        if setreadonly then setreadonly(mt, true) end
    end
    local function install_index_lock()
        if hooks.index then return end
        if game.PlaceId == 9825515356 then
            task.spawn(function()
                local pg = LP:FindFirstChild("PlayerGui"); if not pg then return end
                local fw = pg:WaitForChild("Framework", 10); if not fw then return end
                local env
                local ok = pcall(function() env = getsenv(fw) end)
                if not ok or not env then return end
                hooks.framework = env
                RunService.PostSimulation:Connect(function()
                    if M.lockMethod ~= "Index" then return end
                    if not (M.enabled and M.state.isTargetting and M.state.locked_target) then return end
                    if typeof(M.state.predicted_position) ~= "Vector3" then return end
                    pcall(function() env._G.MOUSE_POSITION = M.state.predicted_position end)
                end)
            end)
            hooks.index = true; return
        end
        local ok, mouse = pcall(function() return LP:GetMouse() end)
        if not ok or not mouse then return end
        local old
        old = hookmetamethod(mouse, "__index", newcclosure(function(self, key)
            if checkcaller() then return old(self, key) end
            if M.lockMethod == "Index" and key == "Hit"
                and M.enabled and M.state.isTargetting and M.state.locked_target
                and typeof(M.state.predicted_position) == "Vector3" then
                local okCF, cf = pcall(CFrame.new, M.state.predicted_position)
                if okCF and cf then return cf end
            end
            return old(self, key)
        end))
        hooks.index = old
    end
    local function install_hooks() install_namecall_lock(); install_index_lock() end

    local function apply_lookat()
        if not M.lookAt then return end
        local t = M.state.locked_target
        if not Checks.has_char(t) or not LP.Character then return end
        local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
        local myHum  = LP.Character:FindFirstChildOfClass("Humanoid")
        local tRoot  = t.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot or not myHum or not tRoot then return end
        local lp, tp = myRoot.Position, tRoot.Position
        local dir = Vector3.new(tp.X - lp.X, 0, tp.Z - lp.Z)
        if dir.Magnitude > 0.01 then
            myRoot.CFrame = CFrame.new(lp, lp + dir.Unit)
            myHum.AutoRotate = false
        end
    end
    local function restore_lookat()
        local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if myHum then myHum.AutoRotate = true end
    end
    local function apply_viewtarget()
        if not M.viewTarget then return end
        local t = M.state.locked_target
        if not Checks.has_char(t) then return end
        local hum = t.Character:FindFirstChildOfClass("Humanoid")
        if hum and Camera.CameraSubject ~= hum then Camera.CameraSubject = hum end
    end
    local function restore_viewtarget()
        if M.viewTarget and not M.state.locked_target then
            local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Camera.CameraSubject = myHum end
        end
    end

    local function init()
        if M.initialized then return end
        M.initialized = true
        ensure_dot()
        install_hooks()
        UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputState ~= Enum.UserInputState.Begin then return end
            if input.KeyCode == M.lockKey then M.toggleLock() end
        end)
        RunService.RenderStepped:Connect(function()
            if not M.enabled then
                if dot_frame then dot_frame.Visible = false end
                restore_viewtarget(); restore_lookat(); return
            end
            pcall(update_auto_prediction)
            if M.state.locked_target and not M.state.locked_target.Parent then do_unlock() end
            if M.state.locked_target and not Checks.has_char(M.state.locked_target) then do_unlock() end
            if not M.state.locked_target then
                do_lock(false)
                if not M.state.locked_target then
                    if dot_frame then dot_frame.Visible = false end
                    restore_viewtarget(); restore_lookat(); return
                end
            end
            M.state.isTargetting = true
            local ok, pp = pcall(compute_prediction)
            if ok and typeof(pp) == "Vector3" then M.state.predicted_position = pp end
            apply_lookat()
            apply_viewtarget()
        end)
        pcall(function()
            RunService:BindToRenderStep("XylAimlockDot", Enum.RenderPriority.Camera.Value + 1, function()
                if not M.enabled or not dot_frame then
                    if dot_frame then dot_frame.Visible = false end
                    return
                end
                if not M.state.locked_target or not Checks.has_char(M.state.locked_target) then
                    dot_frame.Visible = false; return
                end
                if Settings.ShowTargetDot then
                    local head = ResolveClosestPart(M.state.locked_target.Character, Settings.AimPart)
                    if head then
                        local above = head.Position + Vector3.new(0, Settings.TargetDotOffset, 0)
                        local sp, on = Camera:WorldToViewportPoint(above)
                        if on and sp.Z > 0 then
                            dot_frame.Visible = true
                            dot_frame.Position = UDim2.new(0, sp.X, 0, sp.Y)
                        else dot_frame.Visible = false end
                    else dot_frame.Visible = false end
                else dot_frame.Visible = false end
            end)
        end)
        RunService.Heartbeat:Connect(function()
            if not M.enabled or not M.autoAir then return end
            local t = M.state.locked_target
            if not Checks.has_char(t) then return end
            local hum = t.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local ok, st = pcall(function() return hum:GetState() end)
            local airborne = ok and (st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall or hum.FloorMaterial == Enum.Material.Air)
            if not airborne then return end
            if tick() - lastAutoAir < M.autoAirDelay then return end
            lastAutoAir = tick()
            local char = LP.Character; if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end)
    end

    function M.setEnabled(state)
        M.enabled = state and true or false
        if M.enabled then init(); do_lock(true)
        else do_unlock(); restore_lookat(); restore_viewtarget() end
    end
    function M.setHPrediction(v) Settings.HPrediction = tonumber(v) or Settings.HPrediction end
    function M.setVPrediction(v) Settings.VPrediction = tonumber(v) or Settings.VPrediction end
    function M.setAimPart(part) Settings.AimPart = part end
    function M.setRealPart(part) Settings.RealPart = part end
    function M.setAirPart(part) Settings.AirPart = part end
    function M.setWallCheck(v) Settings.Checks.Wall = v and true or false end
    function M.setAutoAir(v) M.autoAir = v and true or false end
    function M.setAutoAirDelay(v) M.autoAirDelay = tonumber(v) or M.autoAirDelay end
    function M.setLookAt(v) M.lookAt = v and true or false; if not v then restore_lookat() end end
    function M.setViewTarget(v) M.viewTarget = v and true or false; if not v then restore_viewtarget() end end
    function M.setLockMethod(v) if v == "Index" or v == "Namecall" then M.lockMethod = v end end
    function M.setResolverEnabled(v) Settings.ResolverEnabled = v and true or false end
    function M.setResolverMethod(v) Settings.ResolverMethod = v end
    function M.setAutoPrediction(v) Settings.AutoPrediction = v and true or false end
    function M.setAutoPredMethod(v) Settings.AutoPredMethod = v end
    function M.setJumpOffset(v) Settings.JumpOffset = tonumber(v) or Settings.JumpOffset end
    function M.setFallOffset(v) Settings.FallOffset = tonumber(v) or Settings.FallOffset end
    function M.setFOVRadius(v) Settings.FOVRadius = math.clamp(tonumber(v) or 250, 10, 1000) end
    function M.setSticky(v) M.stickyTarget = v and true or false end
    function M.setSwitchDelay(v) M.targetSwitchDelay = tonumber(v) or M.targetSwitchDelay end
    function M.setSwitchPriority(v) M.targetSwitchPriority = math.clamp(tonumber(v) or 0.5, 0, 0.95) end
    function M.setAimSmooth(v) M.aimSmooth = v and true or false; if not v then last_predicted = nil end end
    function M.setAimSmoothValue(v) M.aimSmoothValue = math.clamp(tonumber(v) or 0.35, 0.01, 1) end
    M.Settings = Settings
    return M
end)()

-- ============================================================
-- CAMLOCK (standalone)
-- ============================================================
local Camlock = (function()
    local M = {
        enabled = false, smooth = true, smoothValue = 0.5,
        HPrediction = 0.134, VPrediction = 0.134, AimPart = "Closest Part",
        FOV = 360,
        checks = { Knocked = true, Wall = false, Friend = false, Vehicle = false, Team = false, Seated = false },
        target = nil,
    }
    local function passes_checks(p)
        if not Checks.has_char(p) then return false end
        if p == LP then return false end
        if M.checks.Knocked and Checks.is_knocked(p) then return false end
        if M.checks.Friend  and Checks.is_friend(p)  then return false end
        if M.checks.Team    and Checks.is_team(p)    then return false end
        if M.checks.Vehicle and Checks.in_vehicle(p) then return false end
        if M.checks.Seated  and Checks.is_seated(p)  then return false end
        if M.checks.Wall then
            local part = ResolveClosestPart(p.Character, M.AimPart)
            if not part or not Checks.is_visible(p.Character, part) then return false end
        end
        return true
    end
    local function pick_target()
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local best, bestScore = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if not passes_checks(p) then continue end
            local part = ResolveClosestPart(p.Character, M.AimPart)
            if not part then continue end
            local sp, on = Camera:WorldToViewportPoint(part.Position)
            if not on or sp.Z <= 0 then continue end
            local screenDist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
            if screenDist > M.FOV then continue end
            local d3 = (part.Position - Camera.CFrame.Position).Magnitude
            local score = screenDist + d3 * 0.3
            if score < bestScore then bestScore = score; best = p end
        end
        return best
    end
    local function get_predicted_position(target)
        if not target then return nil end
        local part = ResolveClosestPart(target.Character, M.AimPart)
        if not part then return nil end
        local pos, vel = part.Position, part.AssemblyLinearVelocity
        local py = pos.Y + vel.Y * M.VPrediction
        if py < pos.Y - 0.1 then py = pos.Y end
        return Vector3.new(pos.X + vel.X * M.HPrediction, py, pos.Z + vel.Z * M.HPrediction)
    end
    RunService.RenderStepped:Connect(function()
        if not M.enabled then return end
        local target = Aimlock.state.locked_target
        if not (target and passes_checks(target)) then
            target = M.target
            if not (target and passes_checks(target)) then
                target = pick_target()
                M.target = target
            end
        end
        if not target then return end
        local predicted = get_predicted_position(target)
        if not predicted then return end
        local goal = CFrame.new(Camera.CFrame.Position, predicted)
        if M.smooth then Camera.CFrame = Camera.CFrame:Lerp(goal, M.smoothValue)
        else Camera.CFrame = goal end
    end)
    function M.setEnabled(v) M.enabled = v and true or false; if not M.enabled then M.target = nil end end
    function M.setSmooth(v) M.smooth = v and true or false end
    function M.setSmoothValue(v) M.smoothValue = math.clamp(tonumber(v) or 0.5, 0.01, 1) end
    function M.setHPrediction(v) M.HPrediction = tonumber(v) or M.HPrediction end
    function M.setVPrediction(v) M.VPrediction = tonumber(v) or M.VPrediction end
    function M.setAimPart(name) M.AimPart = name or "Closest Part" end
    function M.setFOV(v) M.FOV = math.clamp(tonumber(v) or 360, 10, 1000) end
    return M
end)()

-- ============================================================
-- ESP
-- ============================================================
local ESP = (function()
    local M = { cache = {}, active = false }
    local S = {
        BoxEnabled = false, BoxColor = Color3.fromRGB(255,255,255), BoxFilled = false,
        GradStart = Color3.fromRGB(255,255,255), GradEnd = Color3.fromRGB(0,0,0), FillTransparency = 0.5,
        NameEnabled = false, NameColor = Color3.fromRGB(255,255,255),
        StudsEnabled = false, StudsColor = Color3.fromRGB(255,255,255),
        ToolEnabled = false, ToolColor = Color3.fromRGB(255,255,255),
        HealthEnabled = false,
        HealthHigh = Color3.fromRGB(0,255,0), HealthMid = Color3.fromRGB(255,255,0), HealthLow = Color3.fromRGB(255,0,0),
        ShowOnSelf = false, TeamCheck = false,
    }
    local UPDATE_INTERVAL, accumulator = 1/30, 0
    local guiInset = GuiService:GetGuiInset()
    local function mk(class, props)
        local ok, d = pcall(Drawing.new, class)
        if not ok or not d then return nil end
        for k, v in pairs(props) do d[k] = v end
        return d
    end
    local function mkGui(name)
        local gui = Instance.new("ScreenGui")
        gui.Name = name; gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = game:GetService("CoreGui")
        return gui
    end
    local function mkText(gui)
        local label = Instance.new("TextLabel")
        label.Name = "Text"; label.Parent = gui
        label.BackgroundTransparency = 1; label.BorderSizePixel = 0
        label.Size = UDim2.new(0, 4, 0, 4)
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 10; label.Font = Enum.Font.Code
        label.Visible = false; label.ZIndex = 50
        return label
    end
    local function mkBar(guiName)
        local gui = mkGui(guiName)
        local outline = Instance.new("Frame")
        outline.Name = "Outline"; outline.Parent = gui
        outline.BackgroundColor3 = Color3.new(0, 0, 0)
        outline.BorderSizePixel = 0; outline.Visible = false; outline.ZIndex = 20
        local fill = Instance.new("Frame")
        fill.Name = "Fill"; fill.Parent = outline
        fill.BackgroundTransparency = 0; fill.BorderSizePixel = 0; fill.Visible = false; fill.ZIndex = 21
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90; gradient.Parent = fill
        return { Gui = gui, Outline = outline, Frame = fill, Gradient = gradient, LastValue = nil }
    end
    local function buildObj()
        local o = {}
        o.boxOutline = mk("Square", { Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(0,0,0), Visible = false, ZIndex = 8 })
        o.box        = mk("Square", { Thickness = 2, Filled = false, Transparency = 1, Color = Color3.new(1,1,1), Visible = false, ZIndex = 9 })
        o.boxInline  = mk("Square", { Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(0,0,0), Visible = false, ZIndex = 8 })
        o.fillGui = mkGui("XylESPFill")
        o.fill = Instance.new("Frame")
        o.fill.Name = "Fill"; o.fill.Parent = o.fillGui
        o.fill.BackgroundColor3 = Color3.fromRGB(255,255,255); o.fill.BorderSizePixel = 0
        o.fill.Visible = false; o.fill.ZIndex = 1
        o.fillGradient = Instance.new("UIGradient")
        o.fillGradient.Name = "Gradient"; o.fillGradient.Rotation = 90
        o.fillGradient.Parent = o.fill
        o.nameGui = mkGui("XylESPName"); o.name = mkText(o.nameGui)
        o.studsGui = mkGui("XylESPStuds"); o.studs = mkText(o.studsGui)
        o.toolGui = mkGui("XylESPTool"); o.tool = mkText(o.toolGui)
        o.hpBar = mkBar("XylESPHealth")
        return o
    end
    local function hide(o)
        if o.boxOutline then o.boxOutline.Visible = false end
        if o.box then o.box.Visible = false end
        if o.boxInline then o.boxInline.Visible = false end
        if o.fill then o.fill.Visible = false end
        if o.name then o.name.Visible = false end
        if o.studs then o.studs.Visible = false end
        if o.tool then o.tool.Visible = false end
        if o.hpBar then o.hpBar.Outline.Visible = false; o.hpBar.Frame.Visible = false end
    end
    local function destroyObj(o)
        for _, d in ipairs({ o.boxOutline, o.box, o.boxInline }) do
            if d then pcall(function() d:Remove() end) end
        end
        for _, gui in ipairs({ o.fillGui, o.nameGui, o.studsGui, o.toolGui, o.hpBar and o.hpBar.Gui }) do
            if gui then pcall(function() gui:Destroy() end) end
        end
    end
    local function getObj(plr)
        local o = M.cache[plr]
        if not o then o = buildObj(); M.cache[plr] = o end
        return o
    end
    local function anyOn()
        return S.BoxEnabled or S.NameEnabled or S.StudsEnabled or S.ToolEnabled or S.HealthEnabled
    end
    RunService.RenderStepped:Connect(function(dt)
        if not anyOn() then
            if M.active then
                for plr, o in pairs(M.cache) do hide(o) end
                M.active = false
            end
            accumulator = 0; return
        end
        M.active = true
        accumulator = accumulator + (dt or 0)
        if accumulator < UPDATE_INTERVAL then return end
        accumulator = 0
        local camPos = Camera.CFrame.Position
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP or S.ShowOnSelf then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local skip = (plr ~= LP) and S.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team
                if char and hum and hrp and hum.Health > 0 and not skip then
                    local rootPoint, rootVisible = Camera:WorldToViewportPoint(hrp.Position)
                    if rootPoint.Z <= 0 or not rootVisible then
                        hide(getObj(plr))
                    else
                        seen[plr] = true
                        local o = getObj(plr)
                        local charSize = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 1, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y) / 2
                        local boxWidth = math.floor(charSize * 1.5)
                        local boxHeight = math.floor(charSize * 3.2)
                        local bx = math.floor(rootPoint.X - boxWidth / 2)
                        local by = math.floor(rootPoint.Y - boxHeight / 2)
                        local bw, bh = boxWidth, boxHeight
                        local cx = bx + bw / 2
                        if S.BoxFilled then
                            o.fill.Visible = true
                            o.fill.Position = UDim2.new(0, bx, 0, by - guiInset.Y)
                            o.fill.Size = UDim2.new(0, bw, 0, bh)
                            o.fill.BackgroundTransparency = math.clamp(S.FillTransparency, 0, 1)
                            o.fill.BackgroundColor3 = S.GradStart
                            o.fillGradient.Enabled = true
                            o.fillGradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, S.GradStart),
                                ColorSequenceKeypoint.new(1, S.GradEnd),
                            })
                            o.fillGradient.Rotation = math.sin(tick() * 2) * 180
                        else o.fill.Visible = false end
                        if S.BoxEnabled then
                            o.boxOutline.Visible = true
                            o.boxOutline.Position = Vector2.new(bx - 1, by - 1)
                            o.boxOutline.Size = Vector2.new(bw + 2, bh + 2)
                            o.boxOutline.Color = Color3.new(0, 0, 0)
                            o.box.Visible = true
                            o.box.Position = Vector2.new(bx, by)
                            o.box.Size = Vector2.new(bw, bh)
                            o.box.Color = S.BoxColor
                            o.boxInline.Visible = true
                            o.boxInline.Position = Vector2.new(bx + 1, by + 1)
                            o.boxInline.Size = Vector2.new(math.max(bw - 2, 0), math.max(bh - 2, 0))
                            o.boxInline.Color = Color3.new(0, 0, 0)
                        else
                            o.boxOutline.Visible = false
                            o.box.Visible = false
                            o.boxInline.Visible = false
                        end
                        if S.NameEnabled then
                            o.name.Visible = true
                            o.name.Text = plr.Name
                            o.name.TextColor3 = S.NameColor
                            o.name.Position = UDim2.new(0, math.floor(cx - (o.name.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y - 9))
                        else o.name.Visible = false end
                        if S.StudsEnabled then
                            local dist = (camPos - hrp.Position).Magnitude
                            local meters = dist * 0.28
                            o.studs.Visible = true
                            o.studs.Text = string.format("[%.0fm]", meters)
                            o.studs.TextColor3 = S.StudsColor
                            o.studs.Position = UDim2.new(0, math.floor(cx - (o.studs.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y + bh + 2))
                        else o.studs.Visible = false end
                        if S.ToolEnabled then
                            local tool = char:FindFirstChildOfClass("Tool")
                            o.tool.Visible = true
                            o.tool.Text = tool and tool.Name or "NONE"
                            o.tool.TextColor3 = S.ToolColor
                            o.tool.Position = UDim2.new(0, math.floor(cx - (o.tool.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y + bh + (S.StudsEnabled and 14 or 2)))
                        else o.tool.Visible = false end
                        if S.HealthEnabled then
                            local targetFrac = math.clamp(hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 100), 0, 1)
                            local lastFrac = o.hpBar.LastValue or targetFrac
                            local frac = lastFrac + (targetFrac - lastFrac) * 0.05
                            o.hpBar.LastValue = frac
                            local barX = bx - 7
                            o.hpBar.Outline.Visible = true
                            o.hpBar.Outline.Position = UDim2.new(0, barX - 1, 0, by - guiInset.Y - 1)
                            o.hpBar.Outline.Size = UDim2.new(0, 5, 0, bh + 2)
                            o.hpBar.Frame.Visible = true
                            o.hpBar.Frame.Position = UDim2.new(0, 1, 0, (1 - frac) * bh + 1)
                            o.hpBar.Frame.Size = UDim2.new(0, 3, 0, frac * bh)
                            o.hpBar.Gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, S.HealthHigh),
                                ColorSequenceKeypoint.new(0.5, S.HealthMid),
                                ColorSequenceKeypoint.new(1, S.HealthLow),
                            })
                        else
                            o.hpBar.Outline.Visible = false
                            o.hpBar.Frame.Visible = false
                        end
                    end
                end
            end
        end
        for plr, o in pairs(M.cache) do
            if not seen[plr] then hide(o) end
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        local o = M.cache[plr]
        if o then destroyObj(o); M.cache[plr] = nil end
    end)
    function M.set(key, val) if S[key] ~= nil then S[key] = val end end
    function M.cleanup()
        for plr, o in pairs(M.cache) do destroyObj(o); M.cache[plr] = nil end
    end
    return M
end)()

-- ============================================================
-- BULLET TRACER
-- ============================================================
local BulletTracer = (function()
    local M = { enabled = false, active = {} }
    local S = {
        Width = 1, Duration = 3, Fade = false, FadeDuration = 1.5,
        Color = Color3.fromRGB(255,255,255), Color2 = Color3.fromRGB(255,255,255),
        Texture = "electro", LightEmission = 10, LocalOnly = true, MaxDistFromMe = 15,
        BeamName = "gb", Rainbow = false, RainbowSpeed = 1,
        FaceCamera = true, TextureLength = 10, ZOffset = -1, Segments = 10,
    }
    local Textures = {
        electro = "rbxassetid://139193109954329",
        cool = "rbxassetid://116848240236550",
        cum = "rbxassetid://88263664141635",
        none = "",
    }
    local function mkPart(pos)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
        p.Transparency = 1; p.Size = Vector3.zero; p.CFrame = CFrame.new(pos); p.Parent = Workspace
        return p
    end
    local function isMine(pos)
        if not S.LocalOnly then return true end
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not h then return false end
        return (h.Position - pos).Magnitude <= S.MaxDistFromMe
    end
    local function spawnTracer(a, b)
        local p0, p1 = mkPart(a), mkPart(b)
        local a0, a1 = Instance.new("Attachment", p0), Instance.new("Attachment", p1)
        local beam = Instance.new("Beam")
        beam.Attachment0, beam.Attachment1 = a0, a1
        beam.Width0, beam.Width1 = S.Width, S.Width
        beam.FaceCamera = S.FaceCamera
        beam.LightEmission = S.LightEmission
        beam.Transparency = NumberSequence.new(0)
        beam.Texture = Textures[S.Texture] or Textures.electro
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureLength = S.TextureLength
        beam.ZOffset = S.ZOffset
        beam.Segments = S.Segments
        if S.Rainbow then
            local t = tick() * S.RainbowSpeed
            beam.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(t % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((t + 0.3) % 1, 1, 1)),
            })
        else
            beam.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, S.Color),
                ColorSequenceKeypoint.new(1, S.Color2),
            })
        end
        beam.Parent = p0
        M.active[#M.active + 1] = { p0, p1, beam, tick(), false }
    end
    local function handle(beam)
        if not M.enabled or not beam or not beam.Parent then return end
        if beam.Name ~= S.BeamName then return end
        local ray = beam.Parent
        local a = ray:IsA("BasePart") and ray.Position or (ray.PrimaryPart and ray.PrimaryPart.Position)
        if not a or not isMine(a) then return end
        local b
        if beam.Attachment1 then b = beam.Attachment1.WorldCFrame.Position
        elseif beam.Attachment0 then b = beam.Attachment0.WorldCFrame.Position
        elseif ray:IsA("BasePart") then b = a + ray.CFrame.LookVector * 200
        else return end
        spawnTracer(a, b)
        pcall(function() beam:Destroy() end)
    end
    local hooked
    local function install()
        if hooked then return end
        hooked = Workspace.DescendantAdded:Connect(function(d)
            if d:IsA("Beam") and d.Name == S.BeamName then task.defer(handle, d) end
        end)
    end
    RunService.RenderStepped:Connect(function()
        local now = tick()
        for i = #M.active, 1, -1 do
            local e = M.active[i]
            if now - e[4] <= S.Duration then continue end
            if S.Fade and not e[5] then
                e[5] = true
                local t0 = now
                local c
                c = RunService.Heartbeat:Connect(function()
                    local t = (tick() - t0) / S.FadeDuration
                    if t >= 1 then
                        e[1]:Destroy(); e[2]:Destroy()
                        table.remove(M.active, i); c:Disconnect(); return
                    end
                    e[3].Transparency = NumberSequence.new(
                        TweenService:GetValue(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    )
                end)
            elseif not S.Fade then
                e[1]:Destroy(); e[2]:Destroy(); table.remove(M.active, i)
            end
        end
    end)
    function M.setEnabled(v) M.enabled = v and true or false; if M.enabled then install() end end
    function M.setColor(c) S.Color = c end
    function M.setColor2(c) S.Color2 = c end
    function M.setWidth(v) S.Width = tonumber(v) or S.Width end
    function M.setDuration(v) S.Duration = tonumber(v) or S.Duration end
    function M.setFade(v) S.Fade = v and true or false end
    function M.setFadeDuration(v) S.FadeDuration = tonumber(v) or S.FadeDuration end
    function M.setTexture(v) S.Texture = tostring(v):lower() end
    function M.setRainbow(v) S.Rainbow = v and true or false end
    function M.setLightEmission(v) S.LightEmission = tonumber(v) or S.LightEmission end
    function M.setLocalOnly(v) S.LocalOnly = v and true or false end
    function M.setMaxDist(v) S.MaxDistFromMe = tonumber(v) or S.MaxDistFromMe end
    function M.setBeamName(v) S.BeamName = v end
    function M.setTextureLength(v) S.TextureLength = tonumber(v) or S.TextureLength end
    function M.setZOffset(v) S.ZOffset = tonumber(v) or S.ZOffset end
    return M
end)()

-- ============================================================
-- AUTO FIRE
-- ============================================================
local AutoFire = (function()
    local M = { enabled = false, initialized = false }
    local FIRE_DELAY, IGNORE_MELEE = 0.1, true
    local activeTool, lastFireTime, loopConn = nil, 0, nil
    local function is_melee_or_consumable(tool)
        if not IGNORE_MELEE then return false end
        local n = tool.Name:lower()
        return n:find("katana") or n:find("knife") or n:find("sword") or n:find("bat")
            or n:find("fist") or n:find("crowbar") or n:find("pizza")
            or n:find("donut") or n:find("cola")
    end
    local function is_gun(tool)
        if not tool or not tool:IsA("Tool") then return false end
        if not tool:FindFirstChild("Handle") then return false end
        if is_melee_or_consumable(tool) then return false end
        return true
    end
    local function activateTool(tool)
        if not tool or not tool.Parent then return end
        if tool.Parent ~= player.Character then return end
        pcall(function() tool:Activate() end)
    end
    local function onEquip(tool)
        if not M.enabled then return end
        if not is_gun(tool) then return end
        activeTool, lastFireTime = tool, 0
        task.wait(0.05)
        if M.enabled and activeTool == tool and tool.Parent == player.Character then
            activateTool(tool); lastFireTime = tick()
        end
    end
    local function hookCharacter(character)
        if not character then return end
        character.ChildAdded:Connect(function(child) if child:IsA("Tool") then onEquip(child) end end)
        character.ChildRemoved:Connect(function(child) if child:IsA("Tool") and child == activeTool then activeTool = nil end end)
    end
    local function startLoop()
        if loopConn then return end
        loopConn = RunService.Heartbeat:Connect(function()
            if not M.enabled then return end
            if not activeTool or activeTool.Parent ~= player.Character then return end
            if tick() - lastFireTime >= FIRE_DELAY then
                activateTool(activeTool); lastFireTime = tick()
            end
        end)
    end
    local function init()
        if M.initialized then return end; M.initialized = true
        if player.Character then
            hookCharacter(player.Character)
            local already = player.Character:FindFirstChildWhichIsA("Tool")
            if already then onEquip(already) end
        end
        player.CharacterAdded:Connect(function(char)
            activeTool = nil
            task.wait(0.2); hookCharacter(char)
        end)
        startLoop()
    end
    function M.setEnabled(state)
        M.enabled = state and true or false
        if M.enabled then
            init()
            if player.Character then
                local tool = player.Character:FindFirstChildWhichIsA("Tool")
                if tool and is_gun(tool) then onEquip(tool) end
            end
        else activeTool = nil end
    end
    function M.setFireDelay(v) FIRE_DELAY = math.clamp(tonumber(v) or 0.1, 0.01, 10) end
    return M
end)()

-- ============================================================
-- TRIGGERBOT
-- ============================================================
local TriggerBot = (function()
    local M = { enabled = false, initialized = false }
    local SETTINGS = {
        AimRadius = 20, FireDelay = 0.08, HPrediction = 0.155, VPrediction = 0.155,
        SilentAim = true, IgnoreKnocked = true, HitPart = "Head",
        KnifeCheck = false, ForcefieldCheck = false, KnockedCheck = false,
        WallCheck = false, FriendCheck = false, TeamCheck = false, SeatedCheck = false, VehicleCheck = false,
    }
    local last_shot = 0
    local main_remote = ReplicatedStorage:FindFirstChild("MAINEVENT") or ReplicatedStorage:FindFirstChild("MainEvent")
    local function local_has_katana()
        if not player.Character then return false end
        local tool = player.Character:FindFirstChildWhichIsA("Tool")
        if not tool then return false end
        return string.lower(tool.Name):find("katana", 1, true) ~= nil
    end
    local function has_forcefield(p) if not Checks.has_char(p) then return false end; return p.Character:FindFirstChildOfClass("ForceField") ~= nil end
    local function get_equipped_gun()
        if not player.Character then return nil end
        local tool = player.Character:FindFirstChildWhichIsA("Tool")
        if not tool or not tool:FindFirstChild("Handle") then return nil end
        return tool
    end
    local function get_aim_ray()
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            return camera.CFrame.Position, camera.CFrame.LookVector
        end
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        local ray = camera:ViewportPointToRay(mousePos.X - inset.X, mousePos.Y - inset.Y)
        return ray.Origin, ray.Direction
    end
    local function get_aim_screen_point()
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        end
        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        return Vector2.new(mousePos.X - inset.X, mousePos.Y - inset.Y)
    end
    local function crosshair_hits_player(p)
        if not Checks.has_char(p) then return false end
        local origin, dir = get_aim_ray()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        if player.Character then table.insert(filter, player.Character) end
        params.FilterDescendantsInstances = filter
        params.IgnoreWater = true
        local hit = workspace:Raycast(origin, dir.Unit * 1000, params)
        if not hit or not hit.Instance then return false end
        return hit.Instance:IsDescendantOf(p.Character)
    end
    local function passes_checks(p)
        if SETTINGS.IgnoreKnocked and Checks.is_knocked(p) then return false end
        if SETTINGS.KnockedCheck and Checks.is_knocked(p) then return false end
        if SETTINGS.FriendCheck and Checks.is_friend(p) then return false end
        if SETTINGS.TeamCheck and Checks.is_team(p) then return false end
        if SETTINGS.SeatedCheck and Checks.is_seated(p) then return false end
        if SETTINGS.VehicleCheck and Checks.in_vehicle(p) then return false end
        if SETTINGS.ForcefieldCheck and has_forcefield(p) then return false end
        if SETTINGS.WallCheck then
            local part = ResolveClosestPart(p.Character, SETTINGS.HitPart)
            if not part or not Checks.is_visible(p.Character, part) then return false end
        end
        return true
    end
    local function get_aimed_player()
        local origin, dir = get_aim_ray()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        if player.Character then table.insert(filter, player.Character) end
        params.FilterDescendantsInstances = filter
        params.IgnoreWater = true
        local hit = workspace:Raycast(origin, dir.Unit * 1000, params)
        if hit and hit.Instance then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and Checks.has_char(p) and hit.Instance:IsDescendantOf(p.Character) then
                    if not passes_checks(p) then return nil end
                    return p
                end
            end
        end
        local aimScreen = get_aim_screen_point()
        local best, bestDist = nil, math.min(SETTINGS.AimRadius, 22)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            if not Checks.has_char(p) then continue end
            if not passes_checks(p) then continue end
            local part = ResolveClosestPart(p.Character, SETTINGS.HitPart)
            if part then
                local sp, on = camera:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - aimScreen).Magnitude
                    if d < bestDist then bestDist, best = d, p end
                end
            end
        end
        if best and crosshair_hits_player(best) then return best end
        return nil
    end
    local function init()
        if M.initialized then return end; M.initialized = true
        RunService.Heartbeat:Connect(function()
            if not M.enabled then return end
            if tick() - last_shot < SETTINGS.FireDelay then return end
            if SETTINGS.KnifeCheck and local_has_katana() then return end
            local gun = get_equipped_gun(); if not gun then return end
            local target = get_aimed_player(); if not target then return end
            local char = target.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local aimPart = ResolveClosestPart(char, SETTINGS.HitPart) or hrp
            local pos, vel = aimPart.Position, hrp.AssemblyLinearVelocity
            local py = pos.Y + vel.Y * SETTINGS.VPrediction
            if py < pos.Y - 0.1 then py = pos.Y end
            local predicted = Vector3.new(pos.X + vel.X * SETTINGS.HPrediction, py, pos.Z + vel.Z * SETTINGS.HPrediction)
            last_shot = tick()
            if SETTINGS.SilentAim and main_remote then
                pcall(function() main_remote:FireServer("MOUSE", predicted) end)
                pcall(function() main_remote:FireServer("MousePos", predicted) end)
                pcall(function() main_remote:FireServer("UpdateMousePosI", predicted) end)
                pcall(function() main_remote:FireServer("UpdateMousePos", predicted) end)
            end
            pcall(function() gun:Activate() end)
        end)
    end
    function M.setEnabled(state) M.enabled = state and true or false; if M.enabled then init(); last_shot = 0 end end
    function M.setFireDelay(v) SETTINGS.FireDelay = tonumber(v) or SETTINGS.FireDelay end
    function M.setHPrediction(v) SETTINGS.HPrediction = tonumber(v) or SETTINGS.HPrediction end
    function M.setVPrediction(v) SETTINGS.VPrediction = tonumber(v) or SETTINGS.VPrediction end
    function M.setHitPart(name) SETTINGS.HitPart = name or "Head" end
    function M.setKnifeCheck(v) SETTINGS.KnifeCheck = v and true or false end
    function M.setForcefieldCheck(v) SETTINGS.ForcefieldCheck = v and true or false end
    function M.setKnockedCheck(v) SETTINGS.KnockedCheck = v and true or false end
    function M.setWallCheck(v) SETTINGS.WallCheck = v and true or false end
    function M.setFriendCheck(v) SETTINGS.FriendCheck = v and true or false end
    function M.setTeamCheck(v) SETTINGS.TeamCheck = v and true or false end
    function M.setSeatedCheck(v) SETTINGS.SeatedCheck = v and true or false end
    function M.setVehicleCheck(v) SETTINGS.VehicleCheck = v and true or false end
    return M
end)()

-- ============================================================
-- RAPID FIRE
-- ============================================================
local RapidFire = (function()
    local M = { enabled = false, initialized = false }
    local FIRE_RATE, mouseDown = 0.015, false
    local function getTool()
        local char = LP.Character; if not char then return nil end
        return char:FindFirstChildOfClass("Tool")
    end
    local function activateTool()
        local tool = getTool(); if tool then pcall(function() tool:Activate() end) end
    end
    local function init()
        if M.initialized then return end; M.initialized = true
        UIS.InputBegan:Connect(function(input, gp) if gp then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = true end end)
        UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then mouseDown = false end end)
        task.spawn(function()
            while true do
                if M.enabled and mouseDown then activateTool(); task.wait(FIRE_RATE)
                else task.wait(0.1) end
            end
        end)
    end
    function M.setEnabled(state) M.enabled = state and true or false; if M.enabled then init() end end
    function M.setFireRate(v) FIRE_RATE = math.clamp(tonumber(v) or 0.015, 0.005, 1) end
    return M
end)()

-- ============================================================
-- AUTO ARMOR
-- ============================================================
local AutoArmor = (function()
    local M = { enabled = false, selected = nil, armors = {} }
    local ARMOR_KEYWORDS = { "armor", "vest", "shield", "plate", "kevlar", "protective" }
    local function is_armor_name(name)
        if not name then return false end
        local lower = name:lower()
        for _, kw in ipairs(ARMOR_KEYWORDS) do
            if lower:find(kw, 1, true) then return true end
        end
        return false
    end
    local function try_click(obj)
        if not obj then return nil end
        local det = obj:FindFirstChildOfClass("ClickDetector")
        if det then return det end
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ClickDetector") then return child end
        end
        return nil
    end
    local function clean_name(name)
        if not name then return "" end
        return (name:gsub("^%[", ""):gsub("%]$", ""):gsub("^%s+", ""):gsub("%s+$", ""))
    end
    function M.scan()
        M.armors = {}
        local seen = {}
        local function process(obj)
            if not obj or not obj.Name then return end
            if seen[obj] then return end
            seen[obj] = true
            if is_armor_name(obj.Name) then
                local det = try_click(obj)
                if det then
                    table.insert(M.armors, { name = clean_name(obj.Name), raw = obj.Name, instance = obj, detector = det })
                end
            end
        end
        local map = Workspace:FindFirstChild("MAP")
        if map then for _, obj in ipairs(map:GetDescendants()) do process(obj) end end
        for _, obj in ipairs(Workspace:GetDescendants()) do process(obj) end
        local byName, unique = {}, {}
        for _, a in ipairs(M.armors) do
            if not byName[a.name] then byName[a.name] = true; table.insert(unique, a) end
        end
        M.armors = unique
        table.sort(M.armors, function(a, b) return a.name < b.name end)
        return M.armors
    end
    function M.get_names()
        if #M.armors == 0 then return { "no armors found" } end
        local names = {}
        for _, a in ipairs(M.armors) do table.insert(names, a.name) end
        return names
    end
    function M.setSelected(name)
        if name == "no armors found" then M.selected = nil; return end
        M.selected = name
    end
    local function find_armor(name)
        if not name or name == "" then return nil end
        local lower = name:lower()
        for _, a in ipairs(M.armors) do if a.name:lower() == lower then return a end end
        for _, a in ipairs(M.armors) do if a.name:lower():find(lower, 1, true) then return a end end
        return nil
    end
    task.spawn(function()
        while task.wait(0.5) do
            if M.enabled and M.selected then
                local a = find_armor(M.selected)
                if a and a.detector and a.detector.Parent then
                    pcall(function() fireclickdetector(a.detector) end)
                end
            end
        end
    end)
    function M.setEnabled(v)
        M.enabled = v and true or false
        if M.enabled and #M.armors == 0 then M.scan() end
    end
    return M
end)()

-- ============================================================
-- LOCK BUTTON LOADER
-- ============================================================
local lockButtonLoaded = false
local function loadLockButton()
    if lockButtonLoaded then return end
    lockButtonLoaded = true
    task.spawn(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "xyl_lock"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999; sg.Parent = LP:WaitForChild("PlayerGui")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 100)
        btn.Position = UDim2.new(0, 16, 0.5, -50)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        btn.BackgroundTransparency = 0.35
        btn.Text = ""; btn.AutoButtonColor = false; btn.Active = true; btn.Draggable = true; btn.Parent = sg
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 72, 0, 72)
        icon.Position = UDim2.new(0.5, -36, 0.5, -36)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://107804954685683"
        icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = btn

        local fallback = Instance.new("TextLabel")
        fallback.Size = UDim2.new(1, 0, 1, 0); fallback.BackgroundTransparency = 1
        fallback.Text = "O"; fallback.TextColor3 = Color3.fromRGB(255, 255, 255); fallback.TextSize = 52
        fallback.Font = Enum.Font.SourceSansBold; fallback.Visible = false; fallback.Parent = btn

        task.spawn(function()
            task.wait(2.5)
            if not icon.IsLoaded then icon.Visible = false; fallback.Visible = true end
        end)

        local function refresh()
            local locked = Aimlock.enabled
            icon.ImageTransparency = locked and 0 or 0.45
            fallback.TextTransparency = locked and 0 or 0.45
            btn.BackgroundTransparency = locked and 0.15 or 0.5
        end
        RunService.RenderStepped:Connect(refresh)

        btn.MouseButton1Click:Connect(function()
            Aimlock.setEnabled(not Aimlock.enabled)
            refresh()
        end)
    end)
end

-- ============================================================
-- BUILD UI
-- ============================================================
local win = Library:Window({ Title = "xylo.lol", Size = Vector2.new(600, 520) })

local legitTab = win:Tab("legitbot")
local visTab   = win:Tab("visuals")
local miscTab  = win:Tab("misc")

-- ===== COLUMN ROW 1 =====
-- LEFT: target aim
local aimGroup = legitTab:Group("target aim")
aimGroup:CheckboxKeybind("enabled", false, Enum.KeyCode.Q, function(v)
    Aimlock.setEnabled(v)
end, "ta_enabled")
aimGroup:Combo("aim part", HitParts, 18, function(i, v)
    local part = HITPART_MAP[v] or "Closest Part"
    Aimlock.setAimPart(part); Aimlock.setRealPart(part)
end, "ta_part")
aimGroup:Combo("air part", HitParts, 16, function(i, v)
    Aimlock.setAirPart(HITPART_MAP[v] or "RightFoot")
end, "ta_airpart")
aimGroup:Button("load lock button", function()
    loadLockButton()
    Library:Notify("target aim", "lock button loaded", 3)
end)

-- RIGHT: camlock
local camGroup = legitTab:Group("camlock")
camGroup:CheckboxKeybind("enabled", false, Enum.KeyCode.Z, function(v)
    Camlock.setEnabled(v)
end, "cam_enabled")
camGroup:Combo("aim part", HitParts, 18, function(i, v)
    Camlock.setAimPart(HITPART_MAP[v] or "Closest Part")
end, "cam_part")
camGroup:Slider("prediction h", { min = 0, max = 1, default = 0.134, decimals = 3, flag = "cam_hp" },
    function(v) Camlock.setHPrediction(v) end)
camGroup:Slider("prediction v", { min = 0, max = 1, default = 0.134, decimals = 3, flag = "cam_vp" },
    function(v) Camlock.setVPrediction(v) end)
camGroup:Checkbox("smooth", true, function(v) Camlock.setSmooth(v) end, { flag = "cam_smooth" })
camGroup:Slider("smoothness %", { min = 1, max = 100, default = 50, int = true, flag = "cam_smoothamt" },
    function(v) Camlock.setSmoothValue(v / 100) end)
camGroup:Slider("camlock fov", { min = 10, max = 360, default = 360, int = true, flag = "cam_fov" },
    function(v) Camlock.setFOV(v) end)

-- ===== COLUMN ROW 2 =====
-- LEFT: aim options
local aimOpts = legitTab:Group("aim options")
aimOpts:Slider("prediction x", { min = 0, max = 1, default = 0.134, decimals = 3, flag = "ta_xpred" }, function(v) Aimlock.setHPrediction(v) end)
aimOpts:Slider("prediction y", { min = 0, max = 1, default = 0.134, decimals = 3, flag = "ta_ypred" }, function(v) Aimlock.setVPrediction(v) end)
aimOpts:Slider("jump offset", { min = 0, max = 2, default = 0.06, decimals = 3, flag = "ta_jumpoff" }, function(v) Aimlock.setJumpOffset(v) end)
aimOpts:Slider("fall offset", { min = 0, max = 2, default = 0.27, decimals = 3, flag = "ta_falloff" }, function(v) Aimlock.setFallOffset(v) end)
aimOpts:Combo("lock method", { "namecall", "index" },
    (game.PlaceId == 9825515356 or game.PlaceId == 2788229376) and 2 or 1,
    function(i, v) Aimlock.setLockMethod(v == "index" and "Index" or "Namecall") end, "ta_lockmethod")
aimOpts:Checkbox("sticky target", true, function(v) Aimlock.setSticky(v) end, { flag = "ta_sticky" })
aimOpts:Slider("switch delay", { min = 0, max = 1, default = 0.15, decimals = 2, flag = "ta_switchdelay" }, function(v) Aimlock.setSwitchDelay(v) end)
aimOpts:Slider("switch priority", { min = 0, max = 95, default = 50, int = true, flag = "ta_switchprio" }, function(v) Aimlock.setSwitchPriority(v / 100) end)
aimOpts:Checkbox("aim smoothing", false, function(v) Aimlock.setAimSmooth(v) end, { flag = "ta_aimsmooth" })
aimOpts:Slider("aim smoothing %", { min = 1, max = 100, default = 35, int = true, flag = "ta_aimsmoothamt" }, function(v) Aimlock.setAimSmoothValue(v / 100) end)
aimOpts:Checkbox("resolver", false, function(v) Aimlock.setResolverEnabled(v) end, { flag = "ta_resolver" })
aimOpts:Combo("resolver method", { "recalculate", "movedirection", "lookvector" }, 1,
    function(i, v)
        if v == "movedirection" then Aimlock.setResolverMethod("MoveDirection")
        elseif v == "lookvector" then Aimlock.setResolverMethod("LookVector")
        else Aimlock.setResolverMethod("Recalculate") end
    end, "ta_resmethod")
aimOpts:Checkbox("auto prediction", false, function(v) Aimlock.setAutoPrediction(v) end, { flag = "ta_autopred" })
aimOpts:Combo("auto prediction mode", { "calculate", "sets based", "math based" }, 1,
    function(i, v)
        if v == "sets based" then Aimlock.setAutoPredMethod("Sets Based")
        elseif v == "math based" then Aimlock.setAutoPredMethod("Math Based")
        else Aimlock.setAutoPredMethod("Calculate") end
    end, "ta_autopredmode")

-- RIGHT: aim checks
local aimChecks = legitTab:Group("aim checks")
aimChecks:Checkbox("wall check", false, function(v) Aimlock.setWallCheck(v) end, { flag = "ta_wall" })
aimChecks:Checkbox("knocked check", true, function(v) Aimlock.Settings.Checks.Knocked = v end, { flag = "ta_knocked" })
aimChecks:Checkbox("grabbed check", true, function(v) Aimlock.Settings.Checks.Grabbed = v end, { flag = "ta_grabbed" })
aimChecks:Checkbox("friend check", false, function(v) Aimlock.Settings.Checks.Friend = v end, { flag = "ta_friend" })
aimChecks:Checkbox("vehicle check", false, function(v) Aimlock.Settings.Checks.Vehicle = v end, { flag = "ta_vehicle" })
aimChecks:Checkbox("team check", false, function(v) Aimlock.Settings.Checks.Team = v end, { flag = "ta_team" })
aimChecks:Checkbox("seated check", false, function(v) Aimlock.Settings.Checks.Seated = v end, { flag = "ta_seated" })
aimChecks:Divider and aimChecks:Divider()
aimChecks:Checkbox("look at", false, function(v) Aimlock.setLookAt(v) end, { flag = "ta_lookat" })
aimChecks:Checkbox("view target", false, function(v) Aimlock.setViewTarget(v) end, { flag = "ta_view" })
aimChecks:Checkbox("auto air", true, function(v) Aimlock.setAutoAir(v) end, { flag = "ta_autoair" })
aimChecks:Slider("auto air delay", { min = 0, max = 2, default = 0.2, decimals = 2, flag = "ta_autoairdelay" }, function(v) Aimlock.setAutoAirDelay(v) end)
aimChecks:Checkbox("anti ground shots", true, function(v) Aimlock.Settings.AntiGroundShots = v end, { flag = "ta_antiground" })
aimChecks:Slider("anti ground multiplier", { min = 0, max = 1, default = 0.2, decimals = 2, flag = "ta_agm" }, function(v) Aimlock.Settings.AntiGroundMult = v end)
aimChecks:Checkbox("dot circle", true, function(v) Aimlock.Settings.ShowTargetDot = v end, { flag = "ta_dot" })

-- ===== COLUMN ROW 3 =====
-- LEFT: auto shoot
local asGroup = legitTab:Group("auto shoot")
asGroup:CheckboxKeybind("enabled", false, Enum.KeyCode.V, function(v)
    AutoFire.setEnabled(v)
end, "as_enabled")
asGroup:Slider("fire delay", { min = 0.01, max = 10, default = 0.1, decimals = 2, flag = "as_delay" },
    function(v) AutoFire.setFireDelay(v) end)
asGroup:Checkbox("auto shoot hud", false, function(v)
    if Library.Notify then
        Library:Notify("auto shoot", v and "hud enabled" or "hud disabled", 2)
    end
end, { flag = "as_hud" })

-- RIGHT: triggerbot
local tbGroup = legitTab:Group("triggerbot")
tbGroup:CheckboxKeybind("enabled", false, Enum.KeyCode.T, function(v)
    TriggerBot.setEnabled(v)
end, "tb_enabled")
tbGroup:Slider("fire delay", { min = 0.01, max = 1, default = 0.08, decimals = 2, flag = "tb_delay" }, function(v) TriggerBot.setFireDelay(v) end)
tbGroup:Combo("part", HitParts, 1, function(i, v) TriggerBot.setHitPart(HITPART_MAP[v] or "Head") end, "tb_part")
tbGroup:Slider("h prediction", { min = 0, max = 1, default = 0.155, decimals = 3, flag = "tb_hp" }, function(v) TriggerBot.setHPrediction(v) end)
tbGroup:Slider("v prediction", { min = 0, max = 1, default = 0.155, decimals = 3, flag = "tb_vp" }, function(v) TriggerBot.setVPrediction(v) end)
tbGroup:Checkbox("knife check", false, function(v) TriggerBot.setKnifeCheck(v) end, { flag = "tb_knife" })
tbGroup:Checkbox("forcefield check", false, function(v) TriggerBot.setForcefieldCheck(v) end, { flag = "tb_ff" })
tbGroup:Checkbox("knocked check", false, function(v) TriggerBot.setKnockedCheck(v) end, { flag = "tb_kc" })
tbGroup:Checkbox("wall check", false, function(v) TriggerBot.setWallCheck(v) end, { flag = "tb_wall" })
tbGroup:Checkbox("friend check", false, function(v) TriggerBot.setFriendCheck(v) end, { flag = "tb_friend" })
tbGroup:Checkbox("team check", false, function(v) TriggerBot.setTeamCheck(v) end, { flag = "tb_team" })
tbGroup:Checkbox("seated check", false, function(v) TriggerBot.setSeatedCheck(v) end, { flag = "tb_seated" })
tbGroup:Checkbox("vehicle check", false, function(v) TriggerBot.setVehicleCheck(v) end, { flag = "tb_vehicle" })

-- VISUALS
local espGroup = visTab:Group("esp")
espGroup:Checkbox("box", false, function(v) ESP.set("BoxEnabled", v) end, { flag = "esp_box" })
espGroup:ColorRow("box color", Color3.fromRGB(255,255,255), function(c) ESP.set("BoxColor", c) end, "esp_boxcolor")
espGroup:Checkbox("box filled", false, function(v) ESP.set("BoxFilled", v) end, { flag = "esp_boxfilled" })
espGroup:ColorRow("gradient start", Color3.fromRGB(255,255,255), function(c) ESP.set("GradStart", c) end, "esp_gradstart")
espGroup:ColorRow("gradient end", Color3.fromRGB(0,0,0), function(c) ESP.set("GradEnd", c) end, "esp_gradend")
espGroup:Slider("fill transparency", { min = 0, max = 1, default = 0.5, decimals = 2, flag = "esp_filltrans" }, function(v) ESP.set("FillTransparency", v) end)
espGroup:Checkbox("show on self", false, function(v) ESP.set("ShowOnSelf", v) end, { flag = "esp_showself" })
espGroup:Checkbox("name", false, function(v) ESP.set("NameEnabled", v) end, { flag = "esp_name" })
espGroup:ColorRow("name color", Color3.fromRGB(255,255,255), function(c) ESP.set("NameColor", c) end, "esp_namecolor")
espGroup:Checkbox("distance", false, function(v) ESP.set("StudsEnabled", v) end, { flag = "esp_studs" })
espGroup:ColorRow("distance color", Color3.fromRGB(255,255,255), function(c) ESP.set("StudsColor", c) end, "esp_studscolor")
espGroup:Checkbox("tool", false, function(v) ESP.set("ToolEnabled", v) end, { flag = "esp_tool" })
espGroup:ColorRow("tool color", Color3.fromRGB(255,255,255), function(c) ESP.set("ToolColor", c) end, "esp_toolcolor")
espGroup:Checkbox("health bar", false, function(v) ESP.set("HealthEnabled", v) end, { flag = "esp_health" })
espGroup:ColorRow("health high", Color3.fromRGB(0,255,0), function(c) ESP.set("HealthHigh", c) end, "esp_hp_hi")
espGroup:ColorRow("health mid", Color3.fromRGB(255,255,0), function(c) ESP.set("HealthMid", c) end, "esp_hp_mid")
espGroup:ColorRow("health low", Color3.fromRGB(255,0,0), function(c) ESP.set("HealthLow", c) end, "esp_hp_lo")
espGroup:Checkbox("team check", false, function(v) ESP.set("TeamCheck", v) end, { flag = "esp_team" })

local tracerGroup = visTab:Group("tracers")
tracerGroup:Checkbox("enabled", false, function(v) BulletTracer.setEnabled(v) end, { flag = "bt_enabled" })
tracerGroup:ColorRow("head color", Color3.fromRGB(255,255,255), function(c) BulletTracer.setColor(c) end, "bt_c1")
tracerGroup:ColorRow("tail color", Color3.fromRGB(255,255,255), function(c) BulletTracer.setColor2(c) end, "bt_c2")
tracerGroup:Combo("texture", { "electro", "cool", "cum", "none" }, 1, function(i, v) BulletTracer.setTexture(v) end, "bt_tex")
tracerGroup:Checkbox("rainbow", false, function(v) BulletTracer.setRainbow(v) end, { flag = "bt_rainbow" })
tracerGroup:Checkbox("fade", false, function(v) BulletTracer.setFade(v) end, { flag = "bt_fade" })
tracerGroup:Slider("fade duration", { min = 0.1, max = 5, default = 1.5, decimals = 1, flag = "bt_faded" }, function(v) BulletTracer.setFadeDuration(v) end)
tracerGroup:Checkbox("local only", true, function(v) BulletTracer.setLocalOnly(v) end, { flag = "bt_localonly" })
tracerGroup:Slider("max distance", { min = 1, max = 500, default = 15, int = true, flag = "bt_maxd" }, function(v) BulletTracer.setMaxDist(v) end)
tracerGroup:Slider("light emission", { min = 0, max = 20, default = 10, decimals = 1, flag = "bt_le" }, function(v) BulletTracer.setLightEmission(v) end)
tracerGroup:Slider("width", { min = 0.1, max = 5, default = 1, decimals = 1, flag = "bt_w" }, function(v) BulletTracer.setWidth(v) end)
tracerGroup:Slider("duration", { min = 0.5, max = 10, default = 3, decimals = 1, flag = "bt_d" }, function(v) BulletTracer.setDuration(v) end)
tracerGroup:Textbox("beam name", "gb", function(v) BulletTracer.setBeamName(v) end, "bt_bn")
tracerGroup:Slider("texture length", { min = 1, max = 50, default = 10, int = true, flag = "bt_tl" }, function(v) BulletTracer.setTextureLength(v) end)
tracerGroup:Slider("z offset", { min = -5, max = 5, default = -1, decimals = 1, flag = "bt_zo" }, function(v) BulletTracer.setZOffset(v) end)

-- MISC
local miscGroup = miscTab:Group("misc")
miscGroup:CheckboxKeybind("rapid fire", false, Enum.KeyCode.F, function(v)
    RapidFire.setEnabled(v)
end, "misc_rf")
miscGroup:Slider("fire rate", { min = 0.005, max = 1, default = 0.015, decimals = 3, flag = "misc_rfr" },
    function(v) RapidFire.setFireRate(v) end)

local armorGroup = miscTab:Group("auto armor")
local armorOptions = { "no armors found" }
armorGroup:Combo("armor", armorOptions, 1, function(i, v)
    if v ~= "no armors found" then AutoArmor.setSelected(v) end
end, "aa_armor")
armorGroup:CheckboxKeybind("enabled", false, nil, function(v)
    AutoArmor.setEnabled(v)
    if v and #AutoArmor.armors == 0 then AutoArmor.scan() end
end, "aa_enabled")
armorGroup:Button("refresh armors", function()
    AutoArmor.scan()
    local names = AutoArmor.get_names()
    Library:Notify("auto armor", "found " .. tostring(#names) .. " armor(s)", 3)
end)

Library:BuildSettings(win)
Library:BindToggle(win)

-- ============================================================
-- HOOKS + BOOT
-- ============================================================
Aimlock.onLockChange = function(locked, target)
    if locked and target then
        Library:Notify("locked", target.DisplayName or target.Name, 2)
    else
        Library:Notify("unlocked", "target released", 2)
    end
end

Library:Notify("xylo.lol", "beta free loaded", 3)
