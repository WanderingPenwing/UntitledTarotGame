extends TileMapLayer

func _ready() -> void:
	if GameState.world_status == GameState.STATUS_FROZEN :
		modulate = Color.PALE_TURQUOISE
	if GameState.world_status == GameState.STATUS_BLIND :
		modulate = Color.BLACK 
	if GameState.world_status == GameState.STATUS_FLIPPED :
		scale.y = -1
		position.y = 144
