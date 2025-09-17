extends Area2D

var state: bool = false
var touched: bool = false

signal toggled(state: bool)

func _process(_delta: float) -> void:
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
	$sprite.region_rect.position.x = 32 if state else 16
	toggled.emit(state)
