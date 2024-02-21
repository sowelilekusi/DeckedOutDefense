class_name Dummy extends EnemyController


func _on_health_health_depleted() -> void:
	$Dog/Health.max_health = stats.health
	$Dog/Health.current_health = stats.health
	$Dog/SubViewport/ProgressBar.max_value = stats.health
	$Dog/SubViewport/ProgressBar.value = stats.health
