-- ═══════════════════════════════════════════════════════════════
-- BSTS-ID - LuxxyHub Loader v2.0
-- Purple Edition + Background Logo + Animated Border
-- ═══════════════════════════════════════════════════════════════

local WORKER_URL = "https://bsts-key-server.haloyypayo.workers.dev"

-- ═══ IMAGE ASSETS ═══
local IMG_LOGO = "rbxassetid://72484610504506"
local IMG_TOGGLE = "rbxassetid://125806010780793"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══ ANTI DOUBLE-RUN ═══
if _G.BSTS_LoaderRunning then
    warn("[BSTS-ID] Loader udah jalan, skip duplikat.")
    return
end
_G.BSTS_LoaderRunning = true

print("═══════════════════════════════════════════")
print("[BSTS-ID] Loader v2.0 starting...")
print("═══════════════════════════════════════════")
print("[BSTS-ID] Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"))
print("[BSTS-ID] Game: " .. game.Name .. " (PlaceId: " .. game.PlaceId .. ")")

-- ═══ THEME UNGU ═══
local COLOR = {
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Purple1 = Color3.fromRGB(180, 100, 255),
    Purple2 = Color3.fromRGB(140, 60, 220),
    Purple3 = Color3.fromRGB(100, 40, 180),
    PurpleLight = Color3.fromRGB(220, 180, 255),
    BG = Color3.fromRGB(15, 10, 25),
    BG2 = Color3.fromRGB(25, 15, 40),
    Text = Color3.fromRGB(240, 220, 255),
    TextDim = Color3.fromRGB(180, 150, 220),
    Error = Color3.fromRGB(220, 60, 60),
    Success = Color3.fromRGB(80, 200, 100),
    Warning = Color3.fromRGB(255, 200, 60),
}

-- ═══ SAFE GUI PARENT ═══
local function getSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then
        local testOk = pcall(function()
            local t = Instance.new("Frame"); t.Parent = cg; t:Destroy()
        end)
        if testOk then return cg end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then return pg end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

-- ═══ ANIMATION SYSTEM ═══
local _animations = {}
task.spawn(function()
    local t = 0
    while true do
        t = t + 0.05
        for i = #_animations, 1, -1 do
            local item = _animations[i]
            if not item.gradient or not item.gradient.Parent then
                table.remove(_animations, i)
            else
                pcall(function()
                    if item.mode == "rotate" then
                        item.gradient.Rotation = (t * 60) % 360
                    elseif item.mode == "offset" then
                        item.gradient.Offset = Vector2.new(math.sin(t * 0.8) * 0.4, math.cos(t * 0.6) * 0.3)
                    end
                end)
            end
        end
        task.wait(0.05)
    end
end)

local function createAnimatedBorder(parent, cornerRadius, thickness)
    thickness = thickness or 3
    local offset = thickness
    local border = Instance.new("Frame")
    border.Name = "AnimBorder"
    border.Size = UDim2.new(1, offset * 2, 1, offset * 2)
    border.Position = UDim2.new(0, -offset, 0, -offset)
    border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    border.BorderSizePixel = 0
    border.ZIndex = (parent.ZIndex or 0) - 1
    border.Parent = parent
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, (cornerRadius or 18) + offset)
    bc.Parent = border
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(80, 80, 80)),
        ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(80, 80, 80)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 80, 80)),
        ColorSequenceKeypoint.new(0.90, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(80, 80, 80)),
    })
    grad.Parent = border
    table.insert(_animations, {gradient = grad, mode = "rotate"})
    return border, grad
end

-- ═══ GET HWID ═══
local function getHWID()
    local hwid
    pcall(function() if gethwid then hwid = gethwid() end end)
    if hwid then return hwid end
    pcall(function() if syn and syn.get_hwid then hwid = syn.get_hwid() end end)
    if hwid then return hwid end
    local userId = tostring(LocalPlayer.UserId)
    local clientId = "unknown"
    pcall(function() clientId = game:GetService("RbxAnalyticsService"):GetClientId() end)
    return "FB_" .. userId .. "_" .. clientId
