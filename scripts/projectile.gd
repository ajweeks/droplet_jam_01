extends Spatial

var move_speed := 2.0
var color := 0 # 0, 1, 2 => r, g, b

onready var mesh := $projectile_mesh
onready var game := get_tree().get_current_scene() as main_game

onready var mat_red := load("res://materials/mat_red.tres")
onready var mat_green := load("res://materials/mat_green.tres")
onready var mat_blue := load("res://materials/mat_blue.tres")

func _ready():
	set_color(0)

func _process(delta):
	var center = Vector3.ZERO;
	var centerVec = center - transform.origin;
	transform = transform.translated(centerVec.normalized() * (delta * move_speed));

func _on_RigidBody_body_entered(body):
	var cube := body as cube_collider
	game.onProjectileHit(cube.axis, cube.index)

func set_color(inColor):
	color = inColor
	match inColor:
		0: mesh.material = mat_red
		1: mesh.material = mat_green
		2: mesh.material = mat_blue
		_: printerr("invalid color")
