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

func setVariantAndColor(variant, color):
	voxelVariant = game.getVariantFromVariantAndColor(voxelBaseBlockId, variant, color)
	voxelBaseVariant = variant
	voxelColorVariant = color
	
	voxelBlockId = game.getVariantBlockId(voxelBaseBlockId, voxelRotation, variant, color)
	voxelBlockItem = game.blockList[voxelBlockId]
	
	voxelTerrain.voxel_tool.set_voxel(voxelPosition, voxelBlockId)
	saves.changeInteractiveVoxel(voxelTerrain, voxelPosition, voxelBlockId)

func getVariantsCount():
	return voxelBlockItem.baseVariantsCount
	
func getColorsCount():
	return voxelBlockItem.colorVariantsCount
	
func getVariant():
	return voxelBaseVariant
	
func getColor():
	return voxelColorVariant
	
func setVariant(variant):
	setVariantAndColor(variant, voxelColorVariant)
	
func setColor(color):
	setVariantAndColor(voxelBaseVariant, color)

func destroy():
	terrainUtils.destroyBlock(voxelTerrain, voxelPosition, false)
