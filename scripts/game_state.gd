extends Node

enum STATUS {NORMAL, FLIPPED, BLIND, FROZEN}

const LEVELS = [
	preload("res://levels/level_0.tscn"),
	preload("res://levels/level_0b.tscn")
]

# status par defauts
# en fonction de l'evolution du jeu faudra ptet rendre ca plus extensible q
var player_status = STATUS.NORMAL
var mob_status = STATUS.NORMAL
var world_status = STATUS.NORMAL


var level_index = 0

func _ready() -> void:
	get_tree().paused = true
	GameUi.draw_tarot_label.show()


func _process(_delta: float) -> void:
	# Pour entrer dans le menu selction de tarot
	if Input.is_action_just_pressed("B") and not TarotSelect.visible:
		get_tree().paused = true
		TarotSelect.show()

	GameUi.start_label.visible = TarotSelect.ContinueLabel.visible and get_tree().paused
	
	# Pour lancer le niveau
	if Input.is_action_just_pressed("A") and not TarotSelect.visible and GameUi.start_label.visible :
		get_tree().paused = false
		
	if Input.is_action_just_pressed("A") and GameUi.win_label.visible :
		level_index = (level_index + 1) % len(LEVELS)
		reset_level()
		player_status = STATUS.NORMAL
		mob_status = STATUS.NORMAL
		world_status = STATUS.NORMAL
		var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_callback(TarotSelect.reset)
	

func reset_level() :
	get_tree().change_scene_to_packed(LEVELS[level_index])
	get_tree().paused = true
	GameUi.win_label.hide()


func win() -> void :
	get_tree().paused = true
	GameUi.win_label.show()
	# a completer avec transition vers les autres niveaux
