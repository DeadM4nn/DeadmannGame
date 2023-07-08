extends Node2D

## Specifies which scene is used as a bullet
const BULLET_FILE : PackedScene = preload("res://Element/Player/Gun/Bullet/default.tscn")

## Keeps track if the texture is flipped
var is_flipped : bool = false

## Bullet Speed
@export var bullet_speed : float = 2000.00

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	## Flips the Gun Vertically if the gun is on the left side
	if abs(global_rotation_degrees) > 90 and not is_flipped:
		$Texture.scale.y *= -1
		is_flipped = true
	elif is_flipped and abs(global_rotation_degrees) <= 90:
		$Texture.scale.y *= -1
		is_flipped = false


# Duck Typed : Shoot. Spawns a bullet. Bullet is instantiated from
# BULLET_FILE
func shoot( pivot_rotation : float = 0.00, curr_bull_speed : float = bullet_speed) -> void:
	var curr_bullet = BULLET_FILE.instantiate()
	
	curr_bullet.position = $Nozzle.global_position
	curr_bullet.global_rotation = global_rotation
	
	get_tree().get_root().call_deferred("add_child", curr_bullet)
	
	curr_bullet.apply_impulse(Vector2(curr_bull_speed, 0).rotated(pivot_rotation))


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		shoot(get_parent().rotation)
