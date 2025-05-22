return function(player, RunService, circleFrame)
    local Players = game:GetService("Players")

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(2.3, 0, 2.3, 0)
    viewport.BackgroundTransparency = 1
    viewport.Position = UDim2.new(-1, -10, -0.6, 0)
    viewport.BorderSizePixel = 0
    viewport.Name = "AvatarViewport"
    viewport.Parent = circleFrame

    local camera = Instance.new("Camera")
    viewport.CurrentCamera = camera
    camera.Parent = viewport

    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        player.CharacterAdded:Wait()
    end

    local humanoid = player.Character:WaitForChild("Humanoid")
    local desc = humanoid:GetAppliedDescription()

    local liveModel = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
    liveModel.Name = "LivePreview"
    liveModel.Parent = workspace
    liveModel:MoveTo(Vector3.new(9999, 9999, 9999))

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://507766388"
    local human = liveModel:FindFirstChildOfClass("Humanoid")
    if human then
        local idleTrack = human:LoadAnimation(anim)
        idleTrack.Looped = true
        idleTrack:Play()
    end

    task.wait(0.1)

    local previewModel = liveModel:Clone()
    liveModel:Destroy()

    for _, part in previewModel:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end

    local head = previewModel:FindFirstChild("Head")
    if head then
        previewModel.PrimaryPart = head
        local offset = head.Position - previewModel:GetPivot().Position
        previewModel:PivotTo(CFrame.new(-offset.X, 1.5, -offset.Z))
    end

    previewModel.Parent = viewport

    local rotationX = 15
    local rotationY = 165
    local currentRotationX = 15
    local currentRotationY = 165
    local dragging = false
    local lastPos = nil

    viewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            lastPos = input.Position
        end
    end)

    viewport.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    viewport.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - lastPos
            rotationY = rotationY - delta.X * 0.5
            rotationX = math.clamp(rotationX + delta.Y * 0.5, -40, 40)
            lastPos = input.Position
        end
    end)

    RunService.RenderStepped:Connect(function()
        if previewModel and previewModel.PrimaryPart then
            currentRotationX += (rotationX - currentRotationX) * 0.15
            currentRotationY += (rotationY - currentRotationY) * 0.15

            local pivot = CFrame.new(0, 0, 0)
            local rotation = CFrame.Angles(math.rad(currentRotationX), math.rad(currentRotationY), 0)
            local camOffset = rotation:VectorToWorldSpace(Vector3.new(0, 0, 7))
            camera.CFrame = CFrame.new(pivot.Position + camOffset, pivot.Position)
        end
    end)
end
