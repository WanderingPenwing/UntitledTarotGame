extends StaticBody2D

@export var ActionButton: Area2D

func _ready() -> void:
	ActionButton.connect("toggled", toggled)

func toggled(state: bool) -> void :
	$sprite.region_rect.position.x = 48 if state else 32
	set_collision_layer_value(1, not state)
