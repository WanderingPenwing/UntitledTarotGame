extends Area2D

var state: bool = false
var touched: bool = false

signal toggled(state: bool)

func _process(delta: float) -> void:
	var player_touching = false
	
	for body in get_overlapping_bodies() :
		if not body.is_in_group("player") :
			continue
		player_touching = true
	
	if not player_touching :
		touched = false
		return
	
	if touched :
		return
	print("changed ", state)
	touched = true
	state = not state
	$off.visible = not state
	$on.visible = state
	toggled.emit(state)
