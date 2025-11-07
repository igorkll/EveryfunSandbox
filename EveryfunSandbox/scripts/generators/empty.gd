extends VoxelGeneratorScript

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	pass
	"""
	var size = buffer.get_size()
	
	for ix in range(size.x):
		for iy in range(size.y):
			for iz in range(size.z):
				var localPos = Vector3i(ix, iy, iz)
				buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
	"""
