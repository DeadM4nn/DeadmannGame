extends Node


@export var levels : Array[PackedScene] = [] 

@export var location : int = 0

@onready var level = get_node("Level")

func load_level(level_value : int):
	## Destroy old level
	level.queue_free()
	
	var new_curr_level = levels[level_value].instantiate()
	
	add_child(new_curr_level)
	
	level = new_curr_level
	
	new_curr_level.get_node("Player").connect("win_game", win_level )


func _unhandled_input(event):
	if event.is_action_pressed("Reset"):
		reset_level()
	

func reset_level():
	$Node/Reset.play()
	load_level(location)

func win_level():
	location += 1
	$Node/Win.play()
	load_level(location)


func _on_player_win_game():
	pass # Replace with function body.
