
-- get instance in case of getting called statically
local function get_instance(instance)
	return instance or managers.menu:get_menu("menu_main").callback_handler
end

function MenuCallbackHandler:_relua_lobby()
	local self = get_instance(self) -- safety first
	self:_dialog_leave_lobby_yes()
	self:_relua_start_menu()
end

function MenuCallbackHandler:_relua_start_menu()
	--uncomment if 'self' needed
	--local self = get_instance(self) -- safety first
	if setup and setup.load_start_menu then
		setup:load_start_menu()
	end
end
