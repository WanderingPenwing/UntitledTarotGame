extends TileMapLayer

const WATER = Vector2i(3, 0)
const ICE = Vector2i(3, 1)

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FROZEN :
		modulate = Color.PALE_TURQUOISE
		for x in range(0, 9) :
			for y in range(0, 8) :
				if get_cell_atlas_coords(Vector2i(x,y)) == WATER :
					set_cell(Vector2i(x,y), 0, ICE)
	if GameState.world_status == GameState.STATUS.BLIND :
		modulate = Color.BLACK 
	
	if GameState.world_status == GameState.STATUS.FLIPPED :
		scale.y = -1
		position.y = 144
	
	if GameState.world_status == GameState.STATUS.FOOL :
		var mob = get_tree().get_first_node_in_group("mob")
		var player = get_tree().get_first_node_in_group("player")
		var mob_pos = mob.position
		mob.position = player.position
		player.position = mob_pos
