extends Node

var settings_path = "user://settings.json"
var minimal_load_time = 1

var minimum_loading_radius_for_play = Vector3i(8, 8, 8)
var player_spawn_vertical_offset = 0.1

var base_mouse_sensitivity = 0.2
var base_joystick_camera_sensitivity = 200

var player_mul_crouch = 0.5
var player_mul_sprint = 2
var player_mul_fly = 2

var default_scale_on_1080 = 1.5

var default_sound_unit_size = 16
var default_sound_max_distance = 60

var extfilter_audio = ["*.mp3, *.wav, *.ogg", "Audio"]

var palette = [
	"#f6e58d",
	"#f9ca24",
	"#7ed6df",
	"#22a6b3",
	"#ffbe76",
	"#f0932b",
	"#e056fd",
	"#be2edd",
	"#ff7979",
	"#eb4d4b",
	"#686de0",
	"#4834d4",
	"#dff9fb",
	"#c7ecee",
	"#95afc0",
	"#535c68"
]
