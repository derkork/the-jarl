class_name TeleporterStone
extends XRToolsPickable

## The teleporter stone to which this stone is bound.
var bound_target:TeleporterStone

## How much time is left until the binding is complete
var _binding_time_seconds_left:float = 0
## Which other teleporter stone are we currently binding to
var _current_binding_target:TeleporterStone = null

## The teleport location where the player will be teleported to.
var teleport_location:Vector3

## Whether the player currently can teleport to this stone.
var teleport_enabled:bool


func set_teleport_enabled(enabled:bool, target_location:Vector3 = Vector3.ZERO):
	teleport_location = target_location
	teleport_enabled = enabled
	

func _on_connector_area_area_entered(other:Area3D):
	# this function is responsible for starting the binding
	# process of this stone. a stone can only be bound when it is
	# currently in the hand of the player (otherwise just placing
	# two stones next to each other would override their binding)
	if not is_picked_up():
		# not in hand, abort
		return
	
	# find out if the other area is from a teleporter stone
	var other_stone = other.get_parent() as TeleporterStone
	
	if not other_stone:
		# it's not a stone, so ignore it.
		return
		
	
	# check if the other stone is also in hand
	if not other_stone.is_picked_up():
		# not in hand, abort
		return
			
	# both stones are in hand. now check if the other
	# stone is already our bound target
	if bound_target == other_stone:
		# nothing to do
		return	
			
	# we want to bind to a new stone now so we start the binding
	# process
	_current_binding_target = other_stone
	_binding_time_seconds_left = 5.0
	
	# also set up the other stone so we don't have race conditions
	other_stone._current_binding_target = self
	other_stone._binding_time_seconds_left = 5.0
			


func _on_connector_area_area_exited(other:Area3D):
	var other_stone = other.get_parent() as TeleporterStone
	
	if not other_stone:
		# not a stone, ignore it
		return
		
	# it is a stone, check if it is our current binding target
	if other_stone == _current_binding_target:
		# abort the binding
		_current_binding_target = null
		_binding_time_seconds_left = 0
		
		# also abort it on the other stone to avoid race conditions
		other_stone._current_binding_target = null
		other_stone._binding_time_seconds_left = 0
	

func _process(delta:float):
	if not is_instance_valid(_current_binding_target):
		# nothing to do
		return
	
	_binding_time_seconds_left -= delta
	if _binding_time_seconds_left <= 0:
		# binding is complete
		bound_target = _current_binding_target
		# also fix up the other side so the data stays consistent
		_current_binding_target.bound_target = self
		
		# and clean up
		_current_binding_target._current_binding_target = null
		_current_binding_target._binding_time_seconds_left = 0
		_current_binding_target = null
		_binding_time_seconds_left = 0
			
	