end

-- ═══ KEY FILE ═══
local KEY_FILE = "bsts_luxxy_key.txt"

local function saveKeyFile(k)
    if writefile then pcall(function() writefile(KEY_FILE, k) end) end
end
local function loadKeyFile()
    if not (isfile and readfile) then return nil end
    local ok, k = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and k and k ~= "" then return k end
    return nil
end
local function clearKeyFile()
    if delfile and isfile and isfile(KEY_FILE) then
        pcall(function() delfile(KEY_FILE) end)
    end
end

-- ═══ CLEANUP UI LAMA ═══
pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("BSTS_KeyUI")
    if gui then gui:Destroy() end
end)
pcall(function()
    local cg = game:GetService("CoreGui")
    local gui = cg:FindFirstChild("BSTS_KeyUI")
    if gui then gui:Destroy() end
end)

-- ═══ UI ═══
local sg = Instance.new("ScreenGui")
sg.Name = "BSTS_KeyUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = getSafeGuiParent()

-- Backdrop
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.4
backdrop.BorderSizePixel = 0
backdrop.ZIndex = 1
backdrop.Parent = sg

-- Main Wrapper (buat border animated)
local MainWrapper = Instance.new("Frame")
MainWrapper.Name = "MainWrapper"
MainWrapper.Size = UDim2.new(0, 380, 0, 320)
MainWrapper.Position = UDim2.new(0.5, -190, 0.5, -160)
MainWrapper.BackgroundTransparency = 1
MainWrapper.ZIndex = 9
MainWrapper.Parent = sg

-- Main Panel
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(1, 0, 1, 0)
Main.Position = UDim2.new(0, 0, 0, 0)
Main.BackgroundColor3 = COLOR.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.BackgroundTransparency = 1
Main.ClipsDescendants = true
Main.ZIndex = 10
Main.Parent = MainWrapper

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 18)
mc.Parent = Main

-- Gradient ungu
local mg = Instance.new("UIGradient")
mg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR.BG),
    ColorSequenceKeypoint.new(0.5, COLOR.BG2),
    ColorSequenceKeypoint.new(1, COLOR.BG),
})
mg.Rotation = 45
mg.Parent = Main

-- ═══ BACKGROUND LOGO (transparan) ═══
local bgLogo = Instance.new("ImageLabel")
bgLogo.Name = "BgLogo"
bgLogo.Size = UDim2.new(1, 0, 1, 0)
bgLogo.Position = UDim2.new(0, 0, 0, 0)
bgLogo.BackgroundTransparency = 1
bgLogo.Image = IMG_LOGO
bgLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
bgLogo.ImageTransparency = 0.85  -- Sangat transparan
bgLogo.ScaleType = Enum.ScaleType.Fit
bgLogo.ZIndex = 11
bgLogo.Parent = Main

-- ═══ ANIMATED BORDER ═══
createAnimatedBorder(MainWrapper, 18, 3)

-- ═══ CONTENT LAYER (di atas bg) ═══
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.ZIndex = 15
Content.Parent = Main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 20, 0, 18)
title.BackgroundTransparency = 1
title.Text = "BSTS-ID - LuxxyHub"
title.TextColor3 = COLOR.Purple1
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 20
title.Parent = Content

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -40, 0, 15)
sub.Position = UDim2.new(0, 20, 0, 55)
sub.BackgroundTransparency = 1
sub.Text = "Masukkan key untuk akses script"
sub.TextColor3 = COLOR.TextDim
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Center
sub.ZIndex = 20
sub.Parent = Content

-- Divider
local div = Instance.new("Frame")
div.Size = UDim2.new(1, -60, 0, 1)
div.Position = UDim2.new(0, 30, 0, 82)
div.BackgroundColor3 = COLOR.Purple1
div.BackgroundTransparency = 0.5
div.BorderSizePixel = 0
div.ZIndex = 20
div.Parent = Content

