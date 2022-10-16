extends Node3D

@onready var _player_area:Area3D = $PlayerArea
@onready var _placement_area:Area3D = $PlacementArea

# the teleporter stone which this teleporter is currently using
var _teleporter_stone: TeleporterStone
var _player_body: XRToolsPlayerBody

var _teleport_countdown_seconds:float = 0
var _teleport_requested:bool = false

var _teleport_possible:bool:
	get:
		# the player stands on the platform
		return is_instance_valid(_player_body) \
			# and a teleport stone is bound to this platform
			and is_instance_valid(_teleporter_stone) \
			# and the teleport stone is bound to another stone
			and is_instance_valid(_teleporter_stone.bound_target) \
			# and this other stone is in a location where we can teleport to
			and _teleporter_stone.bound_target.teleport_enabled

func _on_placement_area_body_entered(body):
	
	# if we have already a teleporter stone
	# ignore the new one
	if is_instance_valid(_teleporter_stone):
		return		

	# mark the item as the current teleporter stone if it is one
	_teleporter_stone = body as TeleporterStone
	if _teleporter_stone:
		# and set up the target location
		_teleporter_stone.set_teleport_enabled(true, _player_area.global_position)
	

func _on_placement_area_body_exited(body):
	# if there is no teleporter stone currently on this
	# platform, ignore this.
	if not is_instance_valid(_teleporter_stone):
		return
	
		
	if body == _teleporter_stone:
		# make it no longer possible to teleport to this stone
		_teleporter_stone.set_teleport_enabled(false)
		# our stone was removed
		_teleporter_stone = null
		# abort any running teleport process
		_teleport_countdown_seconds = 0

	_teleport_possible = is_instance_valid(_teleporter_stone)


func _on_placement_area_area_entered(area:Area3D):
	# check if the area is the player hand
	if area.is_in_group("player_hand"):
		_teleport_requested = true
		

func _on_placement_area_area_exited(_ignore:Area3D):
	# check if the area still has any player hands in it
	for other_area in _placement_area.get_overlapping_areas():
			if other_area.is_in_group("player_hand"):
				return
	
	# no more player hands
	_teleport_requested = false
	_teleport_countdown_seconds = 0
	

func _on_player_area_body_entered(body):
	# if the player already stands on this platform, ignore
	if is_instance_valid(_player_body):
		return 
		
	# TODO: i don't like that the platform knows how a player body looks like	
	if body.is_in_group("player_body"):
		_player_body = body.get_parent() as XRToolsPlayerBody
		
	
		

func _on_player_area_body_exited(body):
	# player left area
	if body == _player_body:
		_player_body = null


func _process(delta):
	if _teleport_requested and _teleport_possible:
		if _teleport_countdown_seconds > 0:
			_teleport_countdown_seconds -= delta
			if _teleport_countdown_seconds <= 0:
				_teleport_countdown_seconds = 0
				# teleport the player to the target destination
				_player_body.origin_node.global_position = _teleporter_stone.bound_target.teleport_location
		else:
			# start countdown
			_teleport_countdown_seconds = 5.0 				
			
	

