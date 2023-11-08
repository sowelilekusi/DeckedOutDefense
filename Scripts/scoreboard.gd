extends PanelContainer
class_name Scoreboard

signal all_players_ready

var entry_scene = preload("res://Scenes/UI/scoreboard_entry.tscn")
var entries = {}

func _ready() -> void:
	$VBoxContainer/DummyEntry1.queue_free()
	$VBoxContainer/DummyEntry2.queue_free()
	$VBoxContainer/DummyEntry3.queue_free()


func get_player_entry(peer_id) -> ScoreboardEntry:
	return entries[peer_id]


func set_player_ready_state(peer_id: int, state: bool):
	entries[peer_id].set_ready_state(state)
	for id in entries:
		if !entries[id].get_ready_state():
			return
	all_players_ready.emit()
	unready_all_players()


func unready_all_players():
	for peer_id in entries:
		entries[peer_id].set_ready_state(false)


func add_player(peer_id: int, player_profile: PlayerProfile):
	var entry = entry_scene.instantiate() as ScoreboardEntry
	entry.name = str(peer_id)
	entry.set_display_name("", player_profile.get_display_name())
	entry.set_character(0, player_profile.get_preferred_class())
	player_profile.display_name_changed.connect(entry.set_display_name)
	player_profile.preferred_class_changed.connect(entry.set_character)
	entries[peer_id] = entry
	$VBoxContainer.add_child(entry)


func remove_player(peer_id: int):
	entries[peer_id].queue_free()
	entries.erase(peer_id)
