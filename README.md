```markdown
# FluentModded

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Build](https://img.shields.io/badge/build-stable-brightgreen.svg)

**FluentModded** adalah versi modifikasi dari Fluent UI dengan tambahan fitur **MultiSection** yang memungkinkan Anda membuat beberapa section dalam satu tab dengan lebih mudah. Sekarang Anda bisa menggunakan `Toggle` langsung tanpa prefix "Add"!

## 📸 Preview UI

```

┌──────────────────────────────────────┐
│  MultiSection Demo - by FluentModded │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ 📁 Demo Section                   │ │
│ ├──────────────────────────────────┤ │
│ │ ┌──────────────────────────────┐ │ │
│ │ │ Controls                      │ │ │
│ │ ├──────────────────────────────┤ │ │
│ │ │ [ ] ESP                       │ │ │
│ │ │ [ Click ]                     │ │ │
│ │ └──────────────────────────────┘ │ │
│ │ ┌──────────────────────────────┐ │ │
│ │ │ Settings                      │ │ │
│ │ ├──────────────────────────────┤ │ │
│ │ │ ▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰ 16          │ │ │
│ │ │ ▼ Normal                      │ │ │
│ │ └──────────────────────────────┘ │ │
└──────────────────────────────────────┘

```

## 📥 Installation

```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaiSoku1/Fluent/main/Fluent%20Boreal"))()
```

📝 Example Code

Basic Example

```lua
local Window = Fluent:CreateWindow({
    Title = "MultiSection Demo",
    SubTitle = "by Fluent Modded",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "Main", Icon = "home" })

local section = Tab:MultiSection({
    Title = "Demo Section",
    Sections = {
        { Name = "Controls" },
        { Name = "Settings" }
    }
})

local Controls = section["Controls"]
local Settings = section["Settings"]

-- Controls section
Controls:Toggle({
    Title = "ESP",
    Default = false,
    Callback = function(v) 
        print("ESP:", v) 
    end
})

Controls:Button({
    Title = "Click",
    Callback = function() 
        print("Clicked!") 
        Fluent:Notify({
            Title = "Button Clicked",
            Content = "You clicked the button!",
            Duration = 2
        })
    end
})

-- Settings section
Settings:Slider({
    Title = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(v) 
        print("Speed:", v) 
    end
})

Settings:Dropdown({
    Title = "Mode",
    Values = { "Easy", "Normal", "Hard" },
    Default = "Normal",
    Callback = function(v) 
        print("Mode:", v) 
    end
})
```

📁 File example.lua Lengkap

Simpan kode berikut sebagai example.lua:

```lua
-- example.lua
-- FluentModded - Complete Usage Example

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaiSoku1/Fluent/main/Fluent%20Boreal"))()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "FluentModded Demo",
    SubTitle = "MultiSection Example",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark"
})

-- Create Tabs
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })
local InfoTab = Window:AddTab({ Title = "Info", Icon = "info" })

-- ========== MAIN TAB ==========
local mainSection = MainTab:MultiSection({
    Title = "Main Features",
    Sections = {
        { Name = "Combat" },
        { Name = "Visual" },
        { Name = "Movement" }
    }
})

local Combat = mainSection["Combat"]
local Visual = mainSection["Visual"]
local Movement = mainSection["Movement"]

-- Combat Section
Combat:Toggle({
    Title = "Aimbot",
    Description = "Auto aim at enemies",
    Default = true,
    Callback = function(v) print("Aimbot:", v) end
})

Combat:Toggle({
    Title = "Silent Aim",
    Description = "Invisible aimbot",
    Default = false,
    Callback = function(v) print("Silent Aim:", v) end
})

Combat:Dropdown({
    Title = "Aimbot Target",
    Values = { "Head", "Chest", "Random" },
    Default = "Head",
    Callback = function(v) print("Target:", v) end
})

Combat:Slider({
    Title = "Aimbot Smoothness",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(v) print("Smoothness:", v) end
})

-- Visual Section
Visual:Toggle({
    Title = "ESP Box",
    Description = "Show player boxes",
    Default = true,
    Callback = function(v) print("ESP Box:", v) end
})

Visual:Toggle({
    Title = "ESP Name",
    Description = "Show player names",
    Default = true,
    Callback = function(v) print("ESP Name:", v) end
})

Visual:Toggle({
    Title = "ESP Distance",
    Description = "Show distance",
    Default = false,
    Callback = function(v) print("ESP Distance:", v) end
})

Visual:Colorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c) print("Color:", c.R, c.G, c.B) end
})

-- Movement Section
Movement:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(v) print("Speed Hack:", v) end
})

Movement:Slider({
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(v) print("Speed:", v) end
})

Movement:Slider({
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(v) print("Jump:", v) end
})

Movement:Keybind({
    Title = "Speed Toggle Key",
    Default = "LeftShift",
    Mode = "Hold",
    Callback = function(h) print("Holding:", h) end
})

