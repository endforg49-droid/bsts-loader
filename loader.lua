-- ═══════════════════════════════════════════════════════════════
-- BSTS-ID - LuxxyHub Loader v1.1
-- Protected by Luxxy Key Auth
-- ═══════════════════════════════════════════════════════════════

local WORKER_URL = "https://bsts-key-server.haloyypayo.workers.dev"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ═══ ANTI DOUBLE-RUN ═══
if _G.BSTS_LoaderRunning then
    warn("[BSTS-ID] Loader udah jalan, skip duplikat.")
    return
end
_G.BSTS_LoaderRunning = true

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
-- Cek di PlayerGui DAN CoreGui
pcall(function()
    local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BSTS_KeyUI")
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
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")  -- FIX: Pakai PlayerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 0.4
backdrop.BorderSizePixel = 0
backdrop.ZIndex = 1
backdrop.Parent = sg

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 290)  -- FIX: Langsung final size!
Main.Position = UDim2.new(0.5, -190, 0.5, -145)
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.BackgroundTransparency = 1  -- Start transparent (buat fade in)
Main.ZIndex = 10
Main.Parent = sg

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 16)
mc.Parent = Main

local mg = Instance.new("UIGradient")
mg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 60, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 130, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 40)),
})
mg.Rotation = 45
mg.Parent = Main

local ms = Instance.new("UIStroke")
ms.Thickness = 2
ms.Color = Color3.fromRGB(0, 255, 150)
ms.Transparency = 0.3
ms.Parent = Main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 20, 0, 15)
title.BackgroundTransparency = 1
title.Text = "BSTS-ID - LuxxyHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 20
title.Parent = Main

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -40, 0, 15)
sub.Position = UDim2.new(0, 20, 0, 52)
sub.BackgroundTransparency = 1
sub.Text = "Masukkan key untuk akses script"
sub.TextColor3 = Color3.fromRGB(180, 255, 220)
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Center
sub.ZIndex = 20
sub.Parent = Main

local div = Instance.new("Frame")
div.Size = UDim2.new(1, -60, 0, 1)
div.Position = UDim2.new(0, 30, 0, 78)
div.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
div.BackgroundTransparency = 0.5
div.BorderSizePixel = 0
div.ZIndex = 20
div.Parent = Main

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -40, 0, 45)
input.Position = UDim2.new(0, 20, 0, 95)
input.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
input.BorderSizePixel = 0
input.PlaceholderText = "BSTS-XXXX-XXXX-XXXX"
input.PlaceholderColor3 = Color3.fromRGB(100, 150, 130)
input.Text = ""
input.TextColor3 = Color3.fromRGB(150, 255, 200)
input.Font = Enum.Font.Code
input.TextSize = 14
input.TextXAlignment = Enum.TextXAlignment.Center
input.ClearTextOnFocus = false
input.ZIndex = 100
input.Parent = Main

local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 10)
ic.Parent = input

local istroke = Instance.new("UIStroke")
istroke.Thickness = 1
istroke.Color = Color3.fromRGB(0, 200, 130)
istroke.Transparency = 0.5
istroke.Parent = input

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 18)
status.Position = UDim2.new(0, 20, 0, 145)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(180, 255, 220)
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Center
status.ZIndex = 20
status.Parent = Main

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 42)
btn.Position = UDim2.new(0, 20, 0, 168)
btn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
btn.BorderSizePixel = 0
btn.Text = "VERIFIKASI KEY"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.ZIndex = 100
btn.Parent = Main

local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 10)
bc.Parent = btn

local bg = Instance.new("UIGradient")
bg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 70)),
})
bg.Rotation = 90
bg.Parent = btn

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -40, 0, 28)
clearBtn.Position = UDim2.new(0, 20, 0, 218)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
clearBtn.BorderSizePixel = 0
clearBtn.Text = "CLEAR SAVED KEY"
clearBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 11
clearBtn.ZIndex = 100
clearBtn.Parent = Main

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(0, 8)
cbc.Parent = clearBtn

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 15)
footer.Position = UDim2.new(0, 20, 1, -22)
footer.BackgroundTransparency = 1
footer.Text = "1 Key = 1 Device (HWID Locked)"
footer.TextColor3 = Color3.fromRGB(120, 180, 150)
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 20
footer.Parent = Main

-- FIX: Animasi cuma fade in, size GAK diubah
task.spawn(function()
    pcall(function()
        TweenService:Create(Main, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    end)
end)

-- ═══ LOAD SCRIPT ═══
local isProcessing = false

local function loadScript(key)
    if isProcessing then return end
    isProcessing = true

    status.Text = "Memverifikasi..."
    status.TextColor3 = Color3.fromRGB(255, 200, 60)
    btn.Text = "TUNGGU..."

    local hwid = getHWID()
    local url = WORKER_URL .. "/get-script?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)

    task.spawn(function()
        local ok, resp = pcall(function() return game:HttpGet(url, true) end)

        if not ok or not resp then
            status.Text = "Gagal konek ke server"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.Text = "VERIFIKASI KEY"
            isProcessing = false
            return
        end

        local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
        if not ok2 or not data then
            status.Text = "Response server invalid"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.Text = "VERIFIKASI KEY"
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
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.Text = "VERIFIKASI KEY"
            isProcessing = false
            return
        end

        if not data.script then
            status.Text = "Script tidak ditemukan"
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.Text = "VERIFIKASI KEY"
            isProcessing = false
            return
        end

        saveKeyFile(key)
        status.Text = "Berhasil! Memuat script..."
        status.TextColor3 = Color3.fromRGB(80, 255, 150)
        btn.Text = "LOADING..."

        task.wait(0.5)
        sg:Destroy()

        local fn, err = loadstring(data.script)
        if fn then
            fn()
        else
            warn("[BSTS-ID] Script error: " .. tostring(err))
        end
    end)
end

-- ═══ EVENTS ═══
btn.MouseButton1Click:Connect(function()
    local k = input.Text
    if not k or #k < 10 then
        status.Text = "Key tidak boleh kosong!"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
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
    status.TextColor3 = Color3.fromRGB(255, 200, 60)
end)

-- ═══ AUTO-LOGIN ═══
task.spawn(function()
    local savedKey = loadKeyFile()
    if savedKey then
        input.Text = savedKey
        status.Text = "Auto-login..."
        status.TextColor3 = Color3.fromRGB(255, 200, 60)
        task.wait(0.5)
        loadScript(savedKey)
    end
end)
