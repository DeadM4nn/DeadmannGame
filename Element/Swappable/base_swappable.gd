class_name Swappable extends RigidBody2D

## Emits when it touches a player and it is dangerous
signal danger_touched_player


@export_category("Starting Flags")
## Specifies the initial value for is_flying
@export var flying : bool = false
@export var chasing : bool = false
@export var dangerous : bool = false
@export var voletile : bool = false
@export var wall : bool = false
@export var pickup : bool = false
@export var trophy : bool = false


@export_category("Swappable Base Property")
## Specifies how strong the Swappable will jump towards the player
@export var jump_force : float = 0


var is_flipped = false

## The pointer that points to the player
var player : Player = null

## The Sprite
@onready var sprite : Sprite2D = get_node("Sprite/Sprite")

enum BEHAVIOURS {
	IS_FLYING, # Uncollidable to Walls 
	IS_CHASING, # Makes Incremental Movement Towars The Player
	IS_DANGEROUS,
	IS_VOLETILE,
	IS_WALL,
	IS_PICKUP,
	IS_TROPHY,
}

var behaviour_value : Dictionary = {
	BEHAVIOURS.IS_FLYING : false,
	BEHAVIOURS.IS_CHASING : false, # Makes Incremental Movement Towars The Player
	BEHAVIOURS.IS_DANGEROUS : false, 
	BEHAVIOURS.IS_VOLETILE : false,
	BEHAVIOURS.IS_WALL : false,
	BEHAVIOURS.IS_PICKUP : false,
	BEHAVIOURS.IS_TROPHY : false,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	behaviour_value[BEHAVIOURS.IS_FLYING] = flying
	behaviour_value[BEHAVIOURS.IS_CHASING] = chasing
	behaviour_value[BEHAVIOURS.IS_DANGEROUS] = dangerous
	behaviour_value[BEHAVIOURS.IS_VOLETILE] = voletile
	behaviour_value[BEHAVIOURS.IS_WALL] = wall
	behaviour_value[BEHAVIOURS.IS_PICKUP] = pickup
	behaviour_value[BEHAVIOURS.IS_TROPHY] = trophy
	
	
	set_behaviour()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var old_sprite_flip_h = sprite.flip_h
	
	## Constantly point to player if player is in the range
	if player != null and behaviour_value[BEHAVIOURS.IS_CHASING]:
		$Point_to_player.look_at(player.global_position)
		if player.global_position < global_position:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		
		## Flip the skipp
		if not sprite.flip_h and $Sprite/Sprite/Skull.scale.x < 0:
			$Sprite/Sprite/Skull.scale.x *= -1
		elif sprite.flip_h and $Sprite/Sprite/Skull.scale.x >= 0 : 
			$Sprite/Sprite/Skull.scale.x *= -1

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
		
	# If the Swappable is dangerous
	if behaviour_value[BEHAVIOURS.IS_DANGEROUS]:
		$Sprite/Sprite/Skull.visible = true
	else:
		$Sprite/Sprite/Skull.visible = false
	
	# If the Swappable is voletile
	if behaviour_value[BEHAVIOURS.IS_VOLETILE]:
		sprite.use_parent_material = false
	else:
		sprite.use_parent_material = true
	
	# If the Swappable is wall
	if behaviour_value[BEHAVIOURS.IS_WALL]:
		freeze = true
		$Wall/Shape.call_deferred("set_disabled", false)
	else:
		freeze = false
		$Wall/Shape.call_deferred("set_disabled", true)
	
	# If the Swapppable is 
	if behaviour_value[BEHAVIOURS.IS_TROPHY]:
		$Crown.visible = true
	else:
		$Crown.visible = false


func jump():
	if behaviour_value[BEHAVIOURS.IS_CHASING] and player != null:
		apply_impulse(Vector2(jump_force,0).rotated($Point_to_player.global_rotation))


## Looks at the player
func _check_body_entered_for_player(body):
	if body is Player:
		player = body
		
		if behaviour_value[BEHAVIOURS.IS_CHASING]:
			$Audio/Up.play()
			$ChatAnimation.play("Open")


## Forgets the player
func _forget_player(body):
	if body == player:
		player = null
		sleeping = true
		
		if behaviour_value[BEHAVIOURS.IS_CHASING]:
			$Audio/Down.play()
			$ChatAnimation.play_backwards("Open")


## If Player Touches Item
func _on_touch(body):
	if behaviour_value[BEHAVIOURS.IS_VOLETILE]:
		destroy_self()


func destroy_self():
	## Load explood
	var explosion = preload("res://Element/Explosion/Explosion.tscn").instantiate()
	
	## Put Explosion
	explosion.global_position = global_position
	
	## Exist Explosion
	get_tree().root.add_child(explosion)
	
	queue_free()

## Returns the swappable sprite
func pickup_swappable() -> Texture2D:
	queue_free()
	return get_node("Sprite/Sprite").texture
