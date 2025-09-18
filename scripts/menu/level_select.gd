extends Node2D

const BIP_SOUND: Resource = preload("res://audio/sfx/tarot_check.wav")
const LEVEL_PLACEHOLDER: Resource = preload("res://prefabs/menu/level_placeholder.tscn")

var lines = [4, 4, 4, 1]
var selected = Vector2i(0, 0)
var just_visible = false

func _ready() -> void:
	self.hide()
	self.position.y = 100
	update_levels()


func _process(_delta: float) -> void:
	if not visible :
		just_visible = true
		return
	var dir = Vector2i(0, 0)
	
	dir.x -= 1 if Input.is_action_just_pressed("ui_left") else 0
	dir.x += 1 if Input.is_action_just_pressed("ui_right") else 0
	dir.y -= 1 if Input.is_action_just_pressed("ui_up") else 0
	dir.y += 1 if Input.is_action_just_pressed("ui_down") else 0
	
	selected.x = (selected.x + dir.x)
	selected.y = (selected.y + dir.y + len(lines)) % len(lines)
	
	selected.x = (selected.x + lines[selected.y]) % lines[selected.y] if dir.x != 0 else min(lines[selected.y]-1, selected.x)
	
	$selector.position = get_pos(selected)
	
	if Input.is_action_just_pressed("A") and not just_visible :
		GameState.level_index = selected.y*4+selected.x
		GameState.cutscene_index = GameState.level_index % len(GameState.CUTSCENES)
		GameState.start_cutscene()
	
	just_visible = false

func update_levels() -> void:
	lines = []
	for y in range(3) :
		var unlocked = 0
		for x in range(4) :
			if y*4+x < GameState.level_unlocked + 1 :
				unlocked += 1
				continue
			var PlaceHolder = LEVEL_PLACEHOLDER.instantiate()
			PlaceHolder.position = get_pos(Vector2i(x, y))
			add_child(PlaceHolder)
		if unlocked != 0 :
			lines.append(unlocked)

	if GameState.level_unlocked + 1 == 13 :
		$Level13.show()
		lines.append(1)

func get_pos(vec: Vector2i) -> Vector2 :
	if vec.y == 3 :
		return Vector2(80, 134) 
	return Vector2(vec.x*22+47, vec.y*22+69) 

func open() -> void:
	show()
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 0), 0.1)
	selected = Vector2i(0,0)


func close() -> void:
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(0, 100), 0.1)
	tween.tween_callback(hide)
