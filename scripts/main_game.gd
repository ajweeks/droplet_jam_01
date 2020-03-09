extends Spatial

class_name main_game

onready var cube = load("res://scenes/cube.tscn")
onready var projectile_scene = load("res://scenes/projectile.tscn")
onready var combo_value_text_box := $GUI/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/combo_value as RichTextLabel
onready var percentage_value_text_box := $GUI/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer4/percentage_value as RichTextLabel
onready var hit_scale_curve := load("res://misc/hit_scale_curve.tres") as Curve
onready var audio_manager := $Audio as AudioManager
onready var particles_scene := load("res://scenes/particles.tscn")

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
var highest_combo := 0
var hit_count := 0
var note_count := 0

var time_since_hit := INF
var time_scale = 4.0

var particles_pool : Array

func _ready():
	songs.append([])
	songs[0].append(120) # BPM
	songs[0].append(0.69) # offset
	songs[0].append("x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.xyxyxyx.x.x.x.x.xyxyxyxyx.x.x.")
	songs[0].append("b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.b.brbrbrb.b.b.b.b.brbrbrbrb.b.b.")
	
	songs.append([])
	songs[1].append(110) # BPM
	songs[1].append(0.0) # offset
	songs[1].append("x...x...x...x...x...y.x.x.y.x...y.x.x.y.y...x..yy.xx.xy.")
	songs[1].append("b...r...g...r...b...r.g.r.g.r...g.g.g.r.g...r..rr.gg.rg.")
	
	resize_particle_pool(6)

	cube_inst = cube.instance()
	add_child(cube_inst);
	
	resize_projectiles_array(15)
	
	spawn_dirs.append(Vector3.RIGHT)
	spawn_dirs.append(-Vector3.RIGHT)
	spawn_dirs.append(Vector3.UP)
	spawn_dirs.append(-Vector3.UP)
	spawn_dirs.append(Vector3.FORWARD)
	spawn_dirs.append(-Vector3.FORWARD)

	update_combo_text()
	update_percentage_text()
	
	var thread = Thread.new()
	thread.start(self, "start_song")	

func start_song(userdata):
	var t = Timer.new()
	t.set_wait_time(songs[song_index][1])
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	yield(t, "timeout")
	
	audio_manager.play_song("house_01")
	
	t.queue_free()

func _process(delta):
	elapsed_time_in_song += delta
	var p_time_since_hit = time_since_hit
	time_since_hit += delta*time_scale
	
	if time_since_hit >= 1.0 and p_time_since_hit < 1.0:
		combo_value_text_box.rect_scale = Vector2(1.0, 1.0);
	elif time_since_hit < 1.0:
		var scale = hit_scale_curve.interpolate(time_since_hit)
		combo_value_text_box.rect_scale = Vector2(scale, scale);
	
	var secPerBeat := (float(songs[song_index][0]) / 8.0 / 60.0) # BPM / 8 notes/beat / 60s/min
	
	var p_beat_index := beat_index
	beat_index = int(elapsed_time_in_song / secPerBeat)
	
	if p_beat_index != beat_index and beat_index < songs[song_index][2].length():
		var dirs : String = songs[song_index][2]
		var dir_char := dirs[beat_index]
		if dir_char != '.':
			var new_projectile = next_projectile()
			var dir = dirCharToDir(dir_char)
			var colors : String = songs[song_index][3]
			var color = colorCharToColIdx(colors[beat_index])
			assert(color != -1)
			assert(dir != -1)
			new_projectile.transform.origin = spawn_dirs[dir] * spawn_dist
			new_projectile.set_color(color)
	
	for i in range(projectiles.size()):
		if projectiles_used[i] and projectiles[i].transform.origin.distance_squared_to(center) < 0.1:
			projectiles[i].transform.origin = Vector3(9999,9999,9999)
			projectiles_used[i] = false

func _input(event):
	if event.is_action_pressed("restart"):
		restart()

func restart():
	combo = 0
	beat_index = -1
	time_since_hit = 0.0
	elapsed_time_in_song = 0.0
	hit_count = 0
	note_count = 0
	for i in range(projectiles.size()):
		projectiles[i].transform.origin = Vector3(9999,9999,9999)
		projectiles_used[i] = false
	cube_inst.reset()
	update_combo_text()
	update_percentage_text()

func update_combo_text():
	combo_value_text_box.text = str(combo) + 'x'

func update_percentage_text():
	var val = (hit_count / float(note_count)) if note_count > 0 else 1.0
	percentage_value_text_box.text = ("%.2f" % (val*100)) + '%'

func resize_particle_pool(new_size: int):
	print("Resizing particles pool to " + str(new_size))
	var old_size := particles_pool.size()
	assert(new_size > old_size)
	particles_pool.resize(new_size)
	for i in range(old_size, new_size):
		particles_pool[i] = particles_scene.instance()
		var p := particles_pool[i] as Particles
		p.emitting = false
		add_child(p)

func next_particle_system() -> Particles:
	for i in range(particles_pool.size()):
		if not particles_pool[i].emitting:
			return particles_pool[i]
	resize_particle_pool(int(ceil(particles_pool.size() * 1.5)))
	return next_particle_system()

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

func next_projectile_index() -> int:
	for i in range(projectiles_used.size()):
		if not projectiles_used[i]:
			return i;
	resize_projectiles_array(int(ceil(projectiles.size() * 1.5)))
	return next_projectile_index()

func next_projectile():
	var next_index = next_projectile_index()
	projectiles_used[next_index] = true
	return projectiles[next_index]

func dirCharToDir(dir_char) -> int:
	match dir_char:
		'x': return 0;
		'X': return 1;
		'y': return 2;
		'Y': return 3;
		'z': return 4;
		'Z': return 5;
	return -1;

func colorCharToColIdx(color_char) -> int:
	match color_char:
		'r': return 0;
		'g': return 1;
		'b': return 2;
	return -1;

func onProjectileHit(projectile, axis: int, index: int):
	var correct = projectile.color == axis
	cube_inst.lightFace(axis, index, correct)
	
	var p := next_particle_system() as Particles
	p.restart()
	var t = p.transform as Transform
	t.origin = projectile.transform.origin
	var p_rb := projectile.rb as RigidBody
	var fwd = p_rb.linear_velocity
	var up = fwd.cross(Vector3(0.5, 0.5, 0.5)).normalized()
	p.transform = t.looking_at(fwd, up)
	
	note_count += 1
	
	if correct:
		combo += 1
		hit_count += 1
		highest_combo = max(highest_combo, combo)
		audio_manager.play("hihat" if axis == 0 else "snare" if axis == 1 else "bass")
	else:
		combo = 0
		audio_manager.play("scratch")
	
	update_combo_text()
	update_percentage_text()
	time_since_hit = 0.0
