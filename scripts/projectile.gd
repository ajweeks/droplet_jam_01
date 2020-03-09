extends Spatial

var move_speed := 3.2
var color := -1 # 0, 1, 2 => r, g, b

onready var mesh := $projectile_mesh as CSGMesh
onready var game := get_tree().get_current_scene()
onready var rb = $projectile_rb as RigidBody

var red =   Color("#a141e9")  # magenta
var green = Color("#d0dd36")  # yellow
var blue =  Color("#19c3df")  # turq

func _ready():
	mesh.material_override = SpatialMaterial.new()
	mesh.material_override.roughness = 0.0
	mesh.material_override.emission_energy = 1.0
	mesh.material_override.emission_enabled = true
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
		0:
			mesh.material_override.albedo_color = red;
			mesh.material_override.emission = red;
		1:
			mesh.material_override.albedo_color = green;
			mesh.material_override.emission = green;
		2:
			mesh.material_override.albedo_color = blue;
			mesh.material_override.emission = blue;
		_: printerr("invalid color")
