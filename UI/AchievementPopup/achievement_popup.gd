class_name AchievementPopup
extends PanelContainer


func set_achievement(text: String, sprite: Texture) -> void:
	$HBoxContainer/Label.text = text
	$HBoxContainer/TextureRect.texture = sprite
