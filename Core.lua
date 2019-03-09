
if not ReLUA then
	ReLUA = {}
	ReLUA._lua_path = ModPath .. "Hooks/"
	ReLUA._room_file = SavePath .. "ReLUALastRoomID.txt"
	ReLUA._room_id = nil

	ReLUA._hook_files = {
		["lib/setups/setup"]								= "setup.lua",
		["lib/network/matchmaking/networkmatchmakingsteam"]	= "networkmatchmakingsteam.lua"
	}

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

	function ReLUA:reset_menu()
		if setup and setup.quit_to_main_menu then
			setup.exit_to_main_menu = true
			setup:quit_to_main_menu()
		end
	end

	function ReLUA:reset_server()
		local all_synced = true
		for _,v in pairs(managers.network:session():peers()) do
			if not v:synched() then
				all_synced = false
			end
		end
		if all_synced then
			-- Restart
			if not game_state_machine then
				do return end
			end
			local state = game_state_machine:current_state_name()
			if state == "ingame_waiting_for_players" or
					state == "ingame_lobby_menu" or
					state == "empty" then
				do return end
			end
			local job = managers.raid_job
			if not job or job:is_in_tutorial() or (not job:is_camp_loaded() and job:current_job() and job:current_job().consumable) then
				do return end
			end
			if job:is_camp_loaded() then
				log("reload camp")
				if Global.game_settings.single_player then
					RaidMenuCallbackHandler:raid_play_offline()
				elseif Network:is_server() then
					RaidMenuCallbackHandler:raid_play_online()
				end
			else
				log("restart mission")
				if Global.game_settings.single_player then
					managers.game_play_central:restart_the_mission()
				elseif Network:is_server() then
					managers.vote:restart_mission_auto()
				end
			end
			managers.raid_menu:on_escape()
		else
			managers.chat:_receive_message(1, "[ReLUA]", "Cannot restart, a player may be loading.", Color.red)
		end
	end

	function ReLUA:set_room_id(room_id)
		-- FIXME
		ReLUA._room_id = room_id
	end

	function ReLUA:reset_client()
		-- FIXME
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
		-- FIXME
		-- Reconnect
		local file = io.open(ReLUA._room_file, "r")
		if file then
			local room_id = file:read("*all")
			file:close()
			SystemFS:delete_file(ReLUA._room_file)
			managers.network.matchmake:join_server(room_id)
		end
	end

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
