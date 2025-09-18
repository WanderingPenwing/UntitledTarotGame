extends Node2D

@export var StartCard: Sprite2D
@export var OptionsCard: Sprite2D
@export var CreditsCard: Sprite2D
@export var Menus: Array[Node2D]

var selected: int = 0
var anims: Array[String] =  ["start", "options", "credits"]

func _ready() -> void:
	move(anims[0], true)

func _process(_delta: float) -> void:
	for menu in Menus :
		if menu.visible :
			return
	
	var dir: int = 0
	if Input.is_action_just_pressed("ui_left") :
		dir -= 1
	if Input.is_action_just_pressed("ui_right") :
		dir += 1
	var last_selected = selected
	selected = (selected + dir + 3) % 3
	
	if selected != last_selected : 
		move(anims[last_selected], false)
		move(anims[selected], true)
	
	if Input.is_action_just_pressed("A") :
		Menus[selected].open()


func move(card: String, up: bool) -> void :
	# C'est un peu degueu mais surement temporaire
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if card == "start" and up:
		tween.tween_property(StartCard, "position", Vector2(67, 82), 0.1)
	if card == "start" and not up :
		tween.tween_property(StartCard, "position", Vector2(76, 100), 0.1)
	if card == "options" and up :
		tween.tween_property(OptionsCard, "position", Vector2(57, 70), 0.1)
	if card == "options" and not up :
		tween.tween_property(OptionsCard, "position", Vector2(57, 88), 0.1)
	if card == "credits" and up :
		tween.tween_property(CreditsCard, "position", Vector2(138, 103), 0.1)
	if card == "credits" and not up :
		tween.tween_property(CreditsCard, "position", Vector2(128, 124), 0.1)
