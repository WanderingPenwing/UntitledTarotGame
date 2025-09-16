extends Node2D

const BIP_SOUND: Resource = preload("res://audio/sfx/tarot_check.wav")

@onready var buttons = [[$MusicDec, $MusicInc], [$SfxDec, $SfxInc], [$Back]]
@onready var master_bus : int = AudioServer.get_bus_index("Master")
@onready var sfx_bus : int = AudioServer.get_bus_index("Sfx")
@onready var music_bus : int = AudioServer.get_bus_index("Music")

var selected = Vector2i(0, 0)

func _ready() -> void:
	self.hide()
	self.position.y = 80
	update_buttons()


func _process(_delta: float) -> void:
	if not visible :
		return
	
	if Input.is_action_just_pressed("ui_left") :
		selected.x = (selected.x - 1 + len(buttons[selected.y])) % len(buttons[selected.y])
	if Input.is_action_just_pressed("ui_right") :
		selected.x = (selected.x + 1 + len(buttons[selected.y])) % len(buttons[selected.y])
	if Input.is_action_just_pressed("ui_up") :
		selected.y = (selected.y - 1 + len(buttons)) % len(buttons)
		selected.x = selected.x % len(buttons[selected.y])
	if Input.is_action_just_pressed("ui_down") :
		selected.y = (selected.y + 1 + len(buttons)) % len(buttons)
		selected.x = selected.x % len(buttons[selected.y])
	
	if Input.is_action_just_pressed("A") :
		print(selected)
		GameState.update_volume()
		if buttons[selected.y][selected.x] == $MusicDec :
			GameState.volume["music"] -= 10
		if buttons[selected.y][selected.x] == $MusicInc :
			GameState.volume["music"] += 10
		if buttons[selected.y][selected.x] == $SfxDec :
			GameState.volume["sfx"] -= 10
		if buttons[selected.y][selected.x] == $SfxInc :
			GameState.volume["sfx"] += 10
		if buttons[selected.y][selected.x] == $Back :
			close()
			GameState.save_state()
		SoundManager.play_sound(BIP_SOUND, true)
	
	update_buttons()
	update_bars()


func update_buttons() -> void:
	for y in range(len(buttons)) :
		for x in range(len(buttons[y])) : 
			buttons[y][x].visible = (Vector2i(x, y) == selected)


func update_bars() -> void :
	$MusicVolume.value = GameState.volume["music"]
	$SfxVolume.value = GameState.volume["sfx"]


func open() -> void:
	show()
	print("open")
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 0), 0.1)
	selected = Vector2i(0,0)


func close() -> void:
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 80), 0.1)
	tween.tween_callback(hide)
