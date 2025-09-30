extends VoxelGeneratorScript

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var div = lod + 1
	
	var size = buffer.get_size()
	for ix in range(0, size.x / div):
		for iy in range(0, size.y / div):
			for iz in range(0, size.z / div):
				if (iy + div) + position.y == 10:
					buffer.set_voxel(1, ix, iy, iz, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel(0, ix, iy, iz, VoxelBuffer.CHANNEL_TYPE)