-- Input Key
local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -40, 0, 45)
input.Position = UDim2.new(0, 20, 0, 100)
input.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
input.BorderSizePixel = 0
input.PlaceholderText = "BSTS-XXXX-XXXX-XXXX"
input.PlaceholderColor3 = Color3.fromRGB(120, 90, 160)
input.Text = ""
input.TextColor3 = COLOR.PurpleLight
input.Font = Enum.Font.Code
input.TextSize = 14
input.TextXAlignment = Enum.TextXAlignment.Center
input.ClearTextOnFocus = false
input.ZIndex = 100
input.Parent = Content

local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 10)
ic.Parent = input

local istroke = Instance.new("UIStroke")
istroke.Thickness = 1.5
istroke.Color = COLOR.Purple1
istroke.Transparency = 0.4
istroke.Parent = input

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 18)
status.Position = UDim2.new(0, 20, 0, 152)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = COLOR.PurpleLight
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Center
status.ZIndex = 20
status.Parent = Content

-- Verify Button
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 42)
btn.Position = UDim2.new(0, 20, 0, 175)
btn.BackgroundColor3 = COLOR.Purple1
btn.BorderSizePixel = 0
btn.Text = "VERIFIKASI KEY"
btn.TextColor3 = COLOR.White
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.ZIndex = 100
btn.Parent = Content

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 10)
bc.Parent = btn

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLOR.PurpleLight),
    ColorSequenceKeypoint.new(1, COLOR.Purple2),
})
bgGrad.Rotation = 90
bgGrad.Parent = btn

-- Clear Button
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -40, 0, 28)
clearBtn.Position = UDim2.new(0, 20, 0, 225)
clearBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
clearBtn.BorderSizePixel = 0
clearBtn.Text = "CLEAR SAVED KEY"
clearBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 11
clearBtn.ZIndex = 100
clearBtn.Parent = Content

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 8)
cbc.Parent = clearBtn

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 15)
footer.Position = UDim2.new(0, 20, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "1 Key = 1 Device (HWID Locked)"
footer.TextColor3 = COLOR.TextDim
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 20
footer.Parent = Content

-- ═══ FADE IN ═══
task.spawn(function()
    pcall(function()
        TweenService:Create(Main, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    end)
end)

-- ═══ NOTIFIKASI ═══
local function notify(titleText, textText, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titleText or "BSTS-ID - LuxxyHub",
            Text = textText or "",
            Duration = duration or 5,
        })
    end)
end

-- ═══ LOAD SCRIPT ═══
local isProcessing = false

