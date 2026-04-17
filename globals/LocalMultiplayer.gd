extends Node

enum LocalID {
	PLAYER_ONE = 1,
	PLAYER_TWO = 2,
	PLAYER_THREE = 3,
	PLAYER_FOUR = 4,
}


func is_id_local(peer_id: int) -> bool:
	return LocalID.values().has(peer_id)

func get_next_local_id() -> int:
	return Lobby.get_lobby_size() + 1
