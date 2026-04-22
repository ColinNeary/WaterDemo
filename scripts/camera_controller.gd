extends Camera3D

@export var orbit_target : Vector3 = Vector3(0, 0, 0)
@export var orbit_distance : float = 8.6
@export var orbit_speed : float = 0.4
@export var zoom_speed : float = 1.0
@export var min_distance : float = 3.0
@export var max_distance : float = 30.0
@export var min_pitch : float = 5.0
@export var max_pitch : float = 89.0

# Internal state
var _yaw : float = 45.0
var _pitch : float = 35.0
var _dragging : bool = false

func _ready() -> void:
	var offset := global_position - orbit_target
	orbit_distance = offset.length()
	_pitch = rad_to_deg(asin(offset.y / orbit_distance))
	_yaw = rad_to_deg(atan2(offset.x, offset.z))
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Right mouse = start/stop orbiting
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			
		# Scroll wheel = zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance = clamp(
				orbit_distance - zoom_speed,
				min_distance,
				max_distance
			)
			_update_transform()
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance = clamp(
				orbit_distance + zoom_speed,
				min_distance,
				max_distance
			)
			_update_transform()
			
	if event is InputEventMouseMotion and _dragging:
		_yaw -= event.relative.x * orbit_speed
		_pitch -= event.relative.y * orbit_speed
		_pitch = clamp(_pitch, min_pitch, max_pitch)
		_update_transform()
			
func _update_transform() -> void:
	var pitch_rad := deg_to_rad(_pitch)
	var yaw_rad := deg_to_rad(_yaw)
	var offset := Vector3(
		orbit_distance * cos(pitch_rad) * sin(yaw_rad),
		orbit_distance * sin(pitch_rad),
		orbit_distance * cos(pitch_rad) * cos(yaw_rad)
	)
	global_position = orbit_target + offset
	look_at(orbit_target, Vector3.UP)
			
