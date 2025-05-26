extends PanelContainer

func _ready() -> void:
	if Data.save_data.wins > 0:
		$VBoxContainer/GridContainer/FirstWin.icon.region = Rect2(36, 0, 36, 36)
	if Data.save_data.mage_card_seen_in_shop:
		$VBoxContainer/GridContainer/SeenMageCard.icon.region = Rect2(36, 0, 36, 36)
	if Data.save_data.mage_unlocked:
		$VBoxContainer/GridContainer/UnlockedMage.icon.region = Rect2(36, 0, 36, 36)