-- ========== SETTINGS TAB ==========
local settingsSection = SettingsTab:MultiSection({
    Title = "Settings",
    Sections = {
        { Name = "Theme" },
        { Name = "Window" }
    }
})

local Theme = settingsSection["Theme"]
local WindowSet = settingsSection["Window"]

-- Theme Section
Theme:Dropdown({
    Title = "Select Theme",
    Values = Fluent.Themes,
    Default = "Dark",
    Callback = function(t) 
        Fluent:SetTheme(t)
        Fluent:Notify({
            Title = "Theme Changed",
            Content = "Theme: " .. t,
            Duration = 2
        })
    end
})

Theme:Colorpicker({
    Title = "Accent Color",
    Default = Color3.fromRGB(0, 150, 255),
    Callback = function(c) print("Accent:", c.R, c.G, c.B) end
})

-- Window Section
WindowSet:Toggle({
    Title = "Acrylic Effect",
    Default = true,
    Callback = function(v) Fluent:ToggleAcrylic(v) end
})

WindowSet:Toggle({
    Title = "Transparency",
    Default = false,
    Callback = function(v) Fluent:ToggleTransparency(v) end
})

WindowSet:Button({
    Title = "Unload GUI",
    Callback = function()
        Window:Dialog({
            Title = "Confirm",
            Content = "Unload GUI?",
            Buttons = {
                {
                    Title = "Yes",
                    Callback = function() Fluent:Destroy() end
                },
                { Title = "No" }
            }
        })
    end
})

-- ========== INFO TAB ==========
local infoSection = InfoTab:MultiSection({
    Title = "Information",
    Sections = {
        { Name = "About" },
        { Name = "Actions" }
    }
})

local About = infoSection["About"]
local Actions = infoSection["Actions"]

-- About Section
About:Paragraph({
    Title = "FluentModded",
    Content = "Version: 1.0.0\nAuthor: BaiSoku1\nMultiSection Support"
})

About:Paragraph({
    Title = "Player Info",
    Content = "Username: " .. game.Players.LocalPlayer.Name
})

-- Actions Section
Actions:Button({
    Title = "Test Notification",
    Callback = function()
        Fluent:Notify({
            Title = "Test",
            Content = "This is a test notification!",
            Duration = 3
        })
    end
})

Actions:Button({
    Title = "Copy User ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.Players.LocalPlayer.UserId))
            Fluent:Notify({
                Title = "Copied!",
                Content = "User ID copied to clipboard",
                Duration = 2
            })
        end
    end
})

-- Initial notification
Fluent:Notify({
    Title = "FluentModded",
    Content = "Loaded successfully!",
    SubContent = "MultiSection example is ready",
    Duration = 4
})
```

🎯 Fitur MultiSection

Dengan MultiSection, Anda bisa mengelompokkan elemen-elemen UI ke dalam section-section yang terpisah dalam satu tab:

```lua
local section = Tab:MultiSection({
    Title = "Judul Utama",
    Sections = {
        { Name = "Section 1" },
        { Name = "Section 2" },
        { Name = "Section 3" }
    }
})

local Section1 = section["Section 1"]
local Section2 = section["Section 2"]
local Section3 = section["Section 3"]

-- Tambahkan elemen ke masing-masing section
Section1:Toggle({ ... })
Section2:Slider({ ... })
Section3:Button({ ... })
```

📋 Semua Method yang Tersedia

Method Deskripsi
:Toggle({}) Membuat toggle switch
:Button({}) Membuat tombol
:Slider({}) Membuat slider
:Dropdown({}) Membuat dropdown
:Input({}) Membuat text input
:Colorpicker({}) Membuat color picker
:Keybind({}) Membuat keybind
:Paragraph({}) Membuat teks informasi

🎨 Tema Tersedia

· Dark
· Darker
· Light
· Aqua
· Amethyst
· Rose
· Crimson
· Azure
· Gold
· Greenish
· Neon

📝 License

MIT License - Silakan digunakan dan dimodifikasi sesuai kebutuhan.

🙏 Credits

· Original Fluent UI by dawid-scripts
· Modified by BaiSoku1 with MultiSection feature

---

⭐ Star repository ini jika bermanfaat! ⭐

```

## Cara Upload ke GitHub

1. **Buat file `README.md`** - Copy paste konten README di atas
2. **Buat folder `examples/`** 
3. **Buat file `examples/example.lua`** - Copy paste kode example lengkap
4. **Upload ke repository**:
```bash
git add README.md examples/
git commit -m "Add README with examples"
git push origin master
```

Sekarang repository Anda memiliki:

· ✅ README dengan preview UI ASCII
· ✅ Contoh kode dasar di README
· ✅ File example.lua lengkap di folder examples/
· ✅ Penjelasan fitur MultiSection
· ✅ Daftar semua method yang tersedia

Pengguna bisa langsung melihat contoh dan mencobanya! 🚀
