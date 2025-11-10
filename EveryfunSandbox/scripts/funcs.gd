extends Node

func merge_dicts(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var result = dict2.duplicate(true)
	for key in dict1.keys():
		if dict1[key] is Dictionary and result.has(key) and result[key] is Dictionary:
			result[key] = merge_dicts(dict1[key], result[key])
		else:
			result[key] = dict1[key]
	return result

func indexExistsInArray(array, index):
	return index >= 0 && index < array.size()

func getNestedValue(table: Dictionary, path: String):
	var keys = path.split(".")
	var current = table
	for key in keys:
		if current.has(key):
			current = current[key]
		else:
			return null
	return current

func setNestedValue(table: Dictionary, path: String, value) -> void:
	var keys = path.split(".")
	var current = table

	for i in range(keys.size()):
		var key = keys[i]
		if i == keys.size() - 1:
			current[key] = value
		else:
			if not current.has(key) or typeof(current[key]) != TYPE_DICTIONARY:
				current[key] = {}
			current = current[key]

func rotateVectorIn_xz(vec: Vector3, angle_degrees: float) -> Vector3:
	var angle = deg_to_rad(angle_degrees)
	var cos_a = cos(angle)
	var sin_a = sin(angle)
	
	var x = vec.x * cos_a - vec.z * sin_a
	var z = vec.x * sin_a + vec.z * cos_a
	
	return Vector3(x, vec.y, z)

# окозалось что Vector3i по умалчанию делает гребаное отбрасывание дробной части
# а не округление вниз
# что создавало ПИЗДЕЦ с отрицательными числами
# тупо полтора часа слитых в унитаз
func vec3_to_vec3i_down(v: Vector3) -> Vector3i:
	return Vector3i(v.floor())

func vec3_to_vec3i(v: Vector3) -> Vector3i:
	return Vector3i(v.round())
	
func vec3_to_vec3i_up(v: Vector3) -> Vector3i:
	return Vector3i(v.ceil())

func getRandomDirection() -> Vector3:
	var u = randf_range(-1.0, 1.0)
	var theta = randf() * TAU
	var r = sqrt(max(0.0, 1.0 - u * u))
	var x = r * cos(theta)
	var y = r * sin(theta)
	var z = u
	return Vector3(x, y, z)

func checksum_dict(data: Dictionary, keys: Array) -> int:
	var text = ""
	for k in keys:
		if data.has(k):
			text += str(k) + ":" + str(data[k]) + ";"
	return hash(text)

func is_number(value) -> bool:
	return value is int or value is float

func round_to(num: float, digits: int) -> float:
	var factor = pow(10.0, digits)
	return round(num * factor) / factor

func arr_to_Vector3(arr):
	return Vector3(arr[0], arr[1], arr[2])

func combine_rotations_deg(rotations: Array) -> Vector3:
	var q_combined = Quaternion()

	for rot_deg in rotations:
		var rot_rad = rot_deg * deg_to_rad(1)
		var q = Quaternion.from_euler(rot_rad)
		q_combined *= q

	return q_combined.get_euler() * rad_to_deg(1)

func appendNull(array, value):
	for i in range(array.size()):
		if array[i] == null:
			array[i] = value
			return
	array.append(value)

func arraySet(array, index, value):
	if index >= array.size():
		array.resize(index + 1)
	array[index] = value
	
func getNullIndex(array):
	for i in range(array.size()):
		var val = array[i]
		if val == null:
			return i
	return array.size()

func deleteAllNullsOnEnd(array):
	while array.size() > 0 and array[array.size() - 1] == null:
		array.pop_back()
		
func deg_to_rad_vec3(vec: Vector3) -> Vector3:
	return Vector3(deg_to_rad(vec.x), deg_to_rad(vec.y), deg_to_rad(vec.z))

# -------------------------------------------------

func get_surface_aabb(mesh: ArrayMesh, surface_index: int) -> AABB:
	if surface_index < 0 or surface_index >= mesh.get_surface_count():
		push_error("Invalid surface index")
		return AABB()

	var arrays = mesh.surface_get_arrays(surface_index)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]

	if vertices.is_empty():
		return AABB()

	var aabb = AABB(vertices[0], Vector3.ZERO)
	for v in vertices:
		aabb = aabb.expand(v)

	return aabb

