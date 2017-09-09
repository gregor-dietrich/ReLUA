-- The code is the documentation and many quotes on the internet are attributed incorrectly. (Mahatma "The Condor" Gandhi)
if game_state_machine then
	if game_state_machine:current_state_name() == "menu_main" then
		if Network:multiplayer() then
			local callback_handler = managers.menu:get_menu("menu_main").callback_handler
			local dialog_data = {
				title = managers.localization:text("dialog_warning_title"),
				text = managers.localization:text("dialog_are_you_sure_you_want_leave"),
				id = "leave_lobby_RELUA"
			}
			local yes_button = {
				text = managers.localization:text("dialog_yes"),
				callback_func = callback(callback_handler, callback_handler, "_dialog_leave_lobby_yes_RELUA")
			}
			local no_button = {
				text = managers.localization:text("dialog_no"),
				callback_func = callback(callback_handler, callback_handler, "_dialog_leave_lobby_no"),
				cancel_button = true
			}
			dialog_data.button_list = {
				yes_button,
				no_button
			}
			managers.system_menu:show(dialog_data)
		else
			MenuCallbackHandler:_RELUA()
		end
	elseif game_state_machine:current_state_name() == "ingame_waiting_for_players" or game_state_machine:current_state_name() == "ingame_mask_off" or game_state_machine:current_state_name() == "ingame_standard" then
		if Network:is_server() and not managers.job:is_current_job_professional() and not in_chat then
			local all_synced = true
			for k,v in pairs(managers.network:session():peers()) do
				if not v:synched() then
					all_synced = false
				end
			end
			if all_synced == true then
				managers.game_play_central:restart_the_game()
			else
				managers.chat:_receive_message(1, "[ReLUA]", "Cannot restart, a player may be loading.", Color.red)
			end
		end
	end
end