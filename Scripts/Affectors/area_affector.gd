class_name AreaAffector
extends Affector

@export var shapecast: ShapeCast3D


func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	if shapecast:
		for i: int in shapecast.get_collision_count():
			var enemy: EnemyController = shapecast.get_collider(i) as EnemyController
			#print(shapecast.get_collider(i))
			if targets.has(enemy):
				enemy.apply_effect(effect)
	else:
		for enemy: EnemyController in targets:
			enemy.apply_effect(effect)
