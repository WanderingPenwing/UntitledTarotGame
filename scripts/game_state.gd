extends Node

enum STATUS {NORMAL, FLIPPED, BLIND, FROZEN, CHARIOT, FOOL}

const SAVE_FILE : String = "user://state.save"
const LEVELS = [
	preload("res://levels/level_k1.tscn"),
	preload("res://levels/level_k2.tscn"),
	preload("res://levels/level_k3.tscn"),
	preload("res://levels/level_k4.tscn")
]

const CUTSCENES = [
	preload("res://prefabs/cutscene/cutscene scene/cutscene_1.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_2.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_3.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_4.tscn")
]

@onready var master_bus : int = AudioServer.get_bus_index("Master")
@onready var sfx_bus : int = AudioServer.get_bus_index("Sfx")
@onready var music_bus : int = AudioServer.get_bus_index("Music")

var volume : Dictionary = {
	"master" : 50,
	"sfx" : 50,
	"music" : 50 
}
# status par defauts
# en fonction de l'evolution du jeu faudra ptet rendre ca plus extensible q
var player_status = STATUS.NORMAL
var mob_status = STATUS.NORMAL
var world_status = STATUS.NORMAL

#Sers a définir le niveau actuel/si ingame ou pas
var level_index = 0
var level_unlocked = 0
var in_game = false

var cutscene_index = 0

func _ready() -> void:
	get_tree().paused = true
	GameUi.draw_tarot_label.show()
	load_state()
	update_volume()


func _process(_delta: float) -> void:
	GameUi.start_label.visible = TarotSelect.ContinueLabel.visible and get_tree().paused and in_game
	
	if Input.is_action_just_pressed("A") and GameUi.win_label.visible :
		level_index = (level_index + 1) % len(LEVELS)
		cutscene_index = (cutscene_index + 1) % len(CUTSCENES)
		GameUi.win_label.hide()
		start_cutscene()
	
	if not in_game : return
	
	# Pour entrer dans le menu selction de tarot
	if Input.is_action_just_pressed("B") and not TarotSelect.visible:
		get_tree().paused = true
		TarotSelect.show()
	
	# Pour lancer le niveau
	if Input.is_action_just_pressed("A") and not TarotSelect.visible and GameUi.start_label.visible :
		get_tree().paused = false
		
	

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
	
	level_unlocked = max(level_index, level_unlocked)
	save_state()
	
	

func start_cutscene() -> void :
	get_tree().change_scene_to_packed(CUTSCENES[cutscene_index])
	get_tree().paused = true


func win() -> void :
	get_tree().paused = true
	GameUi.win_label.show()
	in_game = false
	# a completer avec transition vers les autres niveaux


func update_volume() -> void :
	AudioServer.set_bus_volume_db(master_bus,linear_to_db(volume["master"]/200.0)) # Sound is too loud by default
	AudioServer.set_bus_volume_db(sfx_bus,linear_to_db(volume["sfx"]/100.0))
	AudioServer.set_bus_volume_db(music_bus,linear_to_db(volume["music"]/100.0))


func save_state() -> void :
	var save_dict := { # Here you can put other variable to save
		"volume" : volume,
		"level_unlocked" : level_unlocked
	}
	var save_game := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	var json_string := JSON.stringify(save_dict)
	save_game.store_line(json_string)
	print("saved state")


func load_state() -> void :
	print("loading state")
	if not FileAccess.file_exists(SAVE_FILE) :
		print("x : no save file")
		return
	var state_file : FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	
	var json_string : String = state_file.get_line()
	var json : JSON = JSON.new()
	var _parse_result : Error = json.parse(json_string)
	var state_data : Dictionary = json.get_data()
	if not state_data :
		print("x : no state_data")
		return
		
	if "volume" in state_data :
		volume = state_data["volume"]
	if "level_unlocked" in state_data  :
		level_unlocked = state_data["level_unlocked"]
