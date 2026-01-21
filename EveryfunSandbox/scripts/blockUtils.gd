extends Node

var list_id2obj = []
var list_name2id = {}
var blockLibrary

var _blockMaterials = []
var _materialCache = {}
var _blockColliders = {}

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
	var obj = list_id2obj[blockId]
	for variantObj in obj.variantsList:
		if variantObj.baseVariant == variant && variantObj.colorVariant == color:
			return variantObj.currentVariant
	
func getVariantBlockId(blockId, rotation=0, variant=0, color=0):
	variant = getVariantFromVariantAndColor(blockId, variant, color)
	
	var obj = list_id2obj[blockId]
	if obj.has("rotated"):
		rotation = (int(rotation + obj.get("rotationBase", 0)) % 4) + (floor(rotation / 4) * 4)
		blockId = obj.rotated[rotation % obj.rotated.size()].id
		obj = list_id2obj[blockId]
	
	return obj.variantsList[variant].id

func scriptRequest(blockId: int, methodName, ...args):
	var obj = list_id2obj[blockId]
	if obj.has("script"):
		var script = game.loadResource(obj.script).new()
		if script.has_method(methodName):
			return script.callv(methodName, args)
			
func isScriptMethod(blockId: int, methodName):
	var obj = list_id2obj[blockId]
	if obj.has("script"):
		var script = game.loadResource(obj.script).new()
		return script.has_method(methodName)
	return false
			
func getDefaultStorageData(blockId: int):
	if isScriptMethod(blockId, "_requestDefaultStorageData"):
		return scriptRequest(blockId, "_requestDefaultStorageData")
	return {}
	
func getInfo(blockId: int):
	return list_id2obj[blockId].info
	
func isInteractive(blockId: int) -> bool:
	var obj = list_id2obj[blockId]
	return (obj.has("script") && !obj.has("script_temp")) || obj.has("lights")
	
func getBlockCollider(blockId: int):
	if blockId > 0:
		return _blockColliders.get(blockId, _defaultBlockCollider)
	return null

# ------------------------------------------------- backend

var _default_material_texture = preload("res://textures/materialTexture.png")
var _blocks_shader = preload("res://shaders/blocks.gdshader")
var _alpha_blocks_shader = preload("res://shaders/alpha_blocks.gdshader")

var _defaultBlockInfo = {
	"durability": 1,
	"weight": 10,
	"center_of_mass": [0, 0, 0]
}

# map size: x y
# texture pos: x- x+ y- y+ z- z+
var _textureModes = {
	"DIFFERENT_SIDES": [
		Vector2i(3, 3),
		
		Vector2i(0, 1),
		Vector2i(2, 1),
		Vector2i(0, 0),
		Vector2i(1, 1),
		Vector2i(1, 2),
		Vector2i(1, 0)
	],
	"UNIFORM": [
		Vector2i(1, 1),
		
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0)
	],
	"UNIFORM_TOP_BOTTOM": [
		Vector2i(1, 3),
		
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 2),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	],
	"UNIFORM_SIDE": [
		Vector2i(2, 1),
		
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0)
	],
	"UNIFORM_SIDE_TOP_BOTTOM": [
		Vector2i(2, 3),
		
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(0, 2),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	],
	"UNIFORM_TOP": [
		Vector2i(1, 2),
		
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	]
}

var _rotationModes = {
	"NONE": [
	],
	"360": [
		{y=1, r = Vector3i(0, -90, 0), d = Vector3i(0, 0, 1), u = Vector3i(0, 1, 0), q = 16},
		{y=2, r = Vector3i(0, -90 * 2, 0), d = Vector3i(-1, 0, 0), u = Vector3i(0, 1, 0), q = 10},
		{y=3, r = Vector3i(0, -90 * 3, 0), d = Vector3i(0, 0, -1), u = Vector3i(0, 1, 0), q = 22}
	],
	"360V": [
		{y=0, r = Vector3i(0, 0, 90), d = Vector3i(0, 1, 0), u = Vector3i(-1, 0, 0), q = 3},
		{y=1, r = Vector3i(0, -90, 90), d = Vector3i(0, 1, 0), u = Vector3i(0, 0, -1), q = 19},
		{y=2, r = Vector3i(0, -90 * 2, 90), d = Vector3i(0, 1, 0), u = Vector3i(1, 0, 0), q = 9},
		{y=3, r = Vector3i(0, -90 * 3, 90), d = Vector3i(0, 1, 0), u = Vector3i(0, 0, 1), q = 21},
		
		{y=0, r = Vector3i(0, 0, -90), d = Vector3i(0, -1, 0), u = Vector3i(-1, 0, 0), q = 1},
		{y=1, r = Vector3i(0, -90, -90), d = Vector3i(0, -1, 0), u = Vector3i(0, 0, -1), q = 17},
		{y=2, r = Vector3i(0, -90 * 2, -90), d = Vector3i(0, -1, 0), u = Vector3i(1, 0, 0), q = 11},
		{y=3, r = Vector3i(0, -90 * 3, -90), d = Vector3i(0, -1, 0), u = Vector3i(0, 0, 1), q = 23}
	]
}

