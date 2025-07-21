extends block

static var texture = preload("texture.png")
static var mesh = preload("res://mesh/single_texture_block.obj")

var audio_before_explode

func __init():
	var audio_stream = preload("before_explode.mp3")
	audio_before_explode = AudioStreamPlayer3D.new()
	audio_before_explode.max_distance = 64
	audio_before_explode.stream = audio_stream
	add_child(audio_before_explode)

func __interact():
	audio_before_explode.play()
