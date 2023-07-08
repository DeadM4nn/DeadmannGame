extends CharacterBody2D

## States of the Player
enum STATES {
	IDLE, 
	WALKING,
}

## Flow of the states of the player
const FLOW_STATES : Dictionary = {
	STATES.IDLE : [STATES.WALKING],
	STATES.WALKING : [STATES.IDLE],
}

## States of the Player
const ANIMATION_STATES : Dictionary = {
	STATES.IDLE : "IDLE", 
	STATES.WALKING : "WALKING",
}


## Player state
var state : STATES : set = set_state

## The Speed of the Player
const SPEED = 300.0

func process(_delta):
	pass

func _physics_process(_delta):
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	## Moving
	if direction:
		velocity = direction * SPEED

	else:
		## Friction
		velocity.x = move_toward(velocity.x, 0, SPEED)
		## Friction
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Move
	move_and_slide()
	
	## Aim
	$"Gun Pivot".look_at(get_global_mouse_position())
	
	## Change state
	if velocity == Vector2(0,0):
		state = STATES.IDLE
	else:
		state = STATES.WALKING

## Assigns the state. Please specify the state behaviour inside STATE Node
func set_state(new_state : STATES) -> bool:
	
	## If the state is flowable
	if new_state == state or new_state in FLOW_STATES[state]:
		state = new_state
		$States.play(ANIMATION_STATES[new_state])
		return true
	else:
		push_error("Tried to do an illegal state change. %s to %s" % 
			[STATES.find_key(state), STATES.find_key(new_state)])
		return false
