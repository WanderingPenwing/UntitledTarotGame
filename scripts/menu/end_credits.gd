extends Node2D

@onready var text = $Line
@onready var background = $SubViewport/Background

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(text, "position", Vector2(0,-450.0), 60)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("B"):
		get_tree().change_scene_to_file("res://prefabs/menu/start_menu.tscn")