local function loadScript(key)
    if isProcessing then return end
    isProcessing = true

    print("[BSTS-ID] === Memulai verifikasi key ===")
    status.Text = "Memverifikasi..."
    status.TextColor3 = COLOR.Warning
    btn.Text = "TUNGGU..."

    local hwid = getHWID()
    print("[BSTS-ID] HWID: " .. hwid:sub(1, 30) .. "...")
    local url = WORKER_URL .. "/get-script?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)

    task.spawn(function()
        local resp, ok
        for attempt = 1, 3 do
            ok, resp = pcall(function() return game:HttpGet(url, true) end)
            if ok and resp then break end
            print("[BSTS-ID] Attempt " .. attempt .. " gagal, retry...")
            task.wait(0.5)
        end

        if not ok or not resp then
            print("[BSTS-ID] Gagal konek ke server")
            status.Text = "Gagal konek ke server"
            status.TextColor3 = COLOR.Error
            btn.Text = "VERIFIKASI KEY"
            notify("BSTS-ID - LuxxyHub", "Gagal konek ke server. Cek internet!", 5)
            isProcessing = false
            return
        end

        print("[BSTS-ID] Response: " .. resp:sub(1, 100) .. "...")

        local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
        if not ok2 or not data then
            print("[BSTS-ID] Response invalid")
            status.Text = "Response server invalid"
            status.TextColor3 = COLOR.Error
            btn.Text = "VERIFIKASI KEY"
            notify("BSTS-ID - LuxxyHub", "Response server invalid", 5)
            isProcessing = false
            return
        end

        if data.error then
            local msg = data.error
            if msg == "Invalid key" then msg = "Key tidak valid!"
            elseif msg == "Key expired" then msg = "Key sudah expired!"
            elseif msg == "Key locked to another device" then
                msg = "Key dipakai di device lain!"
                clearKeyFile()
            end
            print("[BSTS-ID] Error: " .. data.error)
            status.Text = msg
            status.TextColor3 = COLOR.Error
            btn.Text = "VERIFIKASI KEY"
            notify("BSTS-ID - LuxxyHub", msg, 5)
            isProcessing = false
            return
        end

        if not data.script then
            print("[BSTS-ID] Script kosong")
            status.Text = "Script tidak ditemukan"
            status.TextColor3 = COLOR.Error
            btn.Text = "VERIFIKASI KEY"
            notify("BSTS-ID - LuxxyHub", "Script tidak ditemukan", 5)
            isProcessing = false
            return
        end

        print("[BSTS-ID] Key valid, script size: " .. #data.script .. " chars")

        saveKeyFile(key)

        status.Text = "Berhasil! Memuat script..."
        status.TextColor3 = COLOR.Success
        btn.Text = "LOADING..."

        task.wait(1)
        sg:Destroy()

        print("[BSTS-ID] Compiling script...")
        local fn, err = loadstring(data.script)

        if not fn then
            print("[BSTS-ID] COMPILE ERROR!")
            print("[BSTS-ID] Error: " .. tostring(err))
            warn("[BSTS-ID] Gagal compile script! Error: " .. tostring(err))
            notify("BSTS-ID - LuxxyHub", "Script error. Cek Console Delta!", 7)
            _G.BSTS_LoaderRunning = false
            return
        end

        print("[BSTS-ID] Executing script...")
        local execOk, execErr = pcall(fn)

        if not execOk then
            print("[BSTS-ID] EXECUTE ERROR!")
            print("[BSTS-ID] Error: " .. tostring(execErr))
            warn("[BSTS-ID] Gagal eksekusi script! Error: " .. tostring(execErr))
            notify("BSTS-ID - LuxxyHub", "Error saat menjalankan. Cek Console!", 7)
        else
            print("[BSTS-ID] Script berhasil dijalankan!")
            notify("BSTS-ID - LuxxyHub", "Script berhasil dimuat!", 3)
        end
    end)
end

-- ═══ EVENTS ═══
btn.MouseButton1Click:Connect(function()
    local k = input.Text
    if not k or #k < 10 then
        status.Text = "Key tidak boleh kosong!"
        status.TextColor3 = COLOR.Error
        return
    end
    loadScript(k)
end)

input.FocusLost:Connect(function(enter)
    if enter then
        local k = input.Text
        if k and #k >= 10 then loadScript(k) end
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    clearKeyFile()
    input.Text = ""
    status.Text = "Key tersimpan dihapus"
    status.TextColor3 = COLOR.Warning
    notify("BSTS-ID - LuxxyHub", "Key tersimpan dihapus", 3)
end)

-- ═══ AUTO-LOGIN ═══
task.spawn(function()
    local savedKey = loadKeyFile()
    if savedKey then
        print("[BSTS-ID] Auto-login dengan key tersimpan...")
        input.Text = savedKey
        status.Text = "Auto-login..."
        status.TextColor3 = COLOR.Warning
        task.wait(0.5)
        loadScript(savedKey)
    else
        print("[BSTS-ID] Gak ada key tersimpan, tunggu input manual.")
    end
end)

print("[BSTS-ID] Loader ready!")
