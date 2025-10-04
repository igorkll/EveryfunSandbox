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
