class_name Enemy
extends Resource

@export var title: String = "dog"
@export var target_type: Data.EnemyType
@export var scene: PackedScene
@export var icon: Texture
@export var death_sprite: Texture
@export var sprite: AtlasTexture
@export var spawn_power: int = 10
@export var health: int = 100
@export var penalty: int = 10
@export var movement_speed: float = 0.5
@export var spawn_cooldown: float = 1.0

@export_group("Spawner Card")
@export_subgroup("Common")
@export var common_group: int = 1
@export var common_cost: int = 1

@export_subgroup("Uncommon")
@export var uncommon_group: int = 1
@export var uncommon_cost: int = 1

@export_subgroup("Rare")
@export var rare_group: int = 1
@export var rare_cost: int = 1

@export_subgroup("Epic")
@export var epic_group: int = 1
@export var epic_cost: int = 1

@export_subgroup("Legendary")
@export var legendary_group: int = 1
@export var legendary_cost: int = 1