func make_shape_from_surfaces(mesh: ArrayMesh, surface_indices: Array, convex: bool = true) -> Shape3D:
	var all_vertices = []
	
	for si in surface_indices:
		if si >= mesh.get_surface_count():
			push_warning("Surface index %d out of range" % si)
			continue
		
		var arrays = mesh.surface_get_arrays(si)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var indices = arrays[Mesh.ARRAY_INDEX]
		
		if indices and indices.size() > 0:
			for i in range(0, indices.size(), 3):
				all_vertices.append(vertices[indices[i]])
				all_vertices.append(vertices[indices[i+1]])
				all_vertices.append(vertices[indices[i+2]])
		else:
			all_vertices += vertices
	
	for i in all_vertices.size():
		all_vertices[i] = all_vertices[i] - Vector3(0.5, 0.5, 0.5)
	
	if convex:
		var shape = ConvexPolygonShape3D.new()
		shape.points = all_vertices
		return shape
	else:
		var shape = ConcavePolygonShape3D.new()
		shape.faces = all_vertices
		return shape
		
func get_mesh_from_surface(original_mesh: ArrayMesh, surface_index: int) -> ArrayMesh:
	if surface_index >= original_mesh.get_surface_count():
		push_error("Surface index out of range")
		return null
	
	var arrays = original_mesh.surface_get_arrays(surface_index)
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return new_mesh
	
func rotated_mesh(original_mesh: ArrayMesh, rotation_degrees: Vector3) -> ArrayMesh:
	var new_mesh := ArrayMesh.new()
	
	var transform := Transform3D()
	transform.basis = Basis(Vector3.RIGHT, deg_to_rad(rotation_degrees.x))
	transform.basis = transform.basis.rotated(Vector3.UP, deg_to_rad(rotation_degrees.y))
	transform.basis = transform.basis.rotated(Vector3.FORWARD, deg_to_rad(rotation_degrees.z))
	
	for si in range(original_mesh.get_surface_count()):
		var arrays = original_mesh.surface_get_arrays(si)
		
		var vertices: PackedVector3Array = PackedVector3Array(arrays[Mesh.ARRAY_VERTEX])
		for i in range(vertices.size()):
			vertices[i] = transform * vertices[i]
		
		arrays[Mesh.ARRAY_VERTEX] = vertices
		if arrays[Mesh.ARRAY_INDEX]:
			arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(arrays[Mesh.ARRAY_INDEX])
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return new_mesh
	
func rotated_mesh_centered(original_mesh: ArrayMesh, rotation_degrees: Vector3) -> ArrayMesh:
	var new_mesh := ArrayMesh.new()
	
	var transform := Transform3D()
	transform.basis = Basis(Vector3.RIGHT, deg_to_rad(rotation_degrees.x))
	transform.basis = transform.basis.rotated(Vector3.UP, deg_to_rad(rotation_degrees.y))
	transform.basis = transform.basis.rotated(Vector3.FORWARD, deg_to_rad(rotation_degrees.z))
	
	for si in range(original_mesh.get_surface_count()):
		var arrays = original_mesh.surface_get_arrays(si)
		var vertices: PackedVector3Array = PackedVector3Array(arrays[Mesh.ARRAY_VERTEX])
		
		var aabb := AABB()
		if vertices.size() > 0:
			aabb.position = vertices[0]
			for v in vertices:
				aabb.expand(v)
		
		var center = aabb.position
		for i in range(vertices.size()):
			vertices[i] = (transform * (vertices[i] - center)) + center
		
		arrays[Mesh.ARRAY_VERTEX] = vertices
		if arrays[Mesh.ARRAY_INDEX]:
			arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(arrays[Mesh.ARRAY_INDEX])
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return new_mesh



func make_aabbs_from_surfaces(mesh: ArrayMesh, surfaces: Array, rotation_degrees: Vector3) -> Array:
	var aabbs = []

	for surface in surfaces:
		var _mesh = rotated_mesh_centered(get_mesh_from_surface(mesh, surface), rotation_degrees)
		aabbs.append(_mesh.get_aabb())
	
	return aabbs
