-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteSpy"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Remote Spy"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- Argument Box
local ArgBox = Instance.new("TextBox")
ArgBox.Size = UDim2.new(0.6, -10, 0, 28)
ArgBox.Position = UDim2.new(0, 5, 0, 35)
ArgBox.Text = ""
ArgBox.PlaceholderText = "Argumentumok, vesszővel elválasztva"
ArgBox.ClearTextOnFocus = false
ArgBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
ArgBox.TextColor3 = Color3.fromRGB(255,255,255)
ArgBox.Font = Enum.Font.Code
ArgBox.TextSize = 14
ArgBox.Parent = Frame

-- FireServer Button
local FireBtn = Instance.new("TextButton")
FireBtn.Size = UDim2.new(0.18, -5, 0, 28)
FireBtn.Position = UDim2.new(0.62, 5, 0, 35)
FireBtn.Text = "FireServer"
FireBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
FireBtn.TextColor3 = Color3.new(1,1,1)
FireBtn.Font = Enum.Font.SourceSans
FireBtn.TextSize = 14
FireBtn.Parent = Frame

-- InvokeServer Button
local InvokeBtn = Instance.new("TextButton")
InvokeBtn.Size = UDim2.new(0.18, -5, 0, 28)
InvokeBtn.Position = UDim2.new(0.8, 5, 0, 35)
InvokeBtn.Text = "InvokeServer"
InvokeBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
InvokeBtn.TextColor3 = Color3.new(0,0,0)
InvokeBtn.Font = Enum.Font.SourceSans
InvokeBtn.TextSize = 14
InvokeBtn.Parent = Frame

-- Remote List
local RemoteList = Instance.new("ScrollingFrame")
RemoteList.Size = UDim2.new(0.3, -10, 1, -70)
RemoteList.Position = UDim2.new(0.02, 0, 0, 70)
RemoteList.BackgroundColor3 = Color3.fromRGB(25,25,25)
RemoteList.BorderSizePixel = 0
RemoteList.CanvasSize = UDim2.new(0,0,0,0)
RemoteList.ScrollBarThickness = 6
RemoteList.Parent = Frame

local UIListLayout_Remotes = Instance.new("UIListLayout")
UIListLayout_Remotes.Parent = RemoteList
UIListLayout_Remotes.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Remotes.Padding = UDim.new(0,2)

-- LogBox
local LogBox = Instance.new("ScrollingFrame")
LogBox.Size = UDim2.new(0.65, -10, 0.75, -50)
LogBox.Position = UDim2.new(0.33, 5, 0, 70)
LogBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
LogBox.BorderSizePixel = 0
LogBox.CanvasSize = UDim2.new(0,0,0,0)
LogBox.ScrollBarThickness = 6
LogBox.Parent = Frame

local UIListLayout_Log = Instance.new("UIListLayout")
UIListLayout_Log.Parent = LogBox
UIListLayout_Log.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Log.Padding = UDim.new(0,2)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
CloseBtn.Parent = Frame

local TweenService = game:GetService("TweenService")

local minimized = false
local originalSize = Frame.Size
local collapsedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30) -- csak címsor

CloseBtn.MouseButton1Click:Connect(function()
    local targetSize = minimized and originalSize or collapsedSize
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Frame, tweenInfo, {Size = targetSize})
    tween:Play()
    minimized = not minimized
    tween.Completed:Connect(function()
    for _, child in ipairs(Frame:GetChildren()) do
        if child ~= Title and child ~= CloseBtn then
            child.Visible = not minimized
        end
    end
end)

end)


-- Log helper
local function addLog(text, color)
    color = color or Color3.new(1,1,1)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Text = text
    label.Parent = LogBox
    LogBox.CanvasSize = UDim2.new(0,0,0,UIListLayout_Log.AbsoluteContentSize.Y)
end

-- Kiválasztott Remote
local selectedRemote = nil

-- Összes Remote keresése
local remotes = {}
for _, container in ipairs({Workspace, ReplicatedStorage}) do
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj)
        end
    end
end

-- Remote List feltöltése
for _, remote in ipairs(remotes) do
    local rtype = remote:IsA("RemoteEvent") and "RemoteEvent" or "RemoteFunction"
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Text = remote.Name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = RemoteList

    btn.MouseButton1Click:Connect(function()
        selectedRemote = remote
        addLog("Selected Remote: "..remote.Name.." ["..rtype.."]", Color3.fromRGB(0,255,0))
    end)
end

UIListLayout_Remotes:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RemoteList.CanvasSize = UDim2.new(0,0,0,UIListLayout_Remotes.AbsoluteContentSize.Y)
end)

for _, remote in ipairs(remotes) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local str = ""
            for i,v in ipairs(args) do
                str = str .. tostring(v)
                if i < #args then
                    str = str .. ", "
                end
            end
            addLog("Server → Client ["..remote.Name.."]: "..str, Color3.fromRGB(255,120,0))
        end)
    end
end


-- FireServer
FireBtn.MouseButton1Click:Connect(function()
    if not selectedRemote or not selectedRemote:IsA("RemoteEvent") then
        addLog("Válassz ki egy RemoteEvent-et!", Color3.fromRGB(255,100,100))
        return
    end

    local args = {}
    for part in ArgBox.Text:gmatch("([^,]+)") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed == "true" then
            table.insert(args, true)
        elseif trimmed == "false" then
            table.insert(args, false)
        elseif tonumber(trimmed) then
            table.insert(args, tonumber(trimmed))
        else
            table.insert(args, trimmed)
        end
    end

    local ok, err = pcall(function()
        selectedRemote:FireServer(unpack(args))
    end)
    if ok then
        addLog("Client → Server ["..selectedRemote.Name.."]: "..table.concat(args,", "), Color3.fromRGB(0,170,255))
    else
        addLog("Hiba: "..tostring(err), Color3.fromRGB(255,0,0))
    end
end)

-- InvokeServer
InvokeBtn.MouseButton1Click:Connect(function()
    if not selectedRemote or not selectedRemote:IsA("RemoteFunction") then
        addLog("Válassz ki egy RemoteFunction-t!", Color3.fromRGB(255,100,100))
        return
    end

    local args = {}
    for part in ArgBox.Text:gmatch("([^,]+)") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed == "true" then
            table.insert(args, true)
        elseif trimmed == "false" then
            table.insert(args, false)
        elseif tonumber(trimmed) then
            table.insert(args, tonumber(trimmed))
        else
            table.insert(args, trimmed)
        end
    end

    local ok, res = pcall(function()
        return selectedRemote:InvokeServer(unpack(args))
    end)
    if ok then
        addLog("Client → Server ["..selectedRemote.Name.."]: "..table.concat(args,", ").." -> "..tostring(res), Color3.fromRGB(0,170,255))
    else
        addLog("Hiba: "..tostring(res), Color3.fromRGB(255,0,0))
    end
end)

addLog("RemoteSpy inicializálva!", Color3.fromRGB(0,255,0))
