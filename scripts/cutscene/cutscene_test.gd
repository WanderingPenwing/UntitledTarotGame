extends Node2D
class_name Textbox

const TALK_SOUND = preload("res://audio/sfx/discussion.wav")
const CHAR_READ_RATE  = 0.05

@onready var tween = get_tree().create_tween()
@export var TextBox: Array[Label]
@onready var charbox = $SubViewport/Char
@onready var view = $Sprite2D
@onready var charSprite = $SubViewport/CharacterSprite
@onready var query1 = $SubViewport/Query1
@onready var query2 = $SubViewport/Query2
@onready var cutscenebadend = preload("res://prefabs/cutscene/cutscene scene/cutscene_badend.tscn")
@onready var keyartbadend = preload("res://prefabs/cutscene/cutscene scene/badend_keyart.tscn")
@onready var keyartgoodend = preload("res://prefabs/cutscene/cutscene scene/goodend_keyart.tscn")
@export var dialogue : CutsceneScript
@export var KingSprite : CompressedTexture2D
@export var QueenSprite : CompressedTexture2D
@export var JackSprite : CompressedTexture2D
var isChoosing = false

enum State {
	READY,
	READING,
	CHOOSING,
	FINISHED,
	OVER
}

enum Sprite {
	NONE,
	KING,
	QUEEN,
	JACK
}

@onready var current_state = State.READY
@onready var current_sprite = Sprite.NONE
@onready var text_queue : Array 
@onready var char_queue : Array
@onready var visual_queue : Array

var visible_count = []

func _ready() -> void:
	for i in dialogue.dialogue:
		text_queue.append(i.line)
	for i in dialogue.dialogue:
		char_queue.append(i.char)
	for i in dialogue.dialogue:
		visual_queue.append(i.visual)
	# pour virer l'erreur de la console
	tween.tween_callback(print)


func _process(_delta: float) -> void:
	print(current_state)
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			#ça permet de skip le tween si t'es pressé et de juste passer a la suite, fyi
			if Input.is_action_just_pressed("A"):
				for line in TextBox :
					line.visible_characters = -1
				tween.stop()
				change_state(State.FINISHED)
			
			for line_index in range(len(TextBox)) :
				if visible_count[line_index] == TextBox[line_index].visible_characters :
					continue
				visible_count[line_index] = TextBox[line_index].visible_characters
				if visible_count[line_index] == -1 :
					continue
				if not TextBox[line_index].text[visible_count[line_index] - 1] in " ;:.,!?" :
					SoundManager.play_sound(TALK_SOUND, true)
		State.CHOOSING:
			if Input.is_action_just_pressed("A"):
				pass #envoie vers le niveau 13
			elif Input.is_action_just_pressed("B"):
				get_tree().change_scene_to_packed(cutscenebadend)
		State.FINISHED:
			if isChoosing == true :
				current_state = State.CHOOSING
				return
			elif Input.is_action_just_pressed("A") and text_queue.is_empty():
				sprite_change()
				change_state(State.OVER)
				fade_out()
			elif Input.is_action_just_pressed("A") and !text_queue.is_empty():
				sprite_change()
				change_state(State.READY)
		State.OVER:
			GameState.start_level()
	
	match current_sprite:
		Sprite.NONE:
			charSprite.texture = null
		Sprite.KING:
			charSprite.texture = KingSprite
		Sprite.QUEEN:
			charSprite.texture = QueenSprite
		Sprite.JACK:
			charSprite.texture = JackSprite

func hide_textbox():
	for line in TextBox :
		line.text = ""
	charbox.text = ""
	self.visible = false
	change_state(State.OVER)

func show_textbox():
	self.visible = true

func display_text():
	var next_text: String = text_queue.pop_front()
	var next_char: String = char_queue.pop_front()
	for i in range(len(TextBox)) :
		TextBox[i].text = get_line(next_text, i)
		TextBox[i].visible_characters = 0
	charbox.text = next_char
	change_state(State.READING)
	show_textbox()
	if tween : 
		tween.kill()
		tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in range(len(TextBox)) :
		tween.tween_property(TextBox[i], "visible_characters", len(TextBox[i].text), len(TextBox[i].text)*CHAR_READ_RATE)
	tween.connect("finished", on_tween_finished)
	visible_count = [0, 0, 0]

func get_line(text: String, line:int) -> String :
	# justification
	const LINE_LENGTH = 140
	var offsets = [0]
	
	# On va compter les lignes jusqu a celle que l'on veut, puis on prend la derniere
	for index_line in range(line+1) :
		# on stocke le dernier espace vu, pour decouper a cet endroit
		var last_space = -1
		var length_px = 0
		var index_char = 0
		# on continue a lire le texte tant que la ligne est pas trop longue
		# ou qu on est a la fin du texte
		while length_px < LINE_LENGTH and offsets[-1]+index_char < len(text):
			var c = text.substr(offsets[-1]+index_char, 1)
			# tous les caracteres ne font pas la meme taille en pixels
			if c == " " :
				last_space = index_char
				length_px += 5
			elif c in "lj" :
				length_px += 3
			elif c in "i.,:;!" :
				length_px += 2
			elif c in "mMwW" :
				length_px += 6
			else :
				length_px += 4
			index_char += 1
		
		# si on a trouve aucun espace ou que la ligne est pas finie on coupe a la fin
		if last_space == -1 or length_px < LINE_LENGTH : last_space = index_char - 1
		# offset contient les fin de lignes successives
		offsets.append(offsets[-1] + last_space + 1)
	#on renvoie le texte entre la fin de la derniere ligne trouve et l'avant derniere
	return text.substr(offsets[-2], offsets[-1] - offsets[-2])

func sprite_change():
	var next_sprite = visual_queue.pop_front()
	if next_sprite :
		if next_sprite == "King":
			change_sprite(Sprite.KING)
		elif next_sprite == "Queen":
			change_sprite(Sprite.QUEEN)
		elif next_sprite == "Jack":
			change_sprite(Sprite.JACK)
		elif next_sprite == "void":
			change_sprite(Sprite.NONE)
		elif next_sprite == "query":
			query()
		elif next_sprite == "badend":
			badend()

func on_tween_finished():
	change_state(State.FINISHED)

func fade_out():
	await get_tree().create_timer(0.4, true).timeout
	view.self_modulate = Color(189, 189, 189, 255)
	await get_tree().create_timer(0.4, true).timeout
	view.self_modulate = Color(108, 108, 108, 255)
	await get_tree().create_timer(0.4, true).timeout
	view.self_modulate = Color(42, 42, 42, 255)
	await get_tree().create_timer(0.4,true).timeout
	view.self_modulate = Color(0, 0, 0, 255)
	await get_tree().create_timer(0.4,true).timeout
	hide_textbox()

func change_state(next_state):
	current_state = next_state

func change_sprite(next_state):
	current_sprite = next_state

func query():
	isChoosing = true
	query1.show()
	query2.show()
	
func badend():
	get_tree().change_scene_to_packed(keyartbadend)
