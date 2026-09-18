-- =========================================================
-- ==== NEVERLOSE KEY SYSTEM v1.0 ====
-- =========================================================

-- ==== НАСТРОЙКИ ====
local MASTER_PASSWORD = "NL"  -- 👈 ПАРОЛЬ NL (поменяй на свой)
local ACCOUNTS_FOLDER = "NeverLoseAccounts"
local ACCOUNTS_FILE = ACCOUNTS_FOLDER .. "/accounts.dat"

-- ==== ФАЙЛОВЫЕ ФУНКЦИИ ====
if not isfolder(ACCOUNTS_FOLDER) then
    makefolder(ACCOUNTS_FOLDER)
end

local function loadAccounts()
    if not isfile(ACCOUNTS_FILE) then
        return {}
    end
    local ok, data = pcall(function() return readfile(ACCOUNTS_FILE) end)
    if not ok or not data or data == "" then
        return {}
    end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then return {} end
    return decoded
end

local function saveAccounts(accounts)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(accounts) end)
    if ok then
        writefile(ACCOUNTS_FILE, encoded)
    end
end

-- ==== ХЕШ ПАРОЛЯ (простой XOR + Base64) ====
local function hashPassword(password)
    local seed = 47
    local bytes = {}
    for i = 1, #password do
        table.insert(bytes, string.char(bit32.bxor(string.byte(password, i), seed)))
    end
    local raw = table.concat(bytes)
    -- Base64
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((raw:gsub('.', function(x)
        local r, bb = '', x:byte()
        for i = 8, 1, -1 do r = r .. (bb % 2^i - bb % 2^(i-1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0) end
        return b:sub(c+1, c+1)
    end) .. ({'', '==', '='})[#raw % 3 + 1])
end

-- ==== СОСТОЯНИЕ ====
local Accounts = loadAccounts()
local CurrentUser = nil
local CurrentSession = nil

-- ==== ГЛАВНОЕ ОКНО ====
local MainWindow = NeverLose:CreateWindow({
    Logo = NeverLose.GlobalLogo,
    Name = "NeverLose",
    Content = "Key System",
    Size = NeverLose.Scales.Default,
    ConfigFolder = "NeverLoseConfigs",
    Enable3DRenderer = false,
    Keybind = "Insert"
})

-- =========================================================
-- ==== ВКЛАДКА: ЛОГИН ====
-- =========================================================
local LoginTab = MainWindow:AddTab({ Icon = 'person', Name = "Login" })
local LoginSection = LoginTab:AddSection({ Name = "ACCOUNT" })

LoginSection:AddLabel('Логин'):AddTextInput({
    Default = "",
    Placeholder = "Введите логин",
    Flag = "login_username",
    Size = 150,
    Callback = function(v) end
})

LoginSection:AddLabel('Пароль'):AddTextInput({
    Default = "",
    Placeholder = "Введите пароль",
    Flag = "login_password",
    Size = 150,
    Callback = function(v) end
})

local loginStatusLabel = LoginSection:AddLabel('Статус: ожидание')

LoginSection:AddLabel('Войти'):AddButton({
    Icon = 'arrow-right-to-portrait-rectangle',
    Name = 'Войти',
    Callback = function()
        local username = NeverLose.Flags["login_username"]:GetValue()
        local password = NeverLose.Flags["login_password"]:GetValue()
        username = string.lower(string.gsub(username, "%s", ""))
        password = string.gsub(password, "%s", "")

        if username == "" or password == "" then
            loginStatusLabel:SetText("Статус: введите логин и пароль")
            NeverLose:CreateNotification().new({
                Title = "Ошибка", Content = "Пустые поля", Duration = 3
            })
            return
        end

        if Accounts[username] and Accounts[username].password == hashPassword(password) then
            CurrentUser = username
            CurrentSession = HttpService:GenerateGUID(false)
            loginStatusLabel:SetText("Статус: вошёл как " .. username)
            NeverLose:CreateNotification().new({
                Title = "Успех", Content = "Вы вошли как " .. username, Duration = 4
            })
        else
            loginStatusLabel:SetText("Статус: неверный логин/пароль")
            NeverLose:CreateNotification().new({
                Title = "Ошибка", Content = "Неверные данные", Duration = 3
            })
        end
    end
})

-- =========================================================
-- ==== ВКЛАДКА: РЕГИСТРАЦИЯ ====
-- =========================================================
local RegisterTab = MainWindow:AddTab({ Icon = 'person-plus', Name = "Register" })
local RegisterSection = RegisterTab:AddSection({ Name = "CREATE ACCOUNT" })

RegisterSection:AddLabel('Логин'):AddTextInput({
    Default = "",
    Placeholder = "Минимум 3 символа",
    Flag = "reg_username",
    Size = 150,
    Callback = function(v) end
})

RegisterSection:AddLabel('Пароль'):AddTextInput({
    Default = "",
    Placeholder = "Минимум 4 символа",
    Flag = "reg_password",
    Size = 150,
    Callback = function(v) end
})

RegisterSection:AddLabel('Повтор пароля'):AddTextInput({
    Default = "",
    Placeholder = "Повтори пароль",
    Flag = "reg_password2",
    Size = 150,
    Callback = function(v) end
})

local registerStatusLabel = RegisterSection:AddLabel('Статус: ожидание')

RegisterSection:AddLabel('Создать аккаунт'):AddButton({
    Icon = 'person-plus',
    Name = 'Создать',
    Callback = function()
        local username = NeverLose.Flags["reg_username"]:GetValue()
        local password = NeverLose.Flags["reg_password"]:GetValue()
        local password2 = NeverLose.Flags["reg_password2"]:GetValue()

        username = string.lower(string.gsub(username, "%s", ""))
        password = string.gsub(password, "%s", "")
        password2 = string.gsub(password2, "%s", "")

        if #username < 3 then
            registerStatusLabel:SetText("Статус: логин слишком короткий")
            return
        end
        if #password < 4 then
            registerStatusLabel:SetText("Статус: пароль слишком короткий")
            return
        end
        if password ~= password2 then
            registerStatusLabel:SetText("Статус: пароли не совпадают")
            return
        end
        if Accounts[username] then
            registerStatusLabel:SetText("Статус: логин занят")
            return
        end

        Accounts[username] = {
            password = hashPassword(password),
            created = os.date("%Y-%m-%d %H:%M:%S"),
            banned = false
        }
        saveAccounts(Accounts)

        registerStatusLabel:SetText("Статус: аккаунт создан!")
        NeverLose:CreateNotification().new({
            Title = "Успех", Content = "Аккаунт " .. username .. " создан", Duration = 4
        })
    end
})

-- =========================================================
-- ==== ВКЛАДКА: АДМИН (пароль NL) ====
-- =========================================================
local AdminTab = MainWindow:AddTab({ Icon = 'shield-check', Name = "Admin" })
local AdminSection = AdminTab:AddSection({ Name = "MASTER" })

AdminSection:AddLabel('Пароль NL'):AddTextInput({
    Default = "",
    Placeholder = "Введите пароль NL",
    Flag = "admin_password",
    Size = 150,
    Callback = function(v) end
})

local adminStatusLabel = AdminSection:AddLabel('Статус: не авторизован')
local isAdmin = false

AdminSection:AddLabel('Войти как админ'):AddButton({
    Icon = 'key',
    Name = 'Войти',
    Callback = function()
        local pass = NeverLose.Flags["admin_password"]:GetValue()
        pass = string.gsub(pass, "%s", "")

        if pass == MASTER_PASSWORD then
            isAdmin = true
            adminStatusLabel:SetText("Статус: АДМИН ✔")
            NeverLose:CreateNotification().new({
                Title = "Admin", Content = "Доступ разрешён", Duration = 4
            })
        else
            isAdmin = false
            adminStatusLabel:SetText("Статус: неверный пароль")
        end
    end
})

AdminSection:AddLabel('Показать список аккаунтов'):AddButton({
    Icon = 'list-bulleted',
    Name = 'Список',
    Callback = function()
        if not isAdmin then
            NeverLose:CreateNotification().new({
                Title = "Admin", Content = "Сначала войдите как админ", Duration = 3
            })
            return
        end
        local list = {}
        for name, data in pairs(Accounts) do
            table.insert(list, name .. " (" .. (data.banned and "BAN" or "OK") .. ")")
        end
        if #list == 0 then
            NeverLose:CreateNotification().new({
                Title = "Аккаунты", Content = "Пусто", Duration = 3
            })
        else
            NeverLose:CreateNotification().new({
                Title = "Аккаунты", Content = table.concat(list, ", "), Duration = 6
            })
        end
    end
})

AdminSection:AddLabel('Очистить все аккаунты'):AddButton({
    Icon = 'trash-can',
    Name = 'Очистить',
    Callback = function()
        if not isAdmin then return end
        Accounts = {}
        saveAccounts(Accounts)
        NeverLose:CreateNotification().new({
            Title = "Admin", Content = "Все аккаунты удалены", Duration = 4
        })
    end
})

-- =========================================================
-- ==== ВКЛАДКА: ГЛАВНОЕ МЕНЮ (доступно после логина) ====
-- =========================================================
local GameTab = MainWindow:AddTab({ Icon = 'crosshairs', Name = "Game" })
local GameSection = GameTab:AddSection({ Name = "FEATURES" })

GameSection:AddLabel('Speed Hack'):AddToggle({
    Default = false, Flag = "speed_hack",
    Callback = function(v)
        if not CurrentUser then
            NeverLose:CreateNotification().new({
                Title = "Доступ", Content = "Войдите в аккаунт", Duration = 3
            })
            return
        end
        print("Speed:", v)
    end
})

GameSection:AddLabel('Jump Power'):AddToggle({
    Default = false, Flag = "jump_hack",
    Callback = function(v) print("Jump:", v) end
})

GameSection:AddLabel('ESP'):AddToggle({
    Default = false, Flag = "esp",
    Callback = function(v) print("ESP:", v) end
})

-- =========================================================
-- ==== УВЕДОМЛЕНИЕ ПРИ СТАРТЕ ====
-- =========================================================
NeverLose:CreateNotification().new({
    Title = "NeverLose",
    Content = "Система ключей загружена",
    Duration = 5
})

task.delay(1, function()
    NeverLose:CreateNotification().new({
        Title = "Вход",
        Content = "Войдите или зарегистрируйтесь",
        Duration = 6
    })
end)
