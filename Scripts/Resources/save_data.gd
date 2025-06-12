class_name SaveData extends RefCounted

var save_slot: int = 0

#Game History
var twenty_game_history: Array[bool] = []
var wins: int = 0
var losses: int = 0
var winrate: int :
	get():
		return int((float(twenty_game_history.count(true)) / float(twenty_game_history.size())) * 100.0)
	set(_value):
		return

#Engineer
var engineer_cards_bought: int = 0


#Unlocking the mage
var mage_card_seen_in_shop: bool = false
var mage_cards_bought: int = 0
var mage_unlocked: bool = 0


func add_game_outcome(outcome: bool) -> void:
	if outcome:
		wins += 1
	else:
		losses += 1
	twenty_game_history.push_back(outcome)
	if twenty_game_history.size() > 20:
		twenty_game_history.pop_front()


func unlock_all_content() -> void:
	mage_unlocked = true


func lock_all_content() -> void:
	mage_unlocked = false


func bought_engineer_card() -> void:
	engineer_cards_bought += 1


func saw_mage_card_in_shop() -> void:
	mage_card_seen_in_shop = true
	save_to_disc()


func bought_mage_card() -> void:
	mage_cards_bought += 1
	if mage_cards_bought >= 10:
		mage_unlocked = true
		save_to_disc()


func save_to_disc() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if !dir.dir_exists("saves"):
		dir.make_dir("saves")
	dir.change_dir("saves")
	var save_file: FileAccess = FileAccess.open("user://saves/slot" + str(save_slot), FileAccess.WRITE)
	var dict: Dictionary = {
		"wins" = wins,
		"losses" = losses,
		"twenty_game_history" = twenty_game_history,
		"engineer_cards_bought" = engineer_cards_bought,
		"mage_card_seen_in_shop" = mage_card_seen_in_shop,
		"mage_cards_bought" = mage_cards_bought,
		"mage_unlocked" = mage_unlocked,
	}
	var json_string: String = JSON.stringify(dict)
	save_file.store_line(json_string)


static func load_from_disk(slot: int) -> SaveData:
	if FileAccess.file_exists("user://saves/slot" + str(slot)):
		var save_file: FileAccess = FileAccess.open("user://saves/slot" + str(slot), FileAccess.READ)
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result == OK:
			var dict: Dictionary = json.data
			var stats: SaveData = SaveData.new()
			stats.save_slot = slot
			stats.wins = dict["wins"]
			stats.losses = dict["losses"]
			stats.twenty_game_history.append_array(dict["twenty_game_history"])
			stats.engineer_cards_bought = dict["engineer_cards_bought"]
			stats.mage_card_seen_in_shop = dict["mage_card_seen_in_shop"]
			stats.mage_cards_bought = dict["mage_cards_bought"]
			stats.mage_unlocked = dict["mage_unlocked"]
			return stats
	return SaveData.new()
