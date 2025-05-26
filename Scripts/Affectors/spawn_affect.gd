class_name SpawnAffect extends Affector

@export var spawn_scene: PackedScene
@export var tower: Tower

var force: float = 150.0
var projectile_id: int = 0


func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	for target: EnemyController in targets:
		var projectile: Projectile = spawn_scene.instantiate() as Projectile
		if projectile is HomingProjectile:
			projectile.target = target
		projectile.position = tower.yaw_model.global_position
		projectile.effect = effect
		projectile.direction = -tower.yaw_model.global_transform.basis.z
		projectile.force = force
		projectile.name = tower.base_name + str(tower.owner_id) + str(projectile_id)
		get_tree().root.add_child(projectile)
		projectile_id += 1
