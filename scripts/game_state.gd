extends Node

enum STATUS {NORMAL, FLIPPED, BLIND, FROZEN, CHARIOT, FOOL}

const LEVELS = [
	preload("res://levels/level_p1.tscn"),
	preload("res://levels/level_p2.tscn"),
	preload("res://levels/level_p3.tscn"),
	preload("res://levels/level_p4.tscn")
]

# status par defauts
# en fonction de l'evolution du jeu faudra ptet rendre ca plus extensible q
var player_status = STATUS.NORMAL
var mob_status = STATUS.NORMAL
var world_status = STATUS.NORMAL


var level_index = 0
var in_game = false

func _ready() -> void:
	get_tree().paused = true
	GameUi.draw_tarot_label.show()


func _process(_delta: float) -> void:
	GameUi.start_label.visible = TarotSelect.ContinueLabel.visible and get_tree().paused
	
	if not in_game : return
	
	# Pour entrer dans le menu selction de tarot
	if Input.is_action_just_pressed("B") and not TarotSelect.visible:
		get_tree().paused = true
		TarotSelect.show()
	
	# Pour lancer le niveau
	if Input.is_action_just_pressed("A") and not TarotSelect.visible and GameUi.start_label.visible :
		get_tree().paused = false
		
	if Input.is_action_just_pressed("A") and GameUi.win_label.visible :
		level_index = (level_index + 1) % len(LEVELS)
		start_level()
	

func reset_level() -> void :
	get_tree().change_scene_to_packed(LEVELS[level_index])
	get_tree().paused = true
	GameUi.win_label.hide()

func start_level() -> void :
	reset_level()
	player_status = STATUS.NORMAL
	mob_status = STATUS.NORMAL
	world_status = STATUS.NORMAL
	TarotSelect.ContinueLabel.visible = false
	
	# magie noire pour attendre que le level soit bien charge avant de faire le tirage
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_callback(TarotSelect.reset)
	in_game = true
	SoundManager.update_music()

func win() -> void :
	get_tree().paused = true
	GameUi.win_label.show()
	# a completer avec transition vers les autres niveaux
