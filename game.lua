local RunService, UserInputService, TweenService, Players =
    game:GetService("RunService"),
    game:GetService("UserInputService"),
    game:GetService("TweenService"),
    game:GetService("Players")

local Config = {
    Gravity = 2600,
    JumpVelocity = 830,
    StartSpeed = 330,
    MaxSpeed = 940,
    SpeedRamp = 12,
    ArenaWidth = 612,
    ArenaHeight = 236,
    GroundTop = 196,
    DinoX = 54,
    PixelSize = 2,
    BirdThreshold = 3000,
    ScoreFile = "zekehub_runner_highscore.txt",
    Invite = "discord.gg/zekehub"
}

local Palette = {
    Panel = Color3.fromRGB(22, 22, 28),
    Background = Color3.fromRGB(16, 16, 20),
    Line = Color3.fromRGB(58, 58, 70),
    Text = Color3.fromRGB(235, 235, 245),
    Dim = Color3.fromRGB(130, 130, 148),
    Accent = Color3.fromRGB(140, 128, 255),
    Cactus = Color3.fromRGB(92, 196, 132),
    Bird = Color3.fromRGB(235, 120, 130),
    Dead = Color3.fromRGB(235, 90, 100),
    Cloud = Color3.fromRGB(40, 40, 50),
    Button = Color3.fromRGB(34, 34, 42)
}

local Sprites = {}
local Utilities = {}
local Interface = {}

local Runner = {}
Runner.__index = Runner

do
    Sprites.DinoRunA = {
        "...............####.",
        "..............######",
        "..............#.####",
        "..............######",
        "..............####..",
        "..............###...",
        "#.............####..",
        "##...........#####..",
        "###.........#######.",
        "####.......#########",
        "#####.....##########",
        "###################.",
        "##################..",
        ".#################..",
        "..###############...",
        "...#############....",
        "....###########.....",
        "....####...####.....",
        "....###.....###.....",
        "....##.......##.....",
        "....##.......###....",
        "...####......###...."
    }

    Sprites.DinoRunB = {
        "...............####.",
        "..............######",
        "..............#.####",
        "..............######",
        "..............####..",
        "..............###...",
        "#.............####..",
        "##...........#####..",
        "###.........#######.",
        "####.......#########",
        "#####.....##########",
        "###################.",
        "##################..",
        ".#################..",
        "..###############...",
        "...#############....",
        "....###########.....",
        "....####...####.....",
        "....###.....###.....",
        "....###......##.....",
        "...####......##.....",
        "...####.....####...."
    }

    Sprites.DinoDuckA = {
        "......................####.",
        ".....................######",
        ".....................#.####",
        "#....................######",
        "##...................####..",
        "###........................",
        "##########################.",
        "##########################.",
        ".#####################.....",
        "..#####...#####............",
        "..####.....####............",
        "..###.......###............"
    }

    Sprites.DinoDuckB = {
        "......................####.",
        ".....................######",
        ".....................#.####",
        "#....................######",
        "##...................####..",
        "###........................",
        "##########################.",
        "##########################.",
        ".#####################.....",
        "..####.....#####...........",
        "..###.......####...........",
        ".####........###..........."
    }

    Sprites.BirdA = {
        "......####....",
        ".....######...",
        "....########..",
        "##############",
        "#....########.",
        ".......#####..",
        "........###..."
    }

    Sprites.BirdB = {
        "........###...",
        ".......#####..",
        "##############",
        "#....########.",
        "....########..",
        ".....######...",
        "......####...."
    }

    Sprites.CactusSmall = {
        "..###..",
        "..###..",
        "#.###..",
        "#.###.#",
        "#.###.#",
        "#.###.#",
        "#######",
        ".#####.",
        "..###..",
        "..###..",
        "..###..",
        "..###..",
        "..###..",
        "..###..",
        "..###..",
        "..###.."
    }

    Sprites.CactusTall = {
        "...###...",
        "...###...",
        "...###...",
        "#..###...",
        "#..###..#",
        "#..###..#",
        "#..###..#",
        "##.###..#",
        "#######.#",
        ".########",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###...",
        "...###..."
    }

    Sprites.CactusPair = {
        "..###......###..",
        "..###......###..",
        "#.###.....####..",
        "#.###.#..#.###.#",
        "#.###.#..#.###.#",
        "#####.#..#.###.#",
        ".#####...#######",
        "..###.....#####.",
        "..###......###..",
        "..###......###..",
        "..###......###..",
        "..###......###..",
        "..###......###..",
        "..###......###..",
        "..###......###..",
        "..###......###.."
    }

    Sprites.CactusPool = { Sprites.CactusSmall, Sprites.CactusTall, Sprites.CactusPair }
