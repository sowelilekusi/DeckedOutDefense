extends ProjectileWeapon
class_name RocketLauncherWeapon

@export var target_icon_scene : PackedScene
@export var targeting_raycast : RayCast3D
@export var targeting_ui_rect : TextureRect
var target_max := 3
var targets = []
var target_icons = []


func _ready() -> void:
	super._ready()
	targeting_raycast.global_position = hero.camera.global_position
	
	target_max = floori(stats.get_attribute("Target Limit"))
	for x in target_max:
		var icon = target_icon_scene.instantiate()
		add_child(icon)
		icon.set_visible(false)
		target_icons.append(icon)


func _process(delta: float) -> void:
	super._process(delta)
	if !trigger_held or time_since_firing < time_between_shots:
		return
	var target_list = targets.duplicate()
	for target in target_list:
		if !is_instance_valid(target):
			targets.erase(target)
			continue
	for x in target_icons.size():
		if x < targets.size():
			target_icons[x].global_position = targets[x].sprite.global_position
			target_icons[x].set_visible(true)
		else:
			target_icons[x].set_visible(false)
	targeting_ui_rect.set_visible(true)
	targeting_ui_rect.texture.region = Rect2(128 * targets.size(), 0, 128, 128)
	if targets.size() < target_max and targeting_raycast.is_colliding() and !targets.has(targeting_raycast.get_collider()):
		targets.append(targeting_raycast.get_collider())


func release_trigger():
	super.release_trigger()
	if targets.size() > 0 and time_since_firing >= time_between_shots:
		time_since_firing -= time_between_shots
		shoot()


func shoot():
	animator.play("shoot")
	for target in targets:
		networked_spawn_rocket.rpc(get_tree().root.get_path_to(target), multiplayer.get_unique_id())
	targets.clear()
	targeting_ui_rect.set_visible(false)
	for icon in target_icons:
		icon.set_visible(false)


@rpc("reliable", "call_local")
func networked_spawn_rocket(target_node_path, peer_id):
	var target = get_tree().root.get_node(target_node_path)
	var projectile = projectile_scene.instantiate() as RocketProjectile
	projectile.position = global_position
	projectile.damage = damage
	projectile.target = target
	projectile.owner_id = peer_id
	projectile.name = str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile.apply_central_impulse(Vector3.UP * 3.0)
	projectile_id += 1


func _physics_process(_delta: float) -> void:
	pass
