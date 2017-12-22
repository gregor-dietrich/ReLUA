
if game_state_machine and Network and ReLUA then
	local state = game_state_machine:current_state_name()
	if state == "menu_main" then
		-- menu
		if not Network:multiplayer() then
			-- main menu
			ReLUA:reset_menu()
		else
			-- lobby
			ReLUA:yesno(ReLUA.reset_lobby)
		end
	elseif state == "ingame_lobby_menu" or
			state == "ingame_waiting_for_respawn" or
			state == "ingame_waiting_for_players" or
			state == "ingame_mask_off" or
			state == "ingame_standard" then
		-- in game
		if Network:is_server() then
			-- as host
			ReLUA:yesno(ReLUA.reset_server)
		else
			-- as client
			ReLUA:yesno(ReLUA.reset_client)
		end
	elseif state == "disconnected" then
		-- do nothing
	end
end
