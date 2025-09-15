extends TileMapLayer

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FROZEN :
		modulate = Color.PALE_TURQUOISE
	if GameState.world_status == GameState.STATUS.BLIND :
		modulate = Color.BLACK 
	if GameState.world_status == GameState.STATUS.FLIPPED :
		scale.y = -1
		position.y = 144
