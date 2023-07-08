class_name Player extends CharacterBody2D

signal win_game

@export_category("Camera Zoom")
@export var ZOOM_MAX : float = 1.4
@export var ZOOM_MIN : float = 0.3
@export var ZOOM_RATE : float = 0.1

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


## Keeps track if the body is flipped
var is_flipped : bool = false

## States of the Player
const ANIMATION_STATES : Dictionary = {
	STATES.IDLE : "IDLE", 
	STATES.WALKING : "WALKING",
}


## Holds the texture of a Holdable
var hold_slot : Texture2D = null : set = set_hold


## Gun Node
@onready var gun : Node2D = get_node("Gun Pivot/GunAndHand/Gun")

## Gun Node
@onready var camera : Node2D = get_node("Sprite/Camera2D")

## Player state
var state : STATES : set = set_state

## The Speed of the Player
const SPEED = 700.0


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
#		## Friction
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		## Friction
#		velocity.y = move_toward(velocity.y, 0, SPEED)
		## Friction
		velocity.x = 0
		## Friction
		velocity.y = 0
	
	# Move
	var is_moving = move_and_slide()
	
	## Aim
	$"Gun Pivot".look_at(get_global_mouse_position())
	
	## Change state
	if velocity == Vector2(0,0):
		state = STATES.IDLE
	else:
		state = STATES.WALKING
	
	
	## Flips based on mouse Movement
	if get_global_mouse_position() < global_position and not is_flipped :
		$"Gun Pivot/GunAndHand".scale.y *= -1
		$Flip.play("RIGHT")
#		$Sprite.scale.x *= -1
		is_flipped = true
	elif get_global_mouse_position() >= global_position and is_flipped:
		$"Gun Pivot/GunAndHand".scale.y *= -1
		$Flip.play("LEFT")
#		$Sprite.scale.x *= -1
		is_flipped = false
		

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


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		gun.shoot($"Gun Pivot".rotation)
		
	if event.is_action_pressed("Canon") and hold_slot != null :
		gun.shoot_swappable(hold_slot, $"Gun Pivot".rotation)
		hold_slot = null
	
	var zoom_amount : Vector2 =  camera.get_zoom()
	
	# Zooms the Camera
	if event.is_action_pressed("zoom_in"):
		zoom_amount += Vector2(ZOOM_RATE, ZOOM_RATE)

	elif event.is_action_pressed("zoom_out"):
		zoom_amount -= Vector2(ZOOM_RATE, ZOOM_RATE)
	
	zoom_amount = zoom_amount.clamp(Vector2(ZOOM_MIN, ZOOM_MIN), Vector2(ZOOM_MAX, ZOOM_MAX))
	camera.set_zoom(zoom_amount)
	
	if event.is_action_pressed("test_button"):
		destroy_self()



func destroy_self():
	## Load explood
	var explosion = preload("res://Element/Explosion/Explosion.tscn").instantiate()
	
	## Put Explosion
	explosion.global_position = global_position
	
	## Exist Explosion
	get_tree().root.add_child(explosion)
	
	queue_free()


## Destroy Self if Body is dangerous
func _check_death(body):
	if body.is_inside_tree():
		var parent_body = body.get_parent()

		if parent_body is Swappable:
			var swap_Behave : Dictionary = parent_body.behaviour_value
			if swap_Behave[Swappable.BEHAVIOURS.IS_DANGEROUS]:
				destroy_self()
			elif swap_Behave[Swappable.BEHAVIOURS.IS_TROPHY]:
				win_game.emit()
			elif swap_Behave[Swappable.BEHAVIOURS.IS_PICKUP]:
				$Audio/Pickup.play()
				set_hold(parent_body.pickup_swappable())
				


## Bot is picking up
func set_hold(value):
	if value != null and is_inside_tree():
		$Sprite/UpperBody/Item.texture = value
		$Sprite/UpperBody/Item.visible = true
	elif value == null and is_inside_tree():
		$Sprite/UpperBody/Item.visible = false
	hold_slot = value
