extends Item
class_name Card

enum Faction {GENERIC = 0}

@export var rarity : Data.Rarity
@export var faction : Faction
@export var turret_scene : PackedScene
@export var weapon_scene : PackedScene
@export var weapon_stats : CardText
@export var tower_stats : CardText
