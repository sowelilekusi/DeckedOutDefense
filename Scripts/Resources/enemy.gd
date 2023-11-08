extends Resource
class_name Enemy

@export var title = "dog"
@export var target_type : Data.EnemyType
@export var icon : Texture
@export var sprite : AtlasTexture
@export var spawn_power := 10
@export var health = 100
@export var penalty = 10
@export var movement_speed = 0.5
@export var spawn_cooldown = 1.0
