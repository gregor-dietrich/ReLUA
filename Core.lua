
-- ReLUA Core
if not ReLUA then
	ReLUA = {}
	ReLUA._path = ModPath
	ReLUA._lua_path = ReLUA._path .. "Hooks/"
	ReLUA._menu_file = ReLUA._path .. "Menu/menu.json"
	ReLUA._defaults_file = ReLUA._path .. "default_values.json"

	ReLUA._options_file = SavePath .. "ReLUAOptions.json"
	ReLUA._room_file = SavePath .. "ReLUALastRoomID.txt"
	ReLUA._options = {}
	ReLUA._room_id = nil

	ReLUA._hook_files = {
		["lib/setups/setup"]								= "setup.lua",
		["lib/network/matchmaking/networkmatchmakingsteam"]	= "networkmatchmakingsteam.lua"
	}

	function ReLUA:Save()
		local file = io.open(self._options_file, "w+")
		if file then
			file:write(json.encode(self._options))
			file:close()
		end
	end

	function ReLUA:Load()
		self:LoadDefaults()
		local file = io.open(self._options_file, "r")
		if file then
			local options = json.decode(file:read("*all"))
			file:close()
			for id, value in pairs(options) do
				self._options[id] = value
			end
		end
		--self:Save()
	end

	function ReLUA:LoadDefaults()
		local file = io.open(self._defaults_file)
		self._options = json.decode(file:read("*all"))
		file:close()
	end

	function ReLUA:GetOption(id)
		return self._options[id]
	end

	function ReLUA:SetOption(id, value)
		if self._options[id] ~= value then
			self._options[id] = value
			self:OptionChanged()
		end
	end

	function ReLUA:OptionChanged()
		self:Save()
	end

	-- ReLUA warnings

	function ReLUA:yesno(clbk)
		local localization = managers.localization
		QuickMenu:new(
			localization:text("dialog_warning_title"),
			localization:text("dialog_are_you_sure_you_want_leave"),
			{
				{text = localization:text("dialog_yes"), callback = clbk},
				{text = localization:text("dialog_no"), is_cancel_button = true}
			},
			true
		)
	end

	-- ReLUA menu (main menu)

	function ReLUA:reset_menu()
		if setup and setup.load_start_menu then
			setup:load_start_menu()
		end
	end

	-- ReLUA menu (lobby)

	function ReLUA:reset_lobby()
		managers.menu:get_menu("menu_main").callback_handler:_dialog_leave_lobby_yes()
		ReLUA:reset_menu()
	end

	-- ReLUA ingame (server)

	function ReLUA:reset_server()
		local all_synced = true
		for _,v in pairs(managers.network:session():peers()) do
			if not v:synched() then
				all_synced = false
			end
		end
		if all_synced then
			-- Restart
			managers.game_play_central:restart_the_game()
		else
			managers.chat:_receive_message(1, "[ReLUA]", "Cannot restart, a player may be loading.", Color.red)
		end
	end

	-- ReLUA ingame (client)

	function ReLUA:set_room_id(room_id)
		-- Get Room ID
		ReLUA._room_id = room_id
	end

	function ReLUA:reset_client()
		if ReLUA._room_id then
			-- Save Room ID
			local file = io.open(ReLUA._room_file, "w")
			if file then
				file:write(ReLUA._room_id)
				file:close()
			end
			-- Disconnect
			managers.menu:get_menu("menu_main").callback_handler:_dialog_end_game_yes()
		else
			managers.chat:_receive_message(1, "[ReLUA]", "Wot?!", Color.red)
		end
	end

	function ReLUA:reconnect()
		-- Reconnect
		local file = io.open(ReLUA._room_file, "r")
		if file then
			local room_id = file:read("*all")
			file:close()
			SystemFS:delete_file(ReLUA._room_file)
			managers.network.matchmake:join_server(room_id)
		end
	end

	Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_ReLUA", function(menu_manager)
		function MenuCallbackHandler:relua_menu_callback(item)
			local optionName = item._parameters.name
			local value = item:value()
			if item._type == "toggle" then
				value = (item:value() == "on")
			end
			ReLUA:SetOption(optionName, value)
		end
	end)

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ReLUA", function(loc)
		local language_filename

		--[[
		-- chinese workarounds
		if BLT.Localization._current == 'cht' or BLT.Localization._current == 'zh-cn' then
			language_filename = 'chinese.json'
		end
		if not language_filename then
			local modname_to_language = {
				['ChnMod (Patch)'] = 'chinese.json',
			}
			for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
				language_filename = mod:IsEnabled() and modname_to_language[mod:GetName()]
				if language_filename then
					break
				end
			end
		end
		]]

		-- try to use system language
		if not language_filename then
			for _, filename in pairs(file.GetFiles(ReLUA._path .. 'Loc/')) do
				local str = filename:match('^(.*).json$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					language_filename = filename
					break
				end
			end
		end
		-- load system language, if exists
		if language_filename then
			loc:load_localization_file(ReLUA._path .. 'Loc/' .. language_filename)
		end

		-- load defaults
		loc:load_localization_file(ReLUA._path .. "Loc/english.json", false)
	end)

	-- load config
	ReLUA:Load()

	-- create menu
	MenuHelper:LoadFromJsonFile(ReLUA._menu_file, ReLUA, ReLUA._options)
end

if RequiredScript then
	local hook_files = ReLUA._hook_files[RequiredScript:lower()]
	if hook_files then
		if type(hook_files) == "string" then
			hook_files = {hook_files}
		end
		for _, file in pairs(hook_files) do
			dofile(ReLUA._lua_path .. file)
		end
	end
end
