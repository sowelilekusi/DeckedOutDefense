class_name EnemyBox extends HBoxContainer


func set_wave(wave: int) -> void:
	$WaveLabel.text = "Wave " + str(wave) + ": "


func add_enemy_tag(enemy: Enemy, num: int) -> void:
	for x: int in num:
		var enemy_tex: TextureRect = TextureRect.new()
		enemy_tex.texture = enemy.sprite
		enemy_tex.custom_minimum_size = Vector2(80, 80)
		add_child(enemy_tex)
	#var name_label: Label = Label.new()
	#name_label.text = enemy.title
	#var num_label: Label = Label.new()
	#num_label.text = str(num)
	#add_child(name_label)
	#add_child(num_label)
