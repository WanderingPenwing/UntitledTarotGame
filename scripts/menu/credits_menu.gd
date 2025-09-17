extends Node2D

const BIP_SOUND: Resource = preload("res://audio/sfx/tarot_check.wav")

var just_visible = false

func _ready() -> void:
	self.hide()
	self.position.y = 80


func _process(_delta: float) -> void:
	if not visible :
		just_visible = true
		return
	
	if Input.is_action_just_pressed("A") and not just_visible :
		close()
		SoundManager.play_sound(BIP_SOUND, true)
	just_visible = false


func open() -> void:
	show()
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 0), 0.1)


func close() -> void:
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 80), 0.1)
	tween.tween_callback(hide)
