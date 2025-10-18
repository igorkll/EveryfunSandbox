extends Node3D
class_name baseblock

var storageData = {}

var voxelTerrain
var voxelPosition: Vector3i
var voxelRotation: int
var voxelDirection: Vector3i
var voxelDirectionUp: Vector3i

var voxelBaseBlockId: int
var voxelBlockId: int
var voxelBaseBlockItem: Dictionary
var voxelBlockItem: Dictionary

var multiblock: Vector3i
var multiblockRelative: Vector3i

func getVariantsCount():
	return voxelBaseBlockItem.variantsList.len()
