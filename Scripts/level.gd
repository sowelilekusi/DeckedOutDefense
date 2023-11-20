extends GridMap
class_name Level

@export var enemy_pool : Array[Enemy]
@export var player_spawns : Array[Node3D] = []
@export var enemy_spawns : Array[Node3D] = []
@export var enemy_goals : Array[Node3D] = []
@export var a_star_graph_3d : AStarGraph3D
@export var cinematic_cam : CinematicCamManager
@export var printer : CardPrinter
@export var shop : ShopStand
