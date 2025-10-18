extends baseblock

var audioPlayer

func _ready():
	audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = "Grammophone"
	audioPlayer.stream = preload("res://game/main/music/8.mp3")
	game.initAudioStream(audioPlayer)

	add_child(audioPlayer)
	audioPlayer.play()

func _process(delta):
	audioPlayer.volume_db = -15
