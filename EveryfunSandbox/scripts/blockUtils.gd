extends Node

func getTargetRotation(globalCameraBasisZ: Vector3) -> int:
	var dir = -globalCameraBasisZ
	var vertical_threshold = 0.8
	
	var angle = atan2(dir.z, dir.x)
	var rotation_index = int(round(angle / (PI / 2)) + 2) % 4
	
	var result = rotation_index
	if dir.y < -vertical_threshold:
		result += 4
	elif dir.y > vertical_threshold:
		result += 8
	return result

func getVariantFromVariantAndColor(blockId, variant=0, color=0):
	var obj = game.blockList[blockId]
	for variantObj in obj.variantsList:
		if variantObj.baseVariant == variant && variantObj.colorVariant == color:
			return variantObj.currentVariant
	
func getVariantBlockId(blockId, rotation=0, variant=0, color=0):
	variant = getVariantFromVariantAndColor(blockId, variant, color)
	
	var obj = game.blockList[blockId]
	if obj.has("rotated"):
		rotation = (int(rotation + obj.get("rotationBase", 0)) % 4) + (floor(rotation / 4) * 4)
		blockId = obj.rotated[rotation % obj.rotated.size()].id
		obj = game.blockList[blockId]
	
	return obj.variantsList[variant].id

func blockScriptRequest(blockId: int, methodName, ...args):
	var obj = game.blockList[blockId]
	if obj.has("script"):
		var script = game.loadResource(obj.script).new()
		if script.has_method(methodName):
			return script.callv(methodName, args)
			
func isBlockScriptMethod(blockId: int, methodName):
	var obj = game.blockList[blockId]
	if obj.has("script"):
		var script = game.loadResource(obj.script).new()
		return script.has_method(methodName)
	return false
			
func getDefaultStorageData(blockId: int):
	if isBlockScriptMethod(blockId, "_requestDefaultStorageData"):
		return blockScriptRequest(blockId, "_requestDefaultStorageData")
	return {}
	
func getInfo(blockId: int):
	return game.blockList[blockId].info
	
func isInteractive(blockId: int) -> bool:
	var obj = game.blockList[blockId]
	return obj.has("script") || obj.has("lights")
