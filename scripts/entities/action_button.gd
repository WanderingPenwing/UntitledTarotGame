extends Area2D

var state: bool = false
var touched: bool = false

signal toggled(state: bool)

func _ready() -> void:
	$Tradition.hide()
	if GameState.world_status != GameState.STATUS.TRADITION :
		return
	
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	tween.tween_callback($Tradition.show)
	

func _process(_delta: float) -> void:
	var player_touching = false
	
	if GameState.world_status == GameState.STATUS.TRADITION :
		return
	
	for body in get_overlapping_bodies() :
		if not (body.is_in_group("player") or body.is_in_group("flag") or body.is_in_group("mob"))  :
			continue
		player_touching = true
	
	if not player_touching :
		touched = false
		return
	
	if touched :
		return
	
	touched = true
	state = not state
	$sprite.region_rect.position.x = 16 if state else 0
	toggled.emit(state)
