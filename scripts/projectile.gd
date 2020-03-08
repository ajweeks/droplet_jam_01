extends Spatial

var move_speed := 3.0
var color := -1 # 0, 1, 2 => r, g, b

onready var mesh := $projectile_mesh as CSGMesh
onready var game := get_tree().get_current_scene() as main_game

var red =   Color("#c02929")
var green = Color("#258c2c")
var blue =  Color("#1510b3")

func _ready():
	mesh.material_override = SpatialMaterial.new()
	mesh.material_override.roughness = 0.0
	set_color(0)

func _process(delta):
	var center = Vector3.ZERO;
	var centerVec = center - transform.origin;
	transform = transform.translated(centerVec.normalized() * (delta * move_speed));

func _on_RigidBody_body_entered(body):
	var cube := body as cube_collider
	game.onProjectileHit(self, cube.axis, cube.index)

func set_color(inColor):
	if color == inColor:
		return
	color = inColor
	match inColor:
		0: mesh.material_override.albedo_color = red;
		1: mesh.material_override.albedo_color = green;
		2: mesh.material_override.albedo_color = blue;
		_: printerr("invalid color")
