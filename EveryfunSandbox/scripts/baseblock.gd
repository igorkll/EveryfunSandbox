extends Node3D
class_name baseblock

var storageData = {}
var scriptData = {}

var voxelTerrain
var voxelPosition: Vector3i
var voxelRotation: int
var voxelVariant: int
var voxelBaseVariant: int
var voxelColorVariant: int
var voxelDirection: Vector3i
var voxelDirectionUp: Vector3i

var voxelBaseBlockId: int
var voxelBaseBlockItem: Dictionary

var voxelBlockId: int
var voxelBlockItem: Dictionary

var multiblock: Vector3i
var multiblockRelative: Vector3i

func getVariantsCount():
	return voxelBlockItem.variantsList.size()

func getVariant():
	return voxelBlockItem.currentVariant

func setVariant(variant):
	voxelVariant = variant
	voxelBlockId = game.getVariantBlockId(voxelBaseBlockId, voxelRotation, voxelVariant)
	voxelBlockItem = game.blockList[voxelBlockId]
	voxelTerrain.voxel_tool.set_voxel(voxelPosition, voxelBlockId)
	saves.changeInteractiveVoxel(voxelTerrain, position, voxelBlockId)

func destroy():
	terrainUtils.destroyBlock(voxelTerrain, voxelPosition, false)
