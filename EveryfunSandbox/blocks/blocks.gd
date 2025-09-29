extends Node

var material
var library

var blockslist = [
	
]

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://blocks/blocks.gdshader")
	
	library = _get_library()

func _get_library():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	var block = VoxelBlockyModelCube.new()
	block.set_material_override(0, blocks.material)
	library.add_model(block)
	
	var block2 = VoxelBlockyModelCube.new()
	block2.set_material_override(0, blocks.material)
	block2.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_X, Vector2i(1, 0))
	library.add_model(block2)
	
	return library
