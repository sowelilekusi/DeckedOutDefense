class_name Enemy
extends Resource

@export var title: String = "enemy name goes here"
@export var description: String = "enemy description goes here"
@export var target_type: Data.EnemyType
@export var icon: Texture
@export var scene: PackedScene
@export var death_sprite: Texture
@export var sprite: AtlasTexture
@export var spawn_power: int = 10
@export var group_size: int = 5
@export var health: int = 100
@export var penalty: int = 10
@export var movement_speed: float = 0.5
@export var spawn_cooldown: float = 1.0
