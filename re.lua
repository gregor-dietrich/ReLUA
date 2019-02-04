
if game_state_machine and Network and ReLUA then
	local state = game_state_machine:current_state_name()
	if state == "menu_main" then
		-- menu
		if not Network:multiplayer() then
			-- RESTART: main menu
			ReLUA:reset_menu()
		else
			-- RESTART: lobby
			if ReLUA:GetOption("relua_show_warn") then
				ReLUA:yesno(ReLUA.reset_lobby)
			else
				ReLUA:reset_lobby()
			end
		end
	elseif state == "ingame_lobby_menu" or
			state == "ingame_waiting_for_respawn" or
			state == "ingame_waiting_for_players" or
			state == "ingame_mask_off" or
			state == "ingame_standard" then
		-- in game
		if Network:is_server() then
			-- RESTART: as host
			if ReLUA:GetOption("relua_show_warn") then
				ReLUA:yesno(ReLUA.reset_server)
			else
				ReLUA:reset_server()
			end
		else
			-- RESTART: as client (reconnect)
			if ReLUA:GetOption("relua_show_warn") then
				ReLUA:yesno(ReLUA.reset_client)
			else
				ReLUA:reset_client()
			end
		end
	elseif state == "disconnected" then
		-- do nothing
	end
end