var _materialCacheNames = [
	"material",
	"texture",
	"use_alpha",
	"painted"
]

var _soundsTypes = [
	"sound_walking",
	"sound_jump",
	"sound_headbutt",
	"sound_place",
	"sound_destroy",
	"sound_hit"
]

var _transparency_material
var _defaultBlockCollider

func _ready():
	var array_360_modes = _rotationModes["360"].duplicate()
	array_360_modes.reverse()
	for rotationMode_360 in array_360_modes:
		_rotationModes["360V"].insert(0, rotationMode_360)
		
	_transparency_material = StandardMaterial3D.new()
	_transparency_material.albedo_color = Color(1,1,1,0)
	_transparency_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_transparency_material.flags_transparent = true
	
	_defaultBlockCollider = BoxShape3D.new()
	_defaultBlockCollider.size = Vector3(1, 1, 1)
	
func unloadBlockList():
	list_id2obj = []
	list_name2id = {}

func updateBlockList():
	_blockColliders = {}
	_blockMaterials = []
	_materialCache = {}
	_genLibrary()

func _duplicateItem(item):
	var oldVariantsList = item.variantsList
	var oldRotatedList = item.rotated
	item.erase("variantsList")
	item.erase("rotated")
	var duplicatedItem = item.duplicate(true)
	item.variantsList = oldVariantsList
	item.rotated = oldRotatedList
	return duplicatedItem

func _checkVariants(blockVariants, item):
	item.currentVariant = 0
	item.baseVariant = 0
	item.colorVariant = 0
	item.baseVariantsCount = 1
	item.colorVariantsCount = 1
	if item.has("variants"):
		item.baseVariantsCount += item["variants"].size()
	if item.get("paintable", false):
		item.colorVariantsCount += consts.palette.size()
	item.variantsList = [item]
	
	var currentVariant = 1
	if item.has("variants"):
		for variant in item["variants"]:
			var variantItem = item.merged(variant, true)
			variantItem.variantsList = item.variantsList
			variantItem.currentVariant = currentVariant
			variantItem.baseVariant = currentVariant
			item.variantsList.append(variantItem)
			blockVariants.append(variantItem)
			currentVariant += 1
			
	if item.get("paintable", false):
		var variantsList = item.variantsList.duplicate(false)
		for oldVariantItem in variantsList:
			var colorVariant = 1
			for paintedColor in consts.palette:
				var variantItem = _duplicateItem(oldVariantItem)
				
				variantItem.painted = Color(paintedColor)
				if variantItem.has("lights"):
					for lightObj in variantItem.lights:
						lightObj.color = lightObj.get("color", paintedColor)
				
				variantItem.variantsList = item.variantsList
				variantItem.currentVariant = currentVariant
				variantItem.baseVariant = oldVariantItem.baseVariant
				variantItem.colorVariant = colorVariant
				item.variantsList.append(variantItem)
				blockVariants.append(variantItem)
				currentVariant += 1
				colorVariant += 1

func _prepairItemProcessPath(userPath, jsonDir, baseAddonDir):
	if userPath.begins_with("!"):
		return baseAddonDir.path_join(userPath.substr(1))
	return jsonDir.path_join(userPath)

func _prepairItem(item, path, basepath):
	if item.has("sound"):
		for soundkey in _soundsTypes:
			if not item.has(soundkey):
				item[soundkey] = item.sound
				
	if item.has("sound_placeDestroy"):
		item.sound_place = item.sound_placeDestroy
		item.sound_destroy = item.sound_placeDestroy
		
	if item.has("mesh"):
		item.mesh = game.loadResource(_prepairItemProcessPath(item.mesh, path, basepath))
		if item.mesh is PackedScene:
			item.mesh = item.mesh.instantiate()
	
	if item.has("texture"):
		item.texture = game.loadResource(_prepairItemProcessPath(item.texture, path, basepath))

	if item.has("material"):
		item.material = game.loadResource(_prepairItemProcessPath(item.material, path, basepath))
	
	if item.has("script"):
		item.script = _prepairItemProcessPath(item.script, path, basepath)
		
	if item.has("info"):
		item.info = funcs.merge_dicts(item.info, _defaultBlockInfo)
	else:
		item.info = _defaultBlockInfo
		
	var info = item.info
	if item.has("rotation"):
		var rotation = item.rotation.r
		info.center_of_mass = funcs.rotateVectorIn_degrees(funcs.vecFromArr(info.center_of_mass), rotation)
	else:
		info.center_of_mass = funcs.vecFromArr(info.center_of_mass)

