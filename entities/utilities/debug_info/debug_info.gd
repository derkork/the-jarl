@tool
extends Label3D


@export var watches:Array[DebugWatch] = []
@export var refresh_interval_seconds:float = 0.5

# Start with a refresh interval so we get immediately updated
# on start
@onready var _accumulated_seconds:float = refresh_interval_seconds

func _process(delta):
	
	# take note of the time that has passed
	_accumulated_seconds += delta
	if _accumulated_seconds < refresh_interval_seconds:
		return

	# if we have reached the update interval, reset the counter
	# and update the label's contents
	_accumulated_seconds -= refresh_interval_seconds
	
	var label_text:String = ""
	for watch in watches:
		if watch == null:
			continue
		
		var watched_node = get_node_or_null(watch.node)
		if watched_node == null:
			continue
		
		# if we have a title on the watch, use this one
		if len(watch.title) > 0:
			label_text += watch.title + "\n"
		else:
			# otherwise use the name of the watched node
			label_text += str(watched_node.name) + "\n"
		
		if watch.properties == null or watch.properties.size() == 0:
			label_text += "<no watched properties>"
			# no properties in this watch, ignore
			continue
		
		for property in watch.properties:
			var property_value = watched_node.get_indexed(property)
			if property_value is Callable:
				property_value = property_value.call()
				
			var value:String = str(property_value)
			label_text += "%s -> %s\n" % [property, value]
	
	text = label_text
	
	
	


		
	
		
		
		
