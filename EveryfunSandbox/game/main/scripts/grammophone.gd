extends baseblock

func _ready():
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	audioPlayer.stream = preload("res://game/main/music/8.mp3")
	game.initAudioStream(audioPlayer)

	add_child(audioPlayer)
	audioPlayer.play()
