class_name AreaAffector extends Affector

@export var shapecast: ShapeCast3D


func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	for i: int in shapecast.get_collision_count():
		var enemy: EnemyController = shapecast.get_collider(i) as EnemyController
		#print(shapecast.get_collider(i))
		if targets.has(enemy):
			enemy.apply_effect(effect)
			if Data.preferences.display_tower_damage_indicators and effect.damage > 0:
				spawn_damage_indicator(effect.damage, enemy.sprite.global_position)
