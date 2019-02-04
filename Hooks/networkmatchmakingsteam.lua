
local join_server_original = NetworkMatchMakingSTEAM.join_server

function NetworkMatchMakingSTEAM:join_server(room_id, ...)
	join_server_original(self, room_id, ...)

	-- remember room id for possible upcoming reconnect attempts
	ReLUA:set_room_id(room_id)
end
