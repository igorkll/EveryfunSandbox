extends VoxelGeneratorScript

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var size = buffer.get_size()
	for ix in range(0, size.x):
		for iy in range(0, size.y):
			for iz in range(0, size.z):
				var pos = position + Vector3i(ix, iy, iz)
				if pos.y == 10:
					buffer.set_voxel(1, ix, iy, iz, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel(0, ix, iy, iz, VoxelBuffer.CHANNEL_TYPE)
