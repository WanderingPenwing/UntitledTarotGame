extends Node2D

@export var NormalWorld : TileMapLayer
@export var FlippedWorld : TileMapLayer

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FLIPPED :
		FlippedWorld.hide()
		var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(0.9)
		tween.tween_callback(NormalWorld.queue_free)
		tween.tween_callback(FlippedWorld.show)
	else :
		FlippedWorld.queue_free()
