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
