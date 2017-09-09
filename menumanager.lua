function MenuCallbackHandler:_dialog_leave_lobby_yes_RELUA()
	self:_dialog_leave_lobby_yes()
	self:_RELUA()
end

function MenuCallbackHandler:_RELUA()
	if setup.load_start_menu then
		setup:load_start_menu()
	end
end