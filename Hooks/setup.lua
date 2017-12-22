
local init_managers_original = Setup.init_managers

function Setup:init_managers(...)
	init_managers_original(self, ...)

	ReLUA:reconnect()
end