end

do
    function Utilities.GetParent()
        if gethui then
            return gethui()
        end

        local ok, coreGui = pcall(game.GetService, game, "CoreGui")
        if ok and coreGui then
            return coreGui
        end

        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    function Utilities.New(class, props, children)
        local instance = Instance.new(class)

        for key, value in props or {} do
            if key ~= "Parent" then
                instance[key] = value
            end
        end

        for _, child in children or {} do
            child.Parent = instance
        end

        if props and props.Parent then
            instance.Parent = props.Parent
        end

        return instance
    end

    function Utilities.Corner(radius)
        return Utilities.New("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
    end

    function Utilities.Measure(pattern)
        local width = 0

        for _, row in pattern do
            width = math.max(width, #row)
        end

        return width * Config.PixelSize, #pattern * Config.PixelSize
    end

    function Utilities.BuildSprite(pattern, color, parent)
        local width, height = Utilities.Measure(pattern)

        local holder = Utilities.New("Frame", {
            Size = UDim2.fromOffset(width, height),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = parent
        })

        for row, line in pattern do
            local column = 1

            while column <= #line do
                if line:sub(column, column) == "#" then
                    local start = column

                    while column <= #line and line:sub(column, column) == "#" do
                        column += 1
                    end

                    Utilities.New("Frame", {
                        Position = UDim2.fromOffset((start - 1) * Config.PixelSize, (row - 1) * Config.PixelSize),
                        Size = UDim2.fromOffset((column - start) * Config.PixelSize, Config.PixelSize),
                        BackgroundColor3 = color,
                        BorderSizePixel = 0,
                        Parent = holder
                    })
                else
                    column += 1
                end
            end
        end

        return holder, width, height
    end

    function Utilities.Tint(color, ...)
        for _, holder in { ... } do
            for _, pixel in holder:GetChildren() do
                if pixel:IsA("Frame") then
                    pixel.BackgroundColor3 = color
                end
            end
        end
    end

    function Utilities.LoadHighScore()
        local ok, value = pcall(function()
            if isfile and isfile(Config.ScoreFile) then
                return tonumber(readfile(Config.ScoreFile)) or 0
            end
            return 0
        end)

        return ok and value or 0
    end

    function Utilities.SaveHighScore(score)
        pcall(function()
            if writefile then
                writefile(Config.ScoreFile, tostring(score))
            end
        end)
    end

    function Utilities.CopyDiscord()
        pcall(setclipboard, Config.Invite)
    end

    function Utilities.Overlaps(ax, ay, aw, ah, bx, by, bw, bh)
        return ax + aw > bx and ax < bx + bw and ay + ah > by and ay < by + bh
    end
end

do
    function Interface.Build(opts)
        local elements = {}

        elements.Gui = Utilities.New("ScreenGui", {
            Name = "\0" .. tostring(math.random(1e6, 1e7)),
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            Parent = Utilities.GetParent()
        })

        local shade = Utilities.New("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = elements.Gui
        })

        TweenService:Create(shade, TweenInfo.new(0.35), { BackgroundTransparency = 0.4 }):Play()

        elements.Panel = Utilities.New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(660, 400),
            BackgroundColor3 = Palette.Panel,
            BorderSizePixel = 0,
            Parent = elements.Gui
        }, { Utilities.Corner(12) })

        Utilities.New("UIStroke", {
            Color = Palette.Line,
            Thickness = 1,
            Transparency = 0.4,
            Parent = elements.Panel
        })

        Utilities.New("TextLabel", {
            Position = UDim2.fromOffset(24, 20),
            Size = UDim2.fromOffset(500, 24),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = opts.Title or "ZekeHub is down",
            TextColor3 = Palette.Text,
            TextSize = 19,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = elements.Panel
        })

        Utilities.New("TextLabel", {
            Position = UDim2.fromOffset(24, 46),
            Size = UDim2.fromOffset(560, 36),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = opts.Subtitle or "no eta. have a game while you wait.",
            TextColor3 = Palette.Dim,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = elements.Panel
        })

        elements.Close = Utilities.New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -20, 0, 18),
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = Palette.Button,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Palette.Dim,
            TextSize = 18,
            Parent = elements.Panel
        }, { Utilities.Corner(6) })

        elements.Arena = Utilities.New("Frame", {
            Position = UDim2.fromOffset(24, 96),
            Size = UDim2.fromOffset(Config.ArenaWidth, Config.ArenaHeight),
            BackgroundColor3 = Palette.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = elements.Panel
        }, { Utilities.Corner(8) })

        Utilities.New("Frame", {
            Position = UDim2.fromOffset(0, Config.GroundTop),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Palette.Line,
            BorderSizePixel = 0,
            Parent = elements.Arena
        })

        elements.Score = Utilities.New("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 0, 12),
            Size = UDim2.fromOffset(240, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            Text = "0",
            TextColor3 = Palette.Dim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = elements.Arena
        })

        elements.Overlay = Utilities.New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.4),
            Size = UDim2.fromOffset(520, 56),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = "",
            TextColor3 = Palette.Text,
            TextSize = 15,
            Parent = elements.Arena
        })

        Utilities.New("TextLabel", {
            Position = UDim2.fromOffset(24, 348),
            Size = UDim2.fromOffset(400, 20),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "space to jump  ·  s to duck",
            TextColor3 = Palette.Dim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = elements.Panel
        })

        elements.Discord = Utilities.New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -20, 0, 344),
            Size = UDim2.fromOffset(150, 28),
            BackgroundColor3 = Palette.Button,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            Text = "copy discord",
            TextColor3 = Palette.Text,
            TextSize = 12,
            Parent = elements.Panel
        }, { Utilities.Corner(6) })

        return elements
    end

    function Interface.BuildScenery(arena)
        local clouds, bumps = {}, {}

        for index = 1, 3 do
            local frame = Utilities.New("Frame", {
                Position = UDim2.fromOffset(math.random(0, Config.ArenaWidth), math.random(20, 90)),
                Size = UDim2.fromOffset(math.random(30, 54), 6),
                BackgroundColor3 = Palette.Cloud,
                BorderSizePixel = 0,
                Parent = arena
            }, { Utilities.Corner(3) })

            table.insert(clouds, { frame = frame, x = frame.Position.X.Offset, speed = math.random(14, 30) })
        end

        for index = 1, 22 do
            local frame = Utilities.New("Frame", {
                Position = UDim2.fromOffset(math.random(0, Config.ArenaWidth), Config.GroundTop + math.random(4, 14)),
                Size = UDim2.fromOffset(math.random(3, 9), 2),
                BackgroundColor3 = Palette.Line,
                BorderSizePixel = 0,
                Parent = arena
            })

            table.insert(bumps, { frame = frame, x = frame.Position.X.Offset, y = frame.Position.Y.Offset })
        end

        return clouds, bumps
    end
