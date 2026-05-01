extends RigidBody3D

## Force applied while a movement key is held (in Newtons; mass=1 by default).
@export var move_force : float = 16.0
## Upward impulse applied on jump.
@export var jump_impulse : float = 7.0
## Max horizontal speed before we stop adding force (prevents runaway).
@export var max_horizontal_speed : float = 6.0
## How far below the surface still counts as "able to jump"
## (gives the ball a bit of buoyant tolerance).
@export var jump_tolerance : float = 0.4
## Speed which ball will float to surface
@export var float_force := 1.0
## Density or friction of water while moving through it
@export var water_drag := 0.05
## Water drag for rotation
@export var water_angular_drag := 0.05

## Approximate y-position of the water surface. Used as a "grounded" check
## so you can only jump from at/above the water, not from mid-dive.
@onready var water: MeshInstance3D = %Water
@onready var water_surface_y := water.global_position.y
## Strength of gravity in this project
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var submerged := false

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
		if global_position.y <= water.get_height(global_position) + jump_tolerance:
			apply_central_impulse(Vector3.UP * jump_impulse)
	
	# Apply buoyancy
	submerged = false
	var depth: float = water.get_height(global_position) - global_position.y
	if depth > 0:
		submerged = true
		apply_force(Vector3.UP * float_force * gravity * depth)

## Apply a slow while submerged in the water
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
