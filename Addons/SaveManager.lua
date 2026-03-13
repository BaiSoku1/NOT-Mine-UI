local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.History = {}
	SaveManager.HistoryLimit = 10
	
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = tonumber(object.Value) }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { 
					type = "Colorpicker", 
					idx = idx, 
					value = { object.Value.R, object.Value.G, object.Value.B },
					transparency = object.Transparency 
				}
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					local color = Color3.new(data.value[1], data.value[2], data.value[3])
					SaveManager.Options[idx]:SetValueRGB(color, data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in ipairs(list) do
			self.Ignore[key] = true
		end
	end

	function SaveManager:AddToIgnore(key)
		self.Ignore[key] = true
	end

	function SaveManager:RemoveFromIgnore(key)
		self.Ignore[key] = nil
	end

	function SaveManager:ClearIgnore()
		self.Ignore = {}
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
		return self
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. "/settings",
			self.Folder .. "/backups",
			self.Folder .. "/templates"
		}

		for _, path in ipairs(paths) do
			if not isfolder(path) then
				makefolder(path)
			end
		end
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
		return self
	end

	function SaveManager:GetConfigPath(name)
		return self.Folder .. "/settings/" .. name .. ".json"
	end

	function SaveManager:ValidateConfigName(name)
		if type(name) ~= "string" then
			return false, "config name must be a string"
		end
		name = name:gsub("%s+", " ")
		if name == "" or name:match("^%s+$") then
			return false, "config name cannot be empty"
		end
		if name:match("[<>:\"/\\|?*]") then
			return false, "config name contains invalid characters"
		end
		if #name > 50 then
			return false, "config name is too long (max 50 characters)"
		end
		return true, name
	end

	function SaveManager:AddToHistory(name, operation)
		table.insert(self.History, 1, {
			name = name,
			operation = operation,
			timestamp = os.time(),
			date = os.date("%Y-%m-%d %H:%M:%S")
		})
		
		if #self.History > self.HistoryLimit then
			table.remove(self.History)
		end
	end

	function SaveManager:GetHistory()
		return self.History
	end

	function SaveManager:ClearHistory()
		self.History = {}
	end

	function SaveManager:Save(name)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local fullPath = self:GetConfigPath(name)

		local data = {
			metadata = {
				version = "1.0",
				created = os.time(),
				modified = os.time(),
				saveManager = "Fluent"
			},
			objects = {}
		}

		for idx, option in pairs(self.Options) do
			if self.Parser[option.Type] and not self.Ignore[idx] then
				local saved = self.Parser[option.Type].Save(idx, option)
				if saved then
					table.insert(data.objects, saved)
				end
			end
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "failed to encode data"
		end

		local writeSuccess, writeErr = pcall(writefile, fullPath, encoded)
		if not writeSuccess then
			return false, "failed to write file: " .. tostring(writeErr)
		end

		self:AddToHistory(name, "save")
		return true, "config saved successfully"
	end

	function SaveManager:Load(name)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local file = self:GetConfigPath(name)
		if not isfile(file) then 
			return false, "config file does not exist" 
		end

		local readSuccess, content = pcall(readfile, file)
		if not readSuccess then
			return false, "failed to read file"
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, content)
		if not success then
			return false, "invalid config format"
		end

		if not decoded.objects or type(decoded.objects) ~= "table" then
			return false, "invalid config structure"
		end

		local loadCount = 0
		for _, option in ipairs(decoded.objects) do
			if self.Parser[option.type] then
				task.spawn(function()
					self.Parser[option.type].Load(option.idx, option)
				end)
				loadCount = loadCount + 1
			end
		end

		self:AddToHistory(name, "load")
		return true, string.format("loaded %d options", loadCount)
	end

	function SaveManager:Delete(name)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local file = self:GetConfigPath(name)
		if not isfile(file) then
			return false, "config file does not exist"
		end

		local backupPath = self.Folder .. "/backups/" .. name .. "_" .. os.time() .. ".json"
		pcall(writefile, backupPath, readfile(file))
		
		pcall(delfile, file)

		local autoloadPath = self.Folder .. "/settings/autoload.txt"
		if isfile(autoloadPath) and readfile(autoloadPath) == name then
			pcall(delfile, autoloadPath)
		end

		self:AddToHistory(name, "delete")
		return true, "config deleted successfully"
	end

	function SaveManager:Rename(oldName, newName)
		local validOld, errOld = self:ValidateConfigName(oldName)
		local validNew, errNew = self:ValidateConfigName(newName)
		
		if not validOld then
			return false, errOld
		end
		if not validNew then
			return false, errNew
		end

		local oldPath = self:GetConfigPath(oldName)
		local newPath = self:GetConfigPath(newName)

		if not isfile(oldPath) then
			return false, "source config does not exist"
		end

		if isfile(newPath) then
			return false, "destination config already exists"
		end

		local success, content = pcall(readfile, oldPath)
		if not success then
			return false, "failed to read source file"
		end

		local writeSuccess, writeErr = pcall(writefile, newPath, content)
		if not writeSuccess then
			return false, "failed to write new file"
		end

		pcall(delfile, oldPath)

		local autoloadPath = self.Folder .. "/settings/autoload.txt"
		if isfile(autoloadPath) and readfile(autoloadPath) == oldName then
			writefile(autoloadPath, newName)
		end

		self:AddToHistory(oldName, "rename")
		return true, "config renamed successfully"
	end

	function SaveManager:Duplicate(sourceName, targetName)
		local validSource, errSource = self:ValidateConfigName(sourceName)
		local validTarget, errTarget = self:ValidateConfigName(targetName)
		
		if not validSource then
			return false, errSource
		end
		if not validTarget then
			return false, errTarget
		end

		local sourcePath = self:GetConfigPath(sourceName)
		local targetPath = self:GetConfigPath(targetName)

		if not isfile(sourcePath) then
			return false, "source config does not exist"
		end

		if isfile(targetPath) then
			return false, "destination config already exists"
		end

		local success, content = pcall(readfile, sourcePath)
		if not success then
			return false, "failed to read source file"
		end

		local writeSuccess, writeErr = pcall(writefile, targetPath, content)
		if not writeSuccess then
			return false, "failed to write destination file"
		end

		return true, "config duplicated successfully"
	end

	function SaveManager:CreateTemplate(name, description)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local templatePath = self.Folder .. "/templates/" .. name .. ".json"
		
		if isfile(templatePath) then
			return false, "template already exists"
		end

		local data = {
			metadata = {
				name = name,
				description = description or "",
				created = os.time(),
				type = "template"
			},
			objects = {}
		}

		for idx, option in pairs(self.Options) do
			if self.Parser[option.Type] and not self.Ignore[idx] then
				local saved = self.Parser[option.Type].Save(idx, option)
				if saved then
					table.insert(data.objects, saved)
				end
			end
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "failed to encode template"
		end

		writefile(templatePath, encoded)
		return true, "template created successfully"
	end

	function SaveManager:ApplyTemplate(name)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local templatePath = self.Folder .. "/templates/" .. name .. ".json"
		
		if not isfile(templatePath) then
			return false, "template does not exist"
		end

		local success, content = pcall(readfile, templatePath)
		if not success then
			return false, "failed to read template"
		end

		local decoded = httpService:JSONDecode(content)
		if not decoded.objects then
			return false, "invalid template format"
		end

		for _, option in ipairs(decoded.objects) do
			if self.Parser[option.type] then
				task.spawn(function()
					self.Parser[option.type].Load(option.idx, option)
				end)
			end
		end

		return true, "template applied successfully"
	end

	function SaveManager:ListTemplates()
		local templates = {}
		local templateFolder = self.Folder .. "/templates"
		
		if isfolder(templateFolder) then
			for _, file in ipairs(listfiles(templateFolder)) do
				if file:sub(-5) == ".json" then
					local name = file:match("([^/\\]+)%.json$")
					if name then
						table.insert(templates, name)
					end
				end
			end
		end
		
		table.sort(templates)
		return templates
	end

	function SaveManager:DeleteTemplate(name)
		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local templatePath = self.Folder .. "/templates/" .. name .. ".json"
		
		if not isfile(templatePath) then
			return false, "template does not exist"
		end

		pcall(delfile, templatePath)
		return true, "template deleted successfully"
	end

	function SaveManager:RefreshConfigList()
		local configs = {}
		local settingsFolder = self.Folder .. "/settings"
		
		if isfolder(settingsFolder) then
			for _, file in ipairs(listfiles(settingsFolder)) do
				if file:sub(-5) == ".json" and not file:match("autoload") then
					local name = file:match("([^/\\]+)%.json$")
					if name then
						local stat = self:GetConfigInfo(name)
						table.insert(configs, {
							name = name,
							modified = stat.modified,
							size = stat.size
						})
					end
				end
			end
		end
		
		table.sort(configs, function(a, b)
			return (a.modified or 0) > (b.modified or 0)
		end)
		
		local names = {}
		for _, config in ipairs(configs) do
			table.insert(names, config.name)
		end
		
		return names, configs
	end

	function SaveManager:GetConfigInfo(name)
		local path = self:GetConfigPath(name)
		local info = {
			name = name,
			exists = false,
			size = 0,
			modified = 0,
			objects = 0
		}
		
		if isfile(path) then
			info.exists = true
			info.size = math.floor(getfenv().getfenv and getfenv().getfilesize and getfilesize(path) or 0)
			info.modified = getfenv().getfiletime and getfiletime(path) or 0
			
			local success, content = pcall(readfile, path)
			if success then
				local decoded = httpService:JSONDecode(content)
				if decoded.objects then
					info.objects = #decoded.objects
				end
			end
		end
		
		return info
	end

	function SaveManager:GetAutoloadConfig()
		local autoloadPath = self.Folder .. "/settings/autoload.txt"
		if isfile(autoloadPath) then
			return readfile(autoloadPath)
		end
		return nil
	end

	function SaveManager:SetAutoloadConfig(name)
		local autoloadPath = self.Folder .. "/settings/autoload.txt"
		
		if name == nil then
			if isfile(autoloadPath) then
				pcall(delfile, autoloadPath)
			end
			return true, "autoload disabled"
		end

		local valid, err = self:ValidateConfigName(name)
		if not valid then
			return false, err
		end

		local configPath = self:GetConfigPath(name)
		if not isfile(configPath) then
			return false, "config does not exist"
		end

		writefile(autoloadPath, name)
		return true, string.format("autoload set to %q", name)
	end

	function SaveManager:LoadAutoloadConfig()
		local name = self:GetAutoloadConfig()
		if name then
			local success, msg = self:Load(name)
			if success and self.Library then
				self.Library:Notify({
					Title = "Config Loader",
					Content = string.format("Loaded autoload config: %q", name),
					Duration = 3
				})
			end
			return success, msg
		end
		return false, "no autoload config set"
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind", "AnimationToggle"
		})
	end

	function SaveManager:BuildConfigSection(tab, options)
		assert(self.Library, "Must set SaveManager.Library")
		
		options = options or {}
		
		local section = tab:AddSection(options.sectionTitle or "Configuration")

		local configName = section:AddInput("SaveManager_ConfigName", {
			Title = "Config Name",
			Placeholder = "Enter config name..."
		})

		local configList = section:AddDropdown("SaveManager_ConfigList", {
			Title = "Config List",
			Values = self:RefreshConfigList(),
			AllowNull = true
		})

		local configInfo = section:AddParagraph("SaveManager_ConfigInfo", {
			Title = "Config Info",
			Content = "Select a config to view info"
		})
		configInfo.Frame.Visible = false

		configList:OnChanged(function()
			local name = configList.Value
			if name then
				local info = self:GetConfigInfo(name)
				if info.exists then
					configInfo:SetTitle(string.format("Config: %s", name))
					configInfo:SetContent(string.format(
						"Objects: %d | Size: %d bytes",
						info.objects, info.size
					))
					configInfo.Frame.Visible = true
				end
			else
				configInfo.Frame.Visible = false
			end
		end)

		local buttonRow = section:AddParagraph("SaveManager_ButtonRow", {
			Title = "Actions",
			Content = ""
		})

		section:AddButton({
			Title = "Create Config",
			Description = "Save current settings as new config",
			Callback = function()
				local name = configName.Value:gsub("^%s+", ""):gsub("%s+$", "")
				
				if name == "" then 
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "Invalid config name",
						SubContent = "Config name cannot be empty",
						Duration = 5
					})
				end

				local success, msg = self:Save(name)
				if not success then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "Save Failed",
						SubContent = msg,
						Duration = 5
					})
				end

				self.Library:Notify({
					Title = "Config Manager",
					Content = string.format("Config %q created", name),
					Duration = 3
				})

				configList:SetValues(self:RefreshConfigList())
				configName:SetValue("")
			end
		})

		section:AddButton({
			Title = "Load Config",
			Description = "Load selected config",
			Callback = function()
				local name = configList.Value
				if not name then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "No config selected",
						Duration = 3
					})
				end

				local success, msg = self:Load(name)
				if not success then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "Load Failed",
						SubContent = msg,
						Duration = 5
					})
				end

				self.Library:Notify({
					Title = "Config Manager",
					Content = string.format("Loaded config %q", name),
					Duration = 3
				})
			end
		})

		section:AddButton({
			Title = "Overwrite Config",
			Description = "Save current settings to selected config",
			Callback = function()
				local name = configList.Value
				if not name then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "No config selected",
						Duration = 3
					})
				end

				self.Library:Dialog({
					Title = "Overwrite Config",
					Content = string.format("Are you sure you want to overwrite %q?", name),
					Buttons = {
						{
							Title = "Yes",
							Callback = function()
								local success, msg = self:Save(name)
								if not success then
									return self.Library:Notify({
										Title = "Config Manager",
										Content = "Overwrite Failed",
										SubContent = msg,
										Duration = 5
									})
								end

								self.Library:Notify({
									Title = "Config Manager",
									Content = string.format("Overwrote config %q", name),
									Duration = 3
								})
							end
						},
						{ Title = "No" }
					}
				})
			end
		})

		section:AddButton({
			Title = "Delete Config",
			Description = "Delete selected config",
			Callback = function()
				local name = configList.Value
				if not name then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "No config selected",
						Duration = 3
					})
				end

				self.Library:Dialog({
					Title = "Delete Config",
					Content = string.format("Are you sure you want to delete %q?", name),
					Buttons = {
						{
							Title = "Yes",
							Callback = function()
								local success, msg = self:Delete(name)
								if not success then
									return self.Library:Notify({
										Title = "Config Manager",
										Content = "Delete Failed",
										SubContent = msg,
										Duration = 5
									})
								end

								self.Library:Notify({
									Title = "Config Manager",
									Content = string.format("Deleted config %q", name),
									Duration = 3
								})

								configList:SetValues(self:RefreshConfigList())
								configList:SetValue(nil)
							end
						},
						{ Title = "No" }
					}
				})
			end
		})

		section:AddButton({
			Title = "Refresh List",
			Description = "Update config list",
			Callback = function()
				configList:SetValues(self:RefreshConfigList())
				self.Library:Notify({
					Title = "Config Manager",
					Content = "Config list refreshed",
					Duration = 2
				})
			end
		})

		local autoloadSection = tab:AddSection("Autoload")

		local autoloadStatus = autoloadSection:AddParagraph("SaveManager_AutoloadStatus", {
			Title = "Autoload Status",
			Content = "No autoload config set"
		})

		local function updateAutoloadStatus()
			local name = self:GetAutoloadConfig()
			if name then
				autoloadStatus:SetContent(string.format("Current: %q", name))
				setAutoloadBtn:SetTitle("Disable Autoload")
			else
				autoloadStatus:SetContent("No autoload config set")
				setAutoloadBtn:SetTitle("Set as Autoload")
			end
		end

		local setAutoloadBtn = autoloadSection:AddButton({
			Title = "Set as Autoload",
			Description = "Load this config automatically",
			Callback = function()
				local name = configList.Value
				if not name then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "No config selected",
						Duration = 3
					})
				end

				local success, msg = self:SetAutoloadConfig(name)
				if not success then
					return self.Library:Notify({
						Title = "Config Manager",
						Content = "Autoload Failed",
						SubContent = msg,
						Duration = 5
					})
				end

				updateAutoloadStatus()
				self.Library:Notify({
					Title = "Config Manager",
					Content = msg,
					Duration = 3
				})
			end
		})

		local disableAutoloadBtn = autoloadSection:AddButton({
			Title = "Disable Autoload",
			Description = "Remove autoload config",
			Callback = function()
				local success, msg = self:SetAutoloadConfig(nil)
				updateAutoloadStatus()
				self.Library:Notify({
					Title = "Config Manager",
					Content = msg,
					Duration = 3
				})
			end
		})

		updateAutoloadStatus()

		if options.includeTemplates then
			local templateSection = tab:AddSection("Templates")

			local templateName = templateSection:AddInput("SaveManager_TemplateName", {
				Title = "Template Name",
				Placeholder = "Enter template name..."
			})

			local templateList = templateSection:AddDropdown("SaveManager_TemplateList", {
				Title = "Template List",
				Values = self:ListTemplates(),
				AllowNull = true
			})

			templateSection:AddButton({
				Title = "Create Template",
				Description = "Save current settings as template",
				Callback = function()
					local name = templateName.Value:gsub("^%s+", ""):gsub("%s+$", "")
					
					if name == "" then
						return self.Library:Notify({
							Title = "Template Manager",
							Content = "Invalid template name",
							Duration = 3
						})
					end

					local success, msg = self:CreateTemplate(name, "User template")
					if not success then
						return self.Library:Notify({
							Title = "Template Manager",
							Content = "Create Failed",
							SubContent = msg,
							Duration = 5
						})
					end

					self.Library:Notify({
						Title = "Template Manager",
						Content = string.format("Template %q created", name),
						Duration = 3
					})

					templateList:SetValues(self:ListTemplates())
					templateName:SetValue("")
				end
			})

			templateSection:AddButton({
				Title = "Apply Template",
				Description = "Load template settings",
				Callback = function()
					local name = templateList.Value
					if not name then
						return self.Library:Notify({
							Title = "Template Manager",
							Content = "No template selected",
							Duration = 3
						})
					end

					local success, msg = self:ApplyTemplate(name)
					if not success then
						return self.Library:Notify({
							Title = "Template Manager",
							Content = "Apply Failed",
							SubContent = msg,
							Duration = 5
						})
					end

					self.Library:Notify({
						Title = "Template Manager",
						Content = msg,
						Duration = 3
					})
				end
			})

			templateSection:AddButton({
				Title = "Delete Template",
				Description = "Delete selected template",
				Callback = function()
					local name = templateList.Value
					if not name then
						return self.Library:Notify({
							Title = "Template Manager",
							Content = "No template selected",
							Duration = 3
						})
					end

					self.Library:Dialog({
						Title = "Delete Template",
						Content = string.format("Delete template %q?", name),
						Buttons = {
							{
								Title = "Yes",
								Callback = function()
									local success, msg = self:DeleteTemplate(name)
									if not success then
										return self.Library:Notify({
											Title = "Template Manager",
											Content = "Delete Failed",
											SubContent = msg,
											Duration = 5
										})
									end

									self.Library:Notify({
										Title = "Template Manager",
										Content = msg,
										Duration = 3
									})

									templateList:SetValues(self:ListTemplates())
									templateList:SetValue(nil)
								end
							},
							{ Title = "No" }
						}
					})
				end
			})

			templateSection:AddButton({
				Title = "Refresh Templates",
				Description = "Update template list",
				Callback = function()
					templateList:SetValues(self:ListTemplates())
					self.Library:Notify({
						Title = "Template Manager",
						Content = "Template list refreshed",
						Duration = 2
					})
				end
			})
		end

		if options.includeHistory then
			local historySection = tab:AddSection("History")

			local historyList = historySection:AddDropdown("SaveManager_HistoryList", {
				Title = "Recent Actions",
				Values = {},
				AllowNull = true
			})

			local function updateHistory()
				local history = self:GetHistory()
				local items = {}
				for _, entry in ipairs(history) do
					table.insert(items, string.format("[%s] %s: %s", entry.date, entry.operation, entry.name))
				}
				historyList:SetValues(items)
			end

			historySection:AddButton({
				Title = "Refresh History",
				Description = "Update history list",
				Callback = updateHistory
			})

			historySection:AddButton({
				Title = "Clear History",
				Description = "Remove all history entries",
				Callback = function()
					self:ClearHistory()
					updateHistory()
					self.Library:Notify({
						Title = "History",
						Content = "History cleared",
						Duration = 2
					})
				end
			})

			updateHistory()
		end

		self:SetIgnoreIndexes({ 
			"SaveManager_ConfigName", 
			"SaveManager_ConfigList",
			"SaveManager_TemplateName",
			"SaveManager_TemplateList",
			"SaveManager_HistoryList",
			"SaveManager_ConfigInfo",
			"SaveManager_ButtonRow",
			"SaveManager_AutoloadStatus"
		})

		return section
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
