local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "My Menu",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by me",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightShift
})

local Tab = Window:CreateTab("Main", "home")

Tab:CreateButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
