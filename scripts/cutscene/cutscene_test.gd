extends Node2D
class_name Textbox

const CHAR_READ_RATE  = 0.05

@onready var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
@export var TextBox: Array[Label]
@onready var charbox = $SubViewport/Char
@onready var view = $Sprite2D
@onready var charSprite = $SubViewport/CharacterSprite
@export var dialogue : CutsceneScript
@export var KingSprite : CompressedTexture2D
@export var QueenSprite : CompressedTexture2D
@export var JackSprite : CompressedTexture2D

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

func _ready() -> void:
	for i in dialogue.dialogue:
		text_queue.append(i.line)
	for i in dialogue.dialogue:
		char_queue.append(i.char)
	for i in dialogue.dialogue:
		visual_queue.append(i.visual)


func _process(delta: float) -> void:
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
		State.FINISHED:
			if Input.is_action_just_pressed("A") and text_queue.is_empty():
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
	var written: int = 0
	for i in range(len(TextBox)) :
		TextBox[i].text = next_text.right(
			min(len(next_text)-written, (len(TextBox)-i-1)*30)
		).left(30)
		TextBox[i].visible_characters = 0
		written += len(TextBox[i].text)
	charbox.text = next_char
	change_state(State.READING)
	show_textbox()
	if tween : 
		tween.kill()
		tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in range(len(TextBox)) :
		tween.tween_property(TextBox[i], "visible_characters", len(TextBox[i].text), len(TextBox[i].text)*CHAR_READ_RATE)

	tween.connect("finished", on_tween_finished)

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
