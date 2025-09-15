extends Node

# Pour eviter d'avoir a les retenir, 
# comme ca je peux utiliser (status == GameState.STATUS_BLINND) 
const STATUS_NORMAL: int = -1
const STATUS_FLIPPED: int = 0
const STATUS_BLIND: int = 1
const STATUS_FROZEN: int = 2

const LEVELS = [
	preload("res://levels/level_0.tscn")
]

# status par defauts
# en fonction de l'evolution du jeu faudra ptet rendre ca plus extensible q
var player_status = STATUS_NORMAL
var mob_status = STATUS_NORMAL
var world_status = STATUS_NORMAL

var current_level = 0

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
	

func reset_level() :
	get_tree().change_scene_to_packed(LEVELS[current_level])
	GameUi.win_label.hide()


func win() -> void :
	get_tree().paused = true
	GameUi.win_label.show()
	# a completer avec transition vers les autres niveaux
