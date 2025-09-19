extends Node2D

@onready var text = $Line
@onready var background = $SubViewport/Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(text, "position", Vector2(0,-450.0), 60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