func regBlockList(jsonPath, basepath):
	var path = jsonPath.get_base_dir()
	
	var list = filesystem.checkExistsAndReadJson(jsonPath)
	if list:
		game.processForks(list)
		
		var blockVariants = []
		var rotatedBlocks = []
		for item in list:
			item.id = list_id2obj.size()
			item.baseId = item.id
			if item.has("name"):
				list_name2id[item.name] = item.id
			
			item.rotationsCount = 1
			item.currentRotation = 0
			item.rotated = [item]
			
			_checkVariants(blockVariants, item)
			
			if item.has("rotationMode"):
				var rotationMode = _rotationModes[item.rotationMode]
				var currentRotation = 1
				for rotation in rotationMode:
					var rotated = item.duplicate(false)
					rotated.rotated = item.rotated
					rotated.currentRotation = currentRotation
					rotated.rotation = rotation
					rotatedBlocks.append(rotated)
					item.rotated.append(rotated)
					currentRotation += 1
				item.rotationsCount = currentRotation
			
			_prepairItem(item, path, basepath)
			list_id2obj.append(item)
			
		for rotatedBlock in rotatedBlocks:
			rotatedBlock.id = list_id2obj.size()
			_checkVariants(blockVariants, rotatedBlock)
			_prepairItem(rotatedBlock, path, basepath)
			list_id2obj.append(rotatedBlock)
			
		for blockVariant in blockVariants:
			blockVariant.id = list_id2obj.size()
			_prepairItem(blockVariant, path, basepath)
			list_id2obj.append(blockVariant)

func _getMaterial(block):
	block.use_alpha = block.get("use_alpha", false)
	
	var cachename = funcs.checksum_dict(block, _materialCacheNames)
	if _materialCache.has(cachename):
		return _materialCache[cachename]
	
	var material = ShaderMaterial.new()
	if block["use_alpha"]:
		material.shader = _alpha_blocks_shader
	else:
		material.shader = _blocks_shader
	
	var materialTexture = block.get("material", _default_material_texture)
	var texture = block.texture
	
	if block.has("painted"):
		texture = funcs.tint_texture(texture, block.painted)
	
	material.set_shader_parameter("material_texture", materialTexture);	
	material.set_shader_parameter("dif_texture", texture);
	
	_materialCache[cachename] = material
	_blockMaterials.append(material)
	return material

func _genLibrary():
	blockLibrary = VoxelBlockyLibrary.new()
	
	var index = 0
	for block in list_id2obj:
		var blockModel
		if block.has("mesh"):
			var material = _getMaterial(block)
			
			blockModel = VoxelBlockyModelMesh.new()
			
			var mesh
			if block.mesh is Mesh:
				mesh = block.mesh
			else:
				var mesh_instance = block.mesh.find_children("", "MeshInstance3D", true)
				if mesh_instance.size() > 0:
					mesh = mesh_instance[0].mesh
			
			var auto_collision_value = block.get("auto_collision")
			if auto_collision_value:
				if not funcs.is_number(auto_collision_value):
					auto_collision_value = 0.2
				mesh = funcs.save_only_first_surface(mesh)
				mesh = funcs.copy_surface_with_reduction(mesh, auto_collision_value)
				block.mesh_collision = mesh.get_surface_count() - 1
				
			blockModel.mesh = mesh
			
			var mesh_collision_enabled = block.get("mesh_collision", true)
			var collision_surfaces = []
			for i in range(mesh.get_surface_count()):
				var _mesh_collision_enabled = mesh_collision_enabled
				if funcs.is_number(mesh_collision_enabled):
					_mesh_collision_enabled = mesh_collision_enabled == i
				blockModel.set_mesh_collision_enabled(i, _mesh_collision_enabled)
				
				if _mesh_collision_enabled:
					collision_surfaces.append(i)
				
				if block.get("hide_collision") && _mesh_collision_enabled:
					mesh.surface_set_material(i, _transparency_material)
				else:
					mesh.surface_set_material(i, material)
			
			if collision_surfaces.size() > 0:
				var rotation_degrees = Vector3()
				if block.has("rotation"):
					rotation_degrees = block.rotation.r
				
				blockModel.collision_aabbs = funcs.make_aabbs_from_surfaces(mesh, collision_surfaces, rotation_degrees)
				_blockColliders[index] = funcs.make_shape_from_surfaces(mesh, collision_surfaces)
			else:
				blockModel.collision_aabbs = [AABB(Vector3(0, 0, 0), Vector3(1, 1, 1))]
		elif block.has("texture"):
			var material = _getMaterial(block)
			
			var textureMode = _textureModes[block.get("texture_mode", 1)]
			blockModel = VoxelBlockyModelCube.new()
			blockModel.atlas_size_in_tiles = textureMode[0]
			blockModel.set_material_override(0, material)
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_X, textureMode[1])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_X, textureMode[2])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Y, textureMode[3])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Y, textureMode[4])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Z, textureMode[5])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Z, textureMode[6])
		else:
			blockModel = VoxelBlockyModelEmpty.new()
		
		if blockModel is not VoxelBlockyModelEmpty:
			if block.has("rotation"):
				blockModel.mesh_ortho_rotation_index = block.rotation.q
			else:
				blockModel.mesh_ortho_rotation_index = 0
		
		blockModel.transparency_index = block.get("transparency_index", 1 if block.get("use_alpha", false) else 0)
		blockModel.culls_neighbors = block.get("culls_neighbors", true)
		blockLibrary.add_model(blockModel)
		index += 1
