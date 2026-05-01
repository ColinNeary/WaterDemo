extends MeshInstance3D

@export var colorRect: ColorRect
var material: ShaderMaterial

var wave_frequency: float
var wave_speed: float
var wave_amplitude: float

var time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	material = colorRect.material
	wave_frequency = material.get_shader_parameter("wave_frequency")
	wave_speed = material.get_shader_parameter("wave_speed")
	wave_amplitude = material.get_shader_parameter("wave_amplitude")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time", time)

# Takes in a 3D world position and outputs the water level at that coordinate
# Attempts to copy the existing sine wave injection code in simulate.gdshader
# TODO: Not working as intended
func get_height(world_position: Vector3) -> float:
	# Convert world position to UV-like coordinates 
	var uv_x = wrapf(world_position.x + time * wave_speed, 0, 1)
	var uv_y = wrapf(world_position.z + time * wave_speed, 0, 1)
	
	
	var wave1 = sin(uv_x * wave_frequency + time * wave_speed) * wave_amplitude
	var wave2 = sin((uv_x * 0.7 + uv_y * 0.7) * wave_frequency * 0.8 + time * wave_speed * 0.9) * wave_amplitude * 0.6
	
	return global_position.y + wave1 + wave2
