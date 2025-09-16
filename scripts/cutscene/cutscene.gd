extends Node2D
class_name Textbox

const CHAR_READ_RATE  = 0.05

@onready var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
@onready var textbox = $SubViewport/Label
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in dialogue.dialogue:
		text_queue.append(i.line)
	for i in dialogue.dialogue:
		char_queue.append(i.char)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("A"):
				textbox.visible_characters = -1
				tween.stop()
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("A") and text_queue.is_empty():
				change_state(State.OVER)
				hide_textbox()
			elif Input.is_action_just_pressed("A") and !text_queue.is_empty():
				change_state(State.READY)
		State.OVER:
			hide_textbox()

func hide_textbox():
	textbox.text = ""
	self.visible = false

func show_textbox():
	self.visible = true

func display_text():
	var next_text = text_queue.pop_front()
	var next_char = char_queue.pop_front()
	textbox.text = next_text
	change_state(State.READING)
	show_textbox()
	if tween : 
		tween.kill()
		tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(textbox, "visible_characters", len(next_text), len(next_text)*CHAR_READ_RATE).from(0).finished
	tween.connect("finished", on_tween_finished)

func on_tween_finished():
	change_state(State.FINISHED)

func change_state(next_state):
	current_state = next_state
