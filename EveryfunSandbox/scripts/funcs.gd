extends Node

func merge_dicts(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var result = dict2.duplicate(true)
	for key in dict1.keys():
		if dict1[key] is Dictionary and result.has(key) and result[key] is Dictionary:
			result[key] = merge_dicts(dict1[key], result[key])
		else:
			result[key] = dict1[key]
	return result
