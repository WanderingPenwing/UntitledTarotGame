extends TileMapLayer

const WATER = Vector2i(3, 0)
const ICE = Vector2i(3, 1)

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	
	if GameState.world_status == GameState.STATUS.FROZEN :
		tween.tween_callback(freeze)
	$Blind.hide()
	if GameState.world_status == GameState.STATUS.BLIND :
		tween.tween_callback($Blind.show)
	
	if GameState.world_status == GameState.STATUS.FOOL :
		var mob = get_tree().get_first_node_in_group("mob")
		var player = get_tree().get_first_node_in_group("player")
		var mob_pos = mob.position
		var player_pos = player.position
		tween.tween_property(mob, "position", player_pos, 0.1)
		tween.parallel().tween_property(player, "position", mob_pos, 0.1)

func freeze() -> void :
	for x in range(0, 9) :
		for y in range(0, 8) :
			if get_cell_atlas_coords(Vector2i(x,y)) == WATER :
				set_cell(Vector2i(x,y), 0, ICE)
