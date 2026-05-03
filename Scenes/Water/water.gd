extends MeshInstance3D

@export var colorRect: ColorRect
@onready var sim_viewport = get_node("../Simulation")

var material: ShaderMaterial

var time: float = 0
var mesh_amplitude: float
var sim_image: Image

# Called when the node enters the scene tree for the first time.
func _ready():
	material = colorRect.material
	var visual_mat = mesh.surface_get_material(0) as ShaderMaterial
	mesh_amplitude = visual_mat.get_shader_parameter("amplitude")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time", time)
	sim_image = sim_viewport.get_texture().get_image()

# Takes in a 3D world position and outputs the water level at that coordinate
# Attempts to copy the existing sine wave injection code in simulate.gdshader
# TODO: Not working as intended
func get_height(world_position: Vector3) -> float:
	if not sim_image:
		return global_position.y

	# Map world position to 0.0-1.0 UV range
	var uv_x = clamp((world_position.x + 6.0) / 12.0, 0.0, 1.0)
	var uv_z = clamp((world_position.z + 6.0) / 12.0, 0.0, 1.0)
	
	# Convert UV to pixel coordinates
	var pixel_x = int(uv_x * (sim_image.get_width() - 1))
	var pixel_y = int(uv_z * (sim_image.get_height() - 1))
	
	# Read the Red channel (which is 'p' in simulation.gdshader)
	var pixel_color = sim_image.get_pixel(pixel_x, pixel_y)
	var displacement = pixel_color.r * mesh_amplitude
	
	return global_position.y + displacement
