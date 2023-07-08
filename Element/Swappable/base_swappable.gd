class_name Swappable extends RigidBody2D

## Emits when it touches a player and it is dangerous
signal danger_touched_player


@export_category("Starting Flags")
## Specifies the initial value for is_flying
@export var flying : bool = false
@export var chasing : bool = false
@export var dangerous : bool = false


@export_category("Swappable Base Property")
## Specifies how strong the Swappable will jump towards the player
@export var jump_force : float = 0


## The pointer that points to the player
var player : Player = null

## The Sprite
@onready var sprite : Sprite2D = get_node("Sprite/Sprite")

enum BEHAVIOURS {
	IS_FLYING, # Uncollidable to Walls 
	IS_CHASING, # Makes Incremental Movement Towars The Player
	IS_DANGEROUS,
}

var behaviour_value : Dictionary = {
	BEHAVIOURS.IS_FLYING : false,
	BEHAVIOURS.IS_CHASING : false, # Makes Incremental Movement Towars The Player
	BEHAVIOURS.IS_DANGEROUS : false, 
}

# Called when the node enters the scene tree for the first time.
func _ready():
	behaviour_value[BEHAVIOURS.IS_FLYING] = flying
	behaviour_value[BEHAVIOURS.IS_CHASING] = chasing
	behaviour_value[BEHAVIOURS.IS_DANGEROUS] = dangerous
	
	set_behaviour()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	## Constantly point to player if player is in the range
	if player != null and behaviour_value[BEHAVIOURS.IS_CHASING]:
		$Point_to_player.look_at(player.global_position)
		if player.global_position < global_position:
			sprite.flip_h = false
		else:
			sprite.flip_h = true


# Apply the changes made to the is_flags
func set_behaviour():
	
	# If the Swappable is flying
	if behaviour_value[BEHAVIOURS.IS_FLYING]:
		$Wings.play("Flap_Wings")
		# Make it uncollidable with walls
		set_collision_mask_value(2, false)
	else:
		$Wings.play("RESET")
		# Make it collidable with walls
		set_collision_mask_value(2, true)


func jump():
	if behaviour_value[BEHAVIOURS.IS_CHASING] and player != null:
		apply_impulse(Vector2(jump_force,0).rotated($Point_to_player.global_rotation))


## Looks at the player
func _check_body_entered_for_player(body):
	if body is Player:
		player = body
		$Audio/Up.play()
		$ChatAnimation.play("Open")


## Forgets the player
func _forget_player(body):
	if body == player:
		player = null
		sleeping = true
		$Audio/Down.play()
		$ChatAnimation.play_backwards("Open")


## If Player Touches Item
func _on_touch(body):
	
	## If touched player
	if behaviour_value[BEHAVIOURS.IS_DANGEROUS] and body is Player:
		danger_touched_player.emit()
		print("Kill Player")
