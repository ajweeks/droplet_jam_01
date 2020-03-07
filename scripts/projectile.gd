extends Spatial

var move_speed := 1.0

func _process(delta):
	var center = Vector3.ZERO;
	var centerVec = center - transform.origin;
	transform = transform.translated(centerVec.normalized() * (delta * move_speed));
	
