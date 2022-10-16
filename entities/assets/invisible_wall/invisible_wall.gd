@tool
extends StaticBody3D

@onready var collision_shape:CollisionShape3D = $CollisionShape3D


var box_shape:BoxShape3D = BoxShape3D.new()

@export var size:Vector3:
	set(value):
		size = value
		_refresh_shape()
	get:
		return size
		

func _ready():
	collision_shape.shape = box_shape
	_refresh_shape()


func _refresh_shape():
	if collision_shape != null:
		box_shape.size = size
		collision_shape.transform.origin = Vector3(0,size.y/2, 0)
