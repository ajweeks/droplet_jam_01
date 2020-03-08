extends Spatial

var target_rot : Quat
var rot_speed := 20.0

var rotations_queue : Array

var zero_rot_thresh = 0.1
var fade_speed = 10.0

func _ready():
	for i in range(6):
		var mesh = get_child(i) as CSGMesh
		mesh.material_override = SpatialMaterial.new()
		mesh.material_override.albedo_color = mesh.material.albedo_color
		mesh.material_override.emission = Color.white
		mesh.material_override.emission_enabled = true
		mesh.material_override.emission_energy = 0.0

func _process(delta):
	transform.basis = Quat(transform.basis).slerp(target_rot, delta*rot_speed);

	if at_zero():
		snap_to_nearest_zero()
		
		if not rotations_queue.empty():
			target_rot = rotations_queue.pop_front() * transform.basis.get_rotation_quat();
	
	for i in range(6):
		var mesh := get_child(i) as CSGMesh
		var mat := mesh.material_override as SpatialMaterial
		if mat.emission_energy > 0.0:
			mat.emission_energy = lerp(mat.emission_energy, 0.0, clamp(delta*fade_speed, 0.0, 1.0));


func _input(event):
	if event.is_action_pressed("rotate_x_pos"):
		rotate(Vector3.RIGHT, -1.0);
	if event.is_action_pressed("rotate_x_neg"):
		rotate(Vector3.RIGHT, 1.0);
	if event.is_action_pressed("rotate_y_pos"):
		rotate(Vector3.UP, -1.0);
	if event.is_action_pressed("rotate_y_neg"):
		rotate(Vector3.UP, 1.0);
	if event.is_action_pressed("rotate_z_pos"):
		rotate(Vector3.FORWARD, -1.0);
	if event.is_action_pressed("rotate_z_neg"):
		rotate(Vector3.FORWARD, 1.0);

func at_zero():
	var axis_rotations : Vector3 = transform.basis.get_euler()
	
	var x_scaled = fmod(abs(axis_rotations.x), PI/2.0) / (PI/2.0)
	var y_scaled = fmod(abs(axis_rotations.y), PI/2.0) / (PI/2.0)
	var z_scaled = fmod(abs(axis_rotations.z), PI/2.0) / (PI/2.0)
	if (x_scaled < zero_rot_thresh or x_scaled > (1.0-zero_rot_thresh)) and \
		(y_scaled < zero_rot_thresh or y_scaled > (1.0-zero_rot_thresh)) and \
		(z_scaled < zero_rot_thresh or z_scaled > (1.0-zero_rot_thresh)):
		return true
	return false

func snap_to_nearest_zero():
	var prev_euler_angles : Vector3 = transform.basis.get_euler()
	var new_euler_angles := Vector3.ZERO
	
	var x_scaled = fmod(abs(prev_euler_angles.x), PI/2.0) / (PI/2.0)
	var y_scaled = fmod(abs(prev_euler_angles.y), PI/2.0) / (PI/2.0)
	var z_scaled = fmod(abs(prev_euler_angles.z), PI/2.0) / (PI/2.0)
	if x_scaled < 0.5:
		new_euler_angles.x = prev_euler_angles.x - fmod(prev_euler_angles.x, PI/2.0)
	else:
		new_euler_angles.x = prev_euler_angles.x + (sign(prev_euler_angles.x) * PI/2.0) - fmod(prev_euler_angles.x, PI/2.0)
	
	if y_scaled < 0.5:
		new_euler_angles.y = prev_euler_angles.y - fmod(prev_euler_angles.y, PI/2.0)
	else:
		new_euler_angles.y = prev_euler_angles.y + (sign(prev_euler_angles.y) * PI/2.0) - fmod(prev_euler_angles.y, PI/2.0)
	
	if z_scaled < 0.5:
		new_euler_angles.z = prev_euler_angles.z - fmod(prev_euler_angles.z, PI/2.0)
	else:
		new_euler_angles.z = prev_euler_angles.z + (sign(prev_euler_angles.z) * PI/2.0) - fmod(prev_euler_angles.z, PI/2.0)

	transform.basis = Quat(new_euler_angles)

func rotate(axis: Vector3, amount: float):
	var delta_rot = Quat(axis, amount * (PI/2.0))
	if at_zero() and rotations_queue.empty():
		target_rot = delta_rot * transform.basis.get_rotation_quat();
	else:
		rotations_queue.push_back(delta_rot)

func lightFace(axis: int, index: int):
	var mesh := get_child(axis * 2 + index) as CSGMesh
	var mat := mesh.material_override as SpatialMaterial
	mat.emission_energy = 1.0
