extends RigidBody3D

## Force applied while a movement key is held (in Newtons; mass=1 by default).
@export var move_force : float = 16.0
## Upward impulse applied on jump.
@export var jump_impulse : float = 7.0
## Max horizontal speed before we stop adding force (prevents runaway).
@export var max_horizontal_speed : float = 6.0
## Approximate y-position of the water surface. Used as a "grounded" check
## so you can only jump from at/above the water, not from mid-dive.
@export var water_surface_y : float = 0.0
## How far below the surface still counts as "able to jump"
## (gives the ball a bit of buoyant tolerance).
@export var jump_tolerance : float = 0.4

func _physics_process(_delta: float) -> void:
	# Read WASD as a 2D vector. y is forward/back, mapped to world -Z/+Z.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if input_dir != Vector2.ZERO:
		var force := Vector3(input_dir.x, 0.0, input_dir.y) * move_force
		# Only push if we're under the speed cap on that axis.
		# This lets you change direction freely but caps top speed.
		var horizontal_velocity := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
		if horizontal_velocity.length() < max_horizontal_speed:
			apply_central_force(force)
	
	# Jump: only when at or near the water surface.
	if Input.is_action_just_pressed("jump"):
		if global_position.y <= water_surface_y + jump_tolerance:
			apply_central_impulse(Vector3.UP * jump_impulse)
