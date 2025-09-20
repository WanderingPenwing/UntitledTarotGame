extends Node2D

@export var NormalWorld : TileMapLayer
@export var FlippedWorld : TileMapLayer

func _ready() -> void:
	if GameState.world_status == GameState.STATUS.FLIPPED :
		FlippedWorld.hide()
		FlippedWorld.scale = Vector2(1,0)
		FlippedWorld.position = Vector2(0, 72)
		var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(0.9)
		tween.tween_property(NormalWorld, "scale", Vector2(1,0), 0.05)
		tween.parallel().tween_property(NormalWorld, "position", Vector2(0,72), 0.05)
		tween.tween_property(NormalWorld, "scale", Vector2(1,0), 0.05)
		tween.tween_callback(NormalWorld.queue_free)
		tween.tween_callback(FlippedWorld.show)
		tween.tween_property(FlippedWorld, "scale", Vector2(1,1), 0.05)
		tween.parallel().tween_property(FlippedWorld, "position", Vector2(0,0), 0.05)
	else :
		FlippedWorld.queue_free()
