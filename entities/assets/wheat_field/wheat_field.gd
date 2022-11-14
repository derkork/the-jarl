extends Node3D
@tool

@export var amount:int:
	set(value): 
		amount = value
		repaint(true)
		
@export var size:Vector2:
	set(value): 
		size = value
		repaint(true)
		
@export var y_offset:float:
	set(value): 
		y_offset = value
		repaint(true)

@export_range(0, 1) var growth:float:
	set(value): 
		growth = value
		repaint(false)

@onready var wheat_multimesh:MultiMeshInstance3D = $WheatMultiMesh



# Called when the node enters the scene tree for the first time.
func _ready():
	repaint(true)
	

func repaint(rebuild:bool):
	if not is_instance_valid(wheat_multimesh):
		return
		
	if rebuild:
		wheat_multimesh.multimesh.instance_count = 0
		wheat_multimesh.multimesh.use_custom_data = true
		wheat_multimesh.multimesh.instance_count = amount
		
	for i in range(amount):
		if rebuild:
			var instance_position = Transform3D()
			instance_position = instance_position.translated( Vector3( \
					randf() * size.x - size.x/2, \
					y_offset, \
					randf() * size.y - size.y/2))
			wheat_multimesh.multimesh.set_instance_transform(i, instance_position)	
		wheat_multimesh.multimesh.set_instance_custom_data(i, Color(i, growth, 0, 0))
	
