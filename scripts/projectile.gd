extends Spatial

var move_speed := 2.0

onready var game := get_tree().get_current_scene() as main_game

func _process(delta):
	var center = Vector3.ZERO;
	var centerVec = center - transform.origin;
	transform = transform.translated(centerVec.normalized() * (delta * move_speed));

func _on_RigidBody_body_entered(body):
	var cube := body as cube_collider
	game.onProjectileHit(self, cube.axis, cube.index)

