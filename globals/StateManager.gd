extends Node

var state :StateType = StateType.paused

enum StateType {
	playing,
	paused
}

func pause_game():
	state = StateType.paused
	get_tree().paused = true

func un_pause_game(): 
	state = StateType.playing
	get_tree().paused = false
