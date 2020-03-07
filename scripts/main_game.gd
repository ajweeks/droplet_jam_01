extends Spatial

onready var cube = load("res://scenes/cube.tscn")
onready var projectile = load("res://scenes/projectile.tscn")

var spawn_dist := 4.0
var time_since_spawn := 0.0
var spawn_dir := 0

var projectiles : Array
var projectiles_used : Array

var spawn_dirs : Array

var center := Vector3.ZERO;

func _ready():
	add_child(cube.instance());
	
	resize_projectiles_array(30)
	
	spawn_dirs.append(Vector3.RIGHT)
	spawn_dirs.append(-Vector3.RIGHT)
	spawn_dirs.append(Vector3.UP)
	spawn_dirs.append(-Vector3.UP)
	spawn_dirs.append(Vector3.FORWARD)

func resize_projectiles_array(new_size: int):
	print("Resizing projectiles array to " + str(new_size))
	var old_size = projectiles.size()
	assert(new_size > old_size)
	for i in range(old_size, new_size):
		var new_projectile = projectile.instance()
		new_projectile.transform.origin = Vector3.INF
		projectiles.append(new_projectile)
		projectiles_used.append(false)

func next_projectile_index():
	for i in range(projectiles_used.size()):
		if !projectiles_used[i]:
			return i;
	resize_projectiles_array(int(projectiles.size() * 1.5))

func next_projectile():
	var next_index = next_projectile_index()
	projectiles_used[next_index] = true
	return projectiles[next_index]

func _process(delta):
	time_since_spawn += delta
	
	if time_since_spawn > 1.0:
		time_since_spawn = 0.0
		var new_projectile = next_projectile()
		new_projectile.transform.origin = spawn_dirs[spawn_dir] * spawn_dist
		spawn_dir = (spawn_dir + 1) % spawn_dirs.size()
		add_child(new_projectile)
	
	for i in range(projectiles.size()):
		if projectiles[i].transform.origin.distance_squared_to(center) < 0.1:
			projectiles[i].transform.origin = Vector3.INF
			projectiles_used[i] = false
