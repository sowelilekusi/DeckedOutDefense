extends Resource
class_name Card

enum Faction {GENERIC}

@export var title : String
@export var rarity : Data.Rarity
@export var faction : Faction 
@export var sprite : AtlasTexture
@export var turret : PackedScene
@export var weapon : PackedScene
@export var weapon_stats : WeaponStats
@export var tower_stats : TowerStats
