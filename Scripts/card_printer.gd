extends StaticBody3D
class_name CardPrinter

@export var cards : Array[CardInHand]
@export var item_card_scene : PackedScene
var card_available = false
@export var button_collider : CollisionShape3D
@export var button_box : Node3D
@export var choice_colliders : Array[CollisionShape3D]


func randomize_cards():
	var weight_total = 0
	for rarity in Data.Rarity:
		weight_total += Data.rarity_weights[rarity]
	
	var generated_rarity = randi_range(0, weight_total)
	var decided_rarity := 0
	
	for rarity in Data.Rarity:
		weight_total -= Data.rarity_weights[rarity]
		if generated_rarity >= weight_total:
			decided_rarity = Data.Rarity[rarity]
			break
			
	var card_array = []
	for x in Data.cards:
		if x.rarity == decided_rarity:
			card_array.append(x)
	var card
	for x in cards:
		if card_array.size() > 0:
			card = card_array.pick_random()
			card_array.erase(card)
		x.set_card(card)
	$Node3D.set_visible(true)
	for x in choice_colliders:
		x.disabled = false
	card_available = true


func retrieve_card(i):
	$Node3D.set_visible(false)
	for x in choice_colliders:
		x.disabled = true
	if card_available:
		var card = cards[i].stats
		var item = item_card_scene.instantiate() as ItemCard
		item.card = card
		add_child(item)
		item.position += -transform.basis.z * 2
	button_collider.disabled = false
	button_box.position = Vector3(0,0,0)


func _on_static_body_3d_button_interacted(_value) -> void:
	button_collider.disabled = true
	button_box.position = Vector3(0,0,-0.2)
	randomize_cards()
