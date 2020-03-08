extends Spatial

class_name main_game

onready var cube = load("res://scenes/cube.tscn")
onready var projectile = load("res://scenes/projectile.tscn")

var cube_inst

var spawn_dist := 4.0
var time_since_spawn := 99.0
var spawn_dir := 0

var projectiles : Array
var projectiles_used : Array

var spawn_dirs : Array

var center := Vector3.ZERO;

func _ready():
	cube_inst = cube.instance()
	add_child(cube_inst);
	
	resize_projectiles_array(15)
	
	spawn_dirs.append(Vector3.RIGHT)
	spawn_dirs.append(-Vector3.RIGHT)
	spawn_dirs.append(Vector3.UP)
	spawn_dirs.append(-Vector3.UP)
	spawn_dirs.append(Vector3.FORWARD)

func resize_projectiles_array(new_size: int):
	print("Resizing projectiles array to " + str(new_size))
	var old_size = projectiles.size()
	projectiles.resize(new_size)
	projectiles_used.resize(new_size)
	assert(new_size > old_size)
	for i in range(old_size, new_size):
		var new_projectile = projectile.instance()
		new_projectile.transform.origin = Vector3(9999,9999,9999)
		add_child(new_projectile)
		projectiles[i] = new_projectile
		projectiles_used[i] = false

func next_projectile_index():
	for i in range(projectiles_used.size()):
		if !projectiles_used[i]:
			return i;
	resize_projectiles_array(ceil(projectiles.size() * 1.5))
	return next_projectile_index()

func next_projectile():
	var next_index = next_projectile_index()
	projectiles_used[next_index] = true
	return projectiles[next_index]

func _process(delta):
	time_since_spawn += delta
	
	if time_since_spawn > 0.5:
		time_since_spawn = 0.0
		var new_projectile = next_projectile()
		new_projectile.transform.origin = spawn_dirs[spawn_dir] * spawn_dist
		spawn_dir = (spawn_dir + 1) % spawn_dirs.size()
	
	for i in range(projectiles.size()):
		if projectiles[i].transform.origin.distance_squared_to(center) < 0.1:
			projectiles[i].transform.origin = Vector3(9999,9999,9999)
			projectiles_used[i] = false

func onProjectileHit(projectile, axis: int, index: int):
	print("projectile hit axis " + str(axis) + " and index " + str(index))
	cube_inst.lightFace(axis, index)
