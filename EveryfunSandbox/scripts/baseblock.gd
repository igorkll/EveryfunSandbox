extends Node3D
class_name baseblock

var storageData = {}
var scriptData = {}

var voxelTerrain
var voxelPosition: Vector3i

var voxelVariant: int
var voxelBaseVariant: int
var voxelColorVariant: int

var voxelRotation: int
var voxelDirection: Vector3i
var voxelDirectionUp: Vector3i

var voxelBaseBlockId: int
var voxelBaseBlockItem: Dictionary

var voxelBlockId: int
var voxelBlockItem: Dictionary

func destroy():
	terrainUtils.destroyBlock(voxelTerrain, voxelPosition)

func setVariantAndColor(variant, color):
	terrainUtils.setVariantAndColor(voxelTerrain, voxelPosition, variant, color)
	
func setRotationAndVariantAndColor(rotation, variant, color):
	terrainUtils.setRotationAndVariantAndColor(voxelTerrain, voxelPosition, rotation, variant, color)

func getVariantsCount():
	return voxelBlockItem.baseVariantsCount
	
func getColorsCount():
	return voxelBlockItem.colorVariantsCount
	
func getRotationsCount():
	return voxelBlockItem.rotationsCount
	
func getVariant():
	return voxelBaseVariant
	
func getColor():
	return voxelColorVariant
	
func getRotation():
	return voxelRotation
	
func setVariant(variant):
	setVariantAndColor(variant, voxelColorVariant)
	
func setColor(color):
	setVariantAndColor(voxelBaseVariant, color)
	
func setRotation(rotation):
	setRotationAndVariantAndColor(rotation, voxelBaseVariant, voxelColorVariant)

func setVoxelMetadata():
	pass
