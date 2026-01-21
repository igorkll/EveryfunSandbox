extends Node

var min_random_world_name_len = 5
var max_random_world_name_len = 18
var min_random_player_name_len = 3
var max_random_player_name_len = 9

var minimal_area_load_time = 8
var start_loading_area = 32
var minimal_load_time = 8
var load_time_delay = 1

var settings_path = "user://settings.json"
var chunk_size = 32
var lod_count = 2
var multiplePressTimeout = 300

var minimum_loading_radius_for_play = Vector3i(8, 8, 8)
var player_spawn_vertical_offset = 0.1
var max_interact_distance = 10

var min_human_radius = 0.45

var base_mouse_sensitivity = 0.2
var base_joystick_camera_sensitivity = 200

var player_mul_crouch = 0.5
var player_mul_sprint = 2
var player_mul_fly = 2

var default_scale_on_1080 = 1.5

var default_max_volume_db = 6
var default_sound_unit_size = 16
var default_sound_max_distance = 60
var default_volume_db = 0

var chance_multiplier_to_destroy_a_block_of_greater_strength = 0.8

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
	
	"#badc58",
	"#6ab04c",
	"#30336b",
	"#130f40",
	
	"#dff9fb",
	"#c7ecee",
	"#95afc0",
	"#535c68"
]
