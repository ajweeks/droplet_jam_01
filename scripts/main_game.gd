extends Spatial

class_name main_game

onready var cube = load("res://scenes/cube.tscn")
onready var projectile_scene = load("res://scenes/projectile.tscn")
onready var combo_value_text_box := $GUI/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/combo_value as RichTextLabel
onready var hit_scale_curve := load("res://misc/hit_scale_curve.tres") as Curve
onready var audio_manager := $Audio as AudioManager

var cube_inst

var spawn_dist := 6.0

var projectiles : Array
var projectiles_used : Array

var spawn_dirs : Array

var center := Vector3.ZERO;

var songs : Array

var song_index := 0
var beat_index := -1
var elapsed_time_in_song := 0.0

var combo := 0
var time_since_hit := 0.0
var time_scale = 4.0

func _ready():
	songs.append([])
	songs[0].append(120) # BPM
	songs[0].append("x...y...x...y...x...y.x.x.y.x...y...x...y...x..yy.xx.xy.")
	songs[0].append("r...g...g...g...r...r.g.r.g.r...g...g...g...r..rr.gg.rg.")
	
	cube_inst = cube.instance()
	add_child(cube_inst);
	
	resize_projectiles_array(15)
	
	spawn_dirs.append(Vector3.RIGHT)
	spawn_dirs.append(-Vector3.RIGHT)
	spawn_dirs.append(Vector3.UP)
	spawn_dirs.append(-Vector3.UP)
	spawn_dirs.append(Vector3.FORWARD)
	spawn_dirs.append(-Vector3.FORWARD)

func dirCharToDir(dir_char):
	match dir_char:
		'x': return 0;
		'X': return 1;
		'y': return 2;
		'Y': return 3;
		'z': return 4;
		'Z': return 5;
	return -1;

func colorCharToColIdx(color_char):
	match color_char:
		'r': return 0;
		'g': return 1;
		'b': return 2;
	return -1;

func _process(delta):
	elapsed_time_in_song += delta
	var p_time_since_hit = time_since_hit
	time_since_hit += delta*time_scale
	
	if time_since_hit >= 1.0 and p_time_since_hit < 1.0:
		combo_value_text_box.rect_scale = Vector2(1.0, 1.0);
	elif time_since_hit < 1.0:
		var scale = hit_scale_curve.interpolate(time_since_hit)
		combo_value_text_box.rect_scale = Vector2(scale, scale);
	
	var secPerBeat := (int(songs[song_index][0]) / 8.0 / 60.0) # BPM / 8 notes/beat / 60s/min
	
	var p_beat_index := beat_index
	beat_index = int(elapsed_time_in_song / secPerBeat)
	
	if p_beat_index != beat_index and beat_index < songs[song_index][1].length():
		var dirs : String = songs[song_index][1]
		var dir_char := dirs[beat_index]
		if dir_char != '.':
			var new_projectile = next_projectile()
			var dir = dirCharToDir(dir_char)
			var colors : String = songs[song_index][2]
			var color = colorCharToColIdx(colors[beat_index])
			assert(color != -1)
			assert(dir != -1)
			new_projectile.transform.origin = spawn_dirs[dir] * spawn_dist
			new_projectile.set_color(color)
	
	for i in range(projectiles.size()):
		if projectiles_used[i] and projectiles[i].transform.origin.distance_squared_to(center) < 0.1:
			projectiles[i].transform.origin = Vector3(9999,9999,9999)
			projectiles_used[i] = false

func resize_projectiles_array(new_size: int):
	print("Resizing projectiles array to " + str(new_size))
	var old_size = projectiles.size()
	projectiles.resize(new_size)
	projectiles_used.resize(new_size)
	assert(new_size > old_size)
	for i in range(old_size, new_size):
		var new_projectile = projectile_scene.instance()
		new_projectile.transform.origin = Vector3(9999,9999,9999)
		add_child(new_projectile)
		projectiles[i] = new_projectile
		projectiles_used[i] = false

func next_projectile_index():
	for i in range(projectiles_used.size()):
		if not projectiles_used[i]:
			return i;
	resize_projectiles_array(int(ceil(projectiles.size() * 1.5)))
	return next_projectile_index()

func next_projectile():
	var next_index = next_projectile_index()
	projectiles_used[next_index] = true
	return projectiles[next_index]

func onProjectileHit(projectile, axis: int, index: int):
	var correct = projectile.color == axis
	cube_inst.lightFace(axis, index, correct)
	
	if correct:
		combo += 1
		audio_manager.play("bass")
	else:
		combo = 0
		audio_manager.play("scratch")
	
	combo_value_text_box.text = str(combo) + 'x'
	time_since_hit = 0.0
