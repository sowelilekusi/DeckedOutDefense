class_name PathVFX
extends MeshInstance3D

@export var line_width: float
@export var material: Material


func _ready() -> void:
	var test_points: Array[Vector3] = []
	test_points.append(Vector3(5, 1, 1))
	test_points.append(Vector3(1, 1, 1))
	test_points.append(Vector3(1, 1, 5))
	path(test_points)


func path(path_points: Array[Vector3]) -> void:
	if path_points.size() < 2:
		return
	#Add vertices
	var vertices: PackedVector3Array = PackedVector3Array()
	
	for x: int in path_points.size() - 1:
		if x > 0:
			if path_points.size() > x + 2:
				vertices.append_array(get_quad(path_points[x], path_points[x + 1], path_points[x - 1], path_points[x + 2]))
			else:
				vertices.append_array(get_quad(path_points[x], path_points[x + 1], path_points[x - 1], Vector3.ZERO))
		if x == 0:
			if path_points.size() > 2:
				vertices.append_array(get_quad(path_points[x], path_points[x + 1], Vector3.ZERO, path_points[x + 2]))
			else:
				#print("go1")
				vertices.append_array(get_quad(path_points[x], path_points[x + 1], Vector3.ZERO, Vector3.ZERO))
	
	#Add UVs
	var uvs: PackedVector2Array = PackedVector2Array()
	
	for i: int in path_points.size() - 1:
		uvs.append(Vector2(1, float(i) / (path_points.size() - 1)))
		uvs.append(Vector2(0, float(i + 1) / (path_points.size() - 1)))
		uvs.append(Vector2(1, float(i + 1) / (path_points.size() - 1)))
		
		uvs.append(Vector2(0, float(i + 1) / path_points.size() - 1))
		uvs.append(Vector2(1, float(i) / path_points.size() - 1))
		uvs.append(Vector2(0, float(i) / path_points.size() - 1))
		#print(float(i) / path_points.size() - 1)
	
	#var prev_distance: float = 0
	#var scaler: float = 0.4
	#
	#for i: int in path_points.size() - 1:
		#var distance: float = path_points[i].distance_to(path_points[i + 1])
		#var next_distance: float = prev_distance + distance
		#uvs.append(Vector2(1, prev_distance * scaler))
		#uvs.append(Vector2(0, next_distance * scaler))
		#uvs.append(Vector2(1, next_distance * scaler))
		#
		#uvs.append(Vector2(0, next_distance * scaler))
		#uvs.append(Vector2(1, prev_distance * scaler))
		#uvs.append(Vector2(0, prev_distance * scaler))
		##print(float(i) / path_points.size() - 1)
		#prev_distance = distance
	
	#Initialize the ArrayMesh
	var arr_mesh: ArrayMesh = ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs

	#Create the Mesh
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(arr_mesh.get_surface_count() - 1, material)
	mesh = arr_mesh


func get_edge(pos: Vector3, direction1: Vector2, direction2: Vector2) -> Array[Vector3]:
	var verts: Array[Vector3] = []
	
	var ortho1: Vector2 = Vector2(-direction1.y, direction1.x).normalized()
	var ortho2: Vector2 = Vector2(direction2.y, -direction2.x).normalized()
	
	var top_sample1: Vector3 = pos - (Vector3(ortho1.x, 0.0, ortho1.y) * line_width)
	var top_sample2: Vector3 = pos - (Vector3(ortho2.x, 0.0, ortho2.y) * line_width)
	
	var bottom_sample1: Vector3 = pos + (Vector3(ortho1.x, 0.0, ortho1.y) * line_width)
	var bottom_sample2: Vector3 = pos + (Vector3(ortho2.x, 0.0, ortho2.y) * line_width)
	
	var top: Vector3 = top_sample1 + ((top_sample2 - top_sample1) * 0.5)
	var bottom: Vector3 = bottom_sample1 + ((bottom_sample2 - bottom_sample1) * 0.5)
	
	var top_dir: Vector3 = (pos - top).normalized()
	var bottom_dir: Vector3 = (pos - bottom).normalized()
	
	verts.append(pos + (top_dir * line_width))
	verts.append(pos + (bottom_dir * line_width))
	
	#verts.append(top)
	#verts.append(bottom)
	
	return verts


func get_quad(start_point: Vector3, end_point: Vector3, head_point: Vector3, tail_point: Vector3) -> Array[Vector3]:
	var verts: Array[Vector3] = []
	
	var head_to_start: Vector2
	if head_point != Vector3.ZERO:
		head_to_start = Vector2(start_point.x, start_point.z) - Vector2(head_point.x, head_point.z)
	var start_to_end: Vector2 = Vector2(end_point.x, end_point.z) - Vector2(start_point.x, start_point.z)
	var end_to_tail: Vector2
	if tail_point != Vector3.ZERO:
		end_to_tail = Vector2(tail_point.x, tail_point.z) - Vector2(end_point.x, end_point.z)
	
	var first_edge: Array[Vector3] = []
	if head_point != Vector3.ZERO:
		first_edge.append_array(get_edge(start_point, -head_to_start, start_to_end))
	else:
		first_edge.append_array(get_edge(start_point, Vector2.ZERO, start_to_end))
	
	var second_edge: Array[Vector3] = []
	if tail_point != Vector3.ZERO:
		second_edge.append_array(get_edge(end_point, start_to_end, -end_to_tail))
	else:
		second_edge.append_array(get_edge(end_point, start_to_end, Vector2.ZERO))
	
	
	verts.append(first_edge[1])
	verts.append(second_edge[1])
	verts.append(second_edge[0])
	
	verts.append(second_edge[1])
	verts.append(first_edge[1])
	verts.append(first_edge[0])

	#verts.append(first_edge[0])
	#verts.append(first_edge[1])
	#verts.append(second_edge[0])
	
	#verts.append(first_edge[0])
	#verts.append(second_edge[1])
	#verts.append(first_edge[1])
	
	#verts.append(first_edge[0])
	#verts.append(second_edge[0])
	#verts.append(second_edge[1])
	
	#var top_left: Vector3 = start_point - (orthovec3 * line_width)
	#var bottom_left: Vector3 = start_point + (orthovec3 * line_width)
	#var top_right: Vector3 = end_point - (orthovec3 * line_width)
	#var bottom_right: Vector3 = end_point + (orthovec3 * line_width)
	
	
	#verts.append(top_left)
	#verts.append(bottom_right)
	#verts.append(bottom_left)
	#verts.append(top_left)
	#verts.append(top_right)
	#verts.append(bottom_right)
	
	#print(verts)
	return verts
