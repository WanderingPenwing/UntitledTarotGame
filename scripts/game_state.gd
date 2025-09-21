extends Node

enum STATUS {NORMAL, FLIPPED, BLIND, FROZEN, CHARIOT, FOOL, LOVE, FAITH, TRADITION, CHAOS, ILLUSION, INV_FAITH, DEATH}

const SAVE_FILE : String = "user://state.save"
const LEVELS = [
	preload("res://levels/level_k1.tscn"),
	preload("res://levels/level_k2.tscn"),
	preload("res://levels/level_k3.tscn"),
	preload("res://levels/level_k4.tscn"),
	preload("res://levels/level_q1.tscn"),
	preload("res://levels/level_q2.tscn"),
	preload("res://levels/level_q3.tscn"),
	preload("res://levels/level_q4.tscn"),
	preload("res://levels/level_j1.tscn"),
	preload("res://levels/level_j2.tscn"),
	preload("res://levels/level_j3.tscn"),
	preload("res://levels/level_j4.tscn"),
	preload("res://levels/level_w1.tscn")
]

const CUTSCENES = [
	preload("res://prefabs/cutscene/cutscene scene/cutscene_start.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_1.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_2.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_3.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_4.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_5.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_6.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_7.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_8.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_9.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_10.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_11.tscn"),
	preload("res://prefabs/cutscene/cutscene scene/cutscene_12.tscn")
]
const BIP_SOUND: Resource = preload("res://audio/sfx/tarot_check.wav")
const LOW_SHUFFLE_SOUND = preload("res://audio/sfx/carte_low.wav")

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
var level_index = 12
var level_unlocked = 0
var in_game = false

var cutscene_index = 0
var anim_pause = 0

func _ready() -> void:
	get_tree().paused = true
	GameUi.draw_tarot_label.show()
	load_state()
	update_volume()
	#start_level()


func _process(delta: float) -> void:
	if anim_pause > 0 :
		anim_pause -= delta
	
	if Input.is_action_just_pressed("A") and GameUi.win_label.visible :
		level_index = (level_index + 1) % len(LEVELS)
		cutscene_index = (cutscene_index + 1) % len(CUTSCENES)
		GameUi.win_label.hide()
		start_cutscene()
		SoundManager.play_sound(BIP_SOUND, true)
	
	if Input.is_action_just_pressed("B") and GameUi.win_label.visible :
		SoundManager.play_sound(BIP_SOUND, true)
		reset_level()
		in_game = true
	
	if not in_game : return
	
	# Pour entrer dans le menu selction de tarot
	if Input.is_action_just_pressed("B") and not TarotSelect.visible:
		get_tree().paused = true
		TarotSelect.show()
		GameUi.start_label.hide()
		SoundManager.play_sound(LOW_SHUFFLE_SOUND, true)
	
	# Pour lancer le niveau
	if Input.is_action_just_pressed("A") and GameUi.start_label.visible :
		get_tree().paused = false
		GameUi.start_label.hide()
		var player = get_tree().get_first_node_in_group("player")
		if player.type == player.TYPE.QUEEN :
			GameUi.time_hint.show()
		SoundManager.play_sound(BIP_SOUND, true)
		
	
	if Input.is_action_just_pressed("A") and GameUi.reset_label.visible :
		reset_level()
		SoundManager.play_sound(BIP_SOUND, true)
		
	

func reset_level() -> void :
	get_tree().change_scene_to_packed(LEVELS[level_index])
	get_tree().paused = true
	GameUi.reset_ui()
	GameUi.level_index.region_rect.position.x = level_index * 16
	GameUi.level_index.show()
	GameUi.level_type.show()
	if level_index % 4 == 0 :
		GameUi.objectives_hints[level_index/4].show()
	anim_pause = 1.0
	if not TarotSelect.ContinueLabel.visible :
		return
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(1.0)
	tween.tween_callback(GameUi.show_start)

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
	player_status = STATUS.NORMAL
	mob_status = STATUS.NORMAL
	world_status = STATUS.NORMAL
	GameUi.reset_ui()
	get_tree().change_scene_to_packed(CUTSCENES[cutscene_index])
	get_tree().paused = true


func win() -> void :
	get_tree().paused = true
	GameUi.win_label.show()
	GameUi.blindness.hide()
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
