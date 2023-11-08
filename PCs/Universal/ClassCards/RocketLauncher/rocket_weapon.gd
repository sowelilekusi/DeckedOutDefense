extends Weapon
class_name RocketWeapon

@export var rocket_scene : PackedScene
@export var target_icon_scene : PackedScene
var rocket_speed = 20.0
var target_max := 3
var targets = []
var target_icons = []


func _ready() -> void:
	super._ready()
	for x in target_max:
		var icon = target_icon_scene.instantiate()
		add_child(icon)
		icon.set_visible(false)
		target_icons.append(icon)


func _process(delta: float) -> void:
	super._process(delta)
	if !trigger_held or other_cooldown > 0:
		return
	var target_list = targets.duplicate()
	for target in target_list:
		if !is_instance_valid(target):
			targets.erase(target)
			continue
	for x in target_icons.size():
		if x < targets.size():
			target_icons[x].global_position = targets[x].global_position
			target_icons[x].set_visible(true)
		else:
			target_icons[x].set_visible(false)
	$TextureRect.set_visible(true)
	$TextureRect.texture.region = Rect2(128 * targets.size(), 0, 128, 128)
	if targets.size() < target_max and $RayCast3D.is_colliding() and !targets.has($RayCast3D.get_collider()):
		targets.append($RayCast3D.get_collider())


func _physics_process(_delta: float) -> void:
	pass


func release_trigger():
	if trigger_held:
		super.release_trigger()
		shoot()


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		for target in targets:
			var rocket = rocket_scene.instantiate() as Rocket
			rocket.position = $RayCast3D.global_position
			rocket.damage = stats.damage
			rocket.target = target
			get_tree().root.add_child(rocket)
			rocket.apply_central_impulse(Vector3.UP * 3.0)
		targets.clear()
		$TextureRect.set_visible(false)
		for icon in target_icons:
			icon.set_visible(false)