end

function Runner:Show(opts)
    opts = opts or {}

    if self._gui then
        self:Hide()
    end

    local elements = Interface.Build(opts)
    local arena = elements.Arena
    local connections = {}

    self._gui = elements.Gui
    self._connections = connections

    local clouds, bumps = Interface.BuildScenery(arena)
    local highScore = Utilities.LoadHighScore()

    local Dino = {}
    local State = {}
    local Obstacles = {}

    do
        local runA, standWidth, standHeight = Utilities.BuildSprite(Sprites.DinoRunA, Palette.Accent, arena)
        local runB = Utilities.BuildSprite(Sprites.DinoRunB, Palette.Accent, arena)
        local duckA, duckWidth, duckHeight = Utilities.BuildSprite(Sprites.DinoDuckA, Palette.Accent, arena)
        local duckB = Utilities.BuildSprite(Sprites.DinoDuckB, Palette.Accent, arena)

        runB.Visible = false
        duckA.Visible = false
        duckB.Visible = false

        Dino.Run = { runA, runB }
        Dino.Duck = { duckA, duckB }
        Dino.All = { runA, runB, duckA, duckB }
        Dino.StandWidth, Dino.StandHeight = standWidth, standHeight
        Dino.DuckWidth, Dino.DuckHeight = duckWidth, duckHeight
        Dino.Floor = Config.GroundTop - standHeight
    end

    State.Phase = "running"
    State.Velocity = 0
    State.Y = Dino.Floor
    State.Ducking = false
    State.Speed = Config.StartSpeed
    State.Distance = 0
    State.StepClock = 0
    State.Frame = 1
    State.NextSpawn = 1.2

    local function activeSprites()
        return State.Ducking and Dino.Duck or Dino.Run
    end

    local function showFrame(index)
        for _, sprite in Dino.All do
            sprite.Visible = false
        end

        activeSprites()[index].Visible = true
    end

    local function positionDino()
        local y = State.Ducking and (Config.GroundTop - Dino.DuckHeight) or State.Y

        for _, sprite in activeSprites() do
            sprite.Position = UDim2.fromOffset(Config.DinoX, math.floor(y))
        end
    end

    local function dinoBox()
        if State.Ducking then
            return Config.DinoX + 4, Config.GroundTop - Dino.DuckHeight + 2, Dino.DuckWidth - 12, Dino.DuckHeight - 4
        end

        return Config.DinoX + 6, State.Y + 4, Dino.StandWidth - 14, Dino.StandHeight - 8
    end

    local function isGrounded()
        return State.Y >= Dino.Floor - 0.5
    end

    local function clearObstacles()
        for _, obstacle in Obstacles do
            obstacle.holder:Destroy()

            if obstacle.alt then
                obstacle.alt:Destroy()
            end
        end

        table.clear(Obstacles)
    end

    local function spawnCactus()
        local pattern = Sprites.CactusPool[math.random(1, #Sprites.CactusPool)]
        local holder, width, height = Utilities.BuildSprite(pattern, Palette.Cactus, arena)
        local y = Config.GroundTop - height

        holder.Position = UDim2.fromOffset(Config.ArenaWidth + 8, y)

        table.insert(Obstacles, {
            holder = holder,
            x = Config.ArenaWidth + 8,
            y = y,
            w = width,
            h = height,
            bird = false
        })
    end

    local function spawnBird()
        local wingsUp, width, height = Utilities.BuildSprite(Sprites.BirdA, Palette.Bird, arena)
        local wingsDown = Utilities.BuildSprite(Sprites.BirdB, Palette.Bird, arena)
        local low = math.random() < 0.5
        local y = low and (Config.GroundTop - height - 26) or (Config.GroundTop - height - 66)

        wingsDown.Visible = false
        wingsUp.Position = UDim2.fromOffset(Config.ArenaWidth + 8, y)
        wingsDown.Position = UDim2.fromOffset(Config.ArenaWidth + 8, y)

        table.insert(Obstacles, {
            holder = wingsUp,
            alt = wingsDown,
            x = Config.ArenaWidth + 8,
            y = y,
            w = width,
            h = height,
            bird = true,
            flap = 0
        })
    end

    local function reset()
        clearObstacles()

        State.Phase = "running"
        State.Velocity = 0
        State.Y = Dino.Floor
        State.Ducking = false
        State.Speed = Config.StartSpeed
        State.Distance = 0
        State.Frame = 1
        State.NextSpawn = 1.2

        elements.Overlay.Text = ""
        Utilities.Tint(Palette.Accent, table.unpack(Dino.All))
        showFrame(1)
        positionDino()
    end

    local function die()
        State.Phase = "dead"
        Utilities.Tint(Palette.Dead, table.unpack(Dino.All))

        local score = math.floor(State.Distance / 10)

        if score > highScore then
            highScore = score
            Utilities.SaveHighScore(highScore)
            elements.Overlay.Text = "new best · " .. score .. "\npress space to retry"
        else
            elements.Overlay.Text = "score " .. score .. "  ·  best " .. highScore .. "\npress space to retry"
        end
    end

    local function jump()
        if State.Phase == "dead" then
            return reset()
        end

        if State.Ducking or not isGrounded() then
            return
        end

        State.Velocity = -Config.JumpVelocity
    end

    local function setDucking(active)
        if State.Phase ~= "running" then
            return
        end

        if active and not isGrounded() then
            State.Velocity = math.max(State.Velocity, Config.Gravity * 0.4)
            return
        end

        if State.Ducking == active then
            return
        end

        State.Ducking = active
        showFrame(State.Frame)
        positionDino()
    end

    showFrame(1)
    positionDino()

    connections[#connections + 1] = RunService.RenderStepped:Connect(function(delta)
        delta = math.min(delta, 1 / 30)

        for _, cloud in clouds do
            cloud.x -= cloud.speed * delta

            if cloud.x < -60 then
                cloud.x = Config.ArenaWidth + math.random(20, 120)
            end

            cloud.frame.Position = UDim2.fromOffset(math.floor(cloud.x), cloud.frame.Position.Y.Offset)
        end

        if State.Phase ~= "running" then
            return
        end

        for _, bump in bumps do
            bump.x -= State.Speed * delta

            if bump.x < -12 then
                bump.x = Config.ArenaWidth + math.random(0, 120)
            end

            bump.frame.Position = UDim2.fromOffset(math.floor(bump.x), bump.y)
        end

        State.Speed = math.min(Config.MaxSpeed, State.Speed + Config.SpeedRamp * delta)
        State.Distance += State.Speed * delta
        State.Velocity += Config.Gravity * delta
        State.Y += State.Velocity * delta

        if State.Y > Dino.Floor then
            State.Y = Dino.Floor
            State.Velocity = 0
        end

        State.StepClock += delta

        if State.StepClock >= 0.09 then
            State.StepClock = 0

            if isGrounded() then
                State.Frame = State.Frame == 1 and 2 or 1
                showFrame(State.Frame)
            end
        end

        positionDino()

        State.NextSpawn -= delta

        if State.NextSpawn <= 0 then
            if State.Distance > Config.BirdThreshold and math.random() < 0.32 then
                spawnBird()
            else
                spawnCactus()
            end

            State.NextSpawn = math.max(0.44, (math.random(150, 320) / 100) * (Config.StartSpeed / State.Speed))
        end

        local dx, dy, dw, dh = dinoBox()

        for index = #Obstacles, 1, -1 do
            local obstacle = Obstacles[index]

            obstacle.x -= State.Speed * delta * (obstacle.bird and 1.18 or 1)

            if obstacle.x + obstacle.w < -30 then
                obstacle.holder:Destroy()

                if obstacle.alt then
                    obstacle.alt:Destroy()
                end

                table.remove(Obstacles, index)
            else
                local x = math.floor(obstacle.x)

                obstacle.holder.Position = UDim2.fromOffset(x, obstacle.y)

                if obstacle.alt then
                    obstacle.alt.Position = UDim2.fromOffset(x, obstacle.y)
                    obstacle.flap += delta

                    if obstacle.flap >= 0.16 then
                        obstacle.flap = 0
                        obstacle.holder.Visible, obstacle.alt.Visible = obstacle.alt.Visible, obstacle.holder.Visible
                    end
                end

                local hit = Utilities.Overlaps(
                    dx, dy, dw, dh,
                    obstacle.x + 2, obstacle.y + 2, obstacle.w - 4, obstacle.h - 4
                )

                if hit then
                    die()
                end
            end
        end

        elements.Score.Text = string.format("%d   best %d", math.floor(State.Distance / 10), highScore)
    end)

    connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        local key = input.KeyCode
        local pointer = input.UserInputType

        if key == Enum.KeyCode.Space or key == Enum.KeyCode.Up or key == Enum.KeyCode.W then
            jump()
        elseif key == Enum.KeyCode.Down or key == Enum.KeyCode.S then
            setDucking(true)
        elseif pointer == Enum.UserInputType.MouseButton1 or pointer == Enum.UserInputType.Touch then
            jump()
        end
    end)

    connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.S then
            setDucking(false)
        end
    end)

    elements.Close.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    elements.Discord.MouseButton1Click:Connect(function()
        Utilities.CopyDiscord()
        elements.Discord.Text = "copied"

        task.delay(1.5, function()
            if elements.Discord.Parent then
                elements.Discord.Text = "copy discord"
            end
        end)
    end)

    return self
end

function Runner:Hide()
    for _, connection in self._connections or {} do
        pcall(function()
            connection:Disconnect()
        end)
    end

    self._connections = nil

    if self._gui then
        pcall(function()
            self._gui:Destroy()
        end)

        self._gui = nil
    end
end

return setmetatable({}, Runner)
