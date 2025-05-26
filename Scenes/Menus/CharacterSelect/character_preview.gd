class_name CharacterPreview extends PanelContainer

@export var tower_label_scene: PackedScene
@export var tower_label_container: VBoxContainer
@export var hero_name_label: Label

var added_tags: Array[TowerLabel] = []
var regular_label: Label = null


func set_preview(hero: HeroClass) -> void:
	hero_name_label.text = hero.hero_name
	if regular_label:
		regular_label.queue_free()
		regular_label = null
	for tag: TowerLabel in added_tags:
		tag.queue_free()
	added_tags = []
	var added_labels: Array[Card] = []
	for card: Card in hero.deck:
		if !added_labels.has(card):
			var new_label: TowerLabel = tower_label_scene.instantiate() as TowerLabel
			new_label.change_label(card.display_name, str(hero.deck.count(card)))
			added_labels.append(card)
			tower_label_container.add_child(new_label)
			added_tags.append(new_label)


func setup_with_basic_text(hero: HeroClass, text: String) -> void:
	hero_name_label.text = hero.hero_name
	if regular_label:
		regular_label.queue_free()
		regular_label = null
	for tag: TowerLabel in added_tags:
		tag.queue_free()
	added_tags = []
	var added_labels: Array[Card] = []
	var new_label: Label = Label.new()
	new_label.text = text
	tower_label_container.add_child(new_label)
	regular_label = new_label
