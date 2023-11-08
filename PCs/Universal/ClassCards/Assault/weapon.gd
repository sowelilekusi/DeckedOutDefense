extends Sprite3D
class_name Weapon

@export var stats : WeaponStats
@export var hero : Hero

var cooldown := 0.0
var other_cooldown := 0.0
var trigger_held := false
var second_trigger_held := false


func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate
	$RayCast3D.target_position = Vector3(0, 0, -stats.fire_range)


func set_raycast_origin(node):
	$RayCast3D.global_position = node.global_position


func set_hero(value):
	hero = value


func _process(delta: float) -> void:
	if stats != null:
		other_cooldown -= delta


func _physics_process(_delta: float) -> void:
	if trigger_held:
		shoot()


func hold_trigger():
	trigger_held = true


func release_trigger():
	trigger_held = false


func hold_second_trigger():
	second_trigger_held = true


func release_second_trigger():
	second_trigger_held = false


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		if $RayCast3D.is_colliding():
			var target = $RayCast3D.get_collider()
			if target != null:
				var target_hitbox = target.shape_owner_get_owner($RayCast3D.get_collider_shape())
				if target_hitbox is Hitbox:
					target_hitbox.damage(stats.damage)

@rpc
func networked_shoot():
	$AnimationPlayer.play("shoot")
	
