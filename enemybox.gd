class_name EnemyBox extends HBoxContainer


func set_wave(wave: int) -> void:
	$WaveLabel.text = "Wave " + str(wave) + ": "


func add_enemy_tag(enemy: Enemy, num: int) -> void:
	var name_label: Label = Label.new()
	name_label.text = enemy.title
	var num_label: Label = Label.new()
	num_label.text = str(num)
	add_child(name_label)
	add_child(num_label)
