
local join_server_original = NetworkMatchMakingSTEAM.join_server

function NetworkMatchMakingSTEAM:join_server(room_id, ...)
	join_server_original(self, room_id, ...)

	ReLUA:set_room_id(room_id)
end
