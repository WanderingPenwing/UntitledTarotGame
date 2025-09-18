extends Node2D

@export var NormalWorld : TileMapLayer
@export var FlippedWorld : TileMapLayer

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FLIPPED :
		NormalWorld.queue_free()
	else :
		FlippedWorld.queue_free()
