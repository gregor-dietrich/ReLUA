
-- this is a temporary fix, which can be removed as soon as the corresponding pull request is merged into the blt.
local input_focus =	(managers.menu_component and managers.menu_component:input_focut_game_chat_gui()) -- 'focut' is not a typo on our side.

if not input_focus and game_state_machine then
	local state = game_state_machine:current_state_name()
	if state == "menu_main" then
		if Network:multiplayer() then
			local title = managers.localization:text("dialog_warning_title")
			local text = managers.localization:text("dialog_are_you_sure_you_want_leave")
			local options = {
				{
					text = managers.localization:text("dialog_yes"),
					callback = MenuCallbackHandler._relua_lobby
				},
				{
					text = managers.localization:text("dialog_no"),
					is_cancel_button = true
				}
			}
			QuickMenu:new(title, text, options, true)
		else
			MenuCallbackHandler:_relua_start_menu()
		end
	elseif state == "ingame_waiting_for_players" or state == "ingame_mask_off" or state == "ingame_standard" then
		if Network:is_server() then
			local all_synced = true
			for _,v in pairs(managers.network:session():peers()) do
				if not v:synched() then
					all_synced = false
				end
			end
			if all_synced then
				managers.game_play_central:restart_the_game()
			else
				managers.chat:_receive_message(1, "[ReLUA]", "Cannot restart, a player may be loading.", Color.red)
			end
		--else
			-- TODO: client reconnect
		end
	end
end