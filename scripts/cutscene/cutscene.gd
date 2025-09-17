extends Node2D
class_name TextboxOld

const CHAR_READ_RATE  = 0.05

@onready var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
@onready var textbox = $SubViewport/Text
@onready var charbox = $SubViewport/Char
@onready var view = $Sprite2D
@export var dialogue : CutsceneScript

enum State {
	READY,
	READING,
	CHOOSING,
	FINISHED,
	OVER
}

@onready var current_state = State.READY
@onready var text_queue : Array 
@onready var char_queue : Array

func _ready() -> void:
	for i in dialogue.dialogue:
		text_queue.append(i.line)
	for i in dialogue.dialogue:
		char_queue.append(i.char)


func _process(delta: float) -> void:
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			#ça permet de skip le tween si t'es pressé et de juste passer a la suite, fyi
			if Input.is_action_just_pressed("A"):
				textbox.visible_characters = -1
				tween.stop()
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("A") and text_queue.is_empty():
				change_state(State.OVER)
				fade_out()
			elif Input.is_action_just_pressed("A") and !text_queue.is_empty():
				change_state(State.READY)
		State.OVER:
			GameState.start_level()

func hide_textbox():
	textbox.text = ""
	charbox.text = ""
	self.visible = false
	change_state(State.OVER)

func show_textbox():
	self.visible = true

func display_text():
	var next_text = text_queue.pop_front()
	var next_char = char_queue.pop_front()
	textbox.text = next_text
	charbox.text = next_char
	change_state(State.READING)
	show_textbox()
	if tween : 
		tween.kill()
		tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(textbox, "visible_characters", len(next_text), len(next_text)*CHAR_READ_RATE).from(0).finished
	tween.connect("finished", on_tween_finished)

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
