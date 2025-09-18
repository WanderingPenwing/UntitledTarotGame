extends CharacterBody2D

enum TYPE {KING, QUEEN, JACK, WITCH}

const WIN_SOUND : Resource = preload("res://audio/sfx/win2.wav")
const SPEED: float = 100
const LOVE_SPEED: float = 10

@onready var Flag = get_tree().get_first_node_in_group("flag")
@onready var Mob = get_tree().get_first_node_in_group("mob")

@export var type : TYPE = TYPE.KING

var chrono = 10.0


func _ready() -> void:
	if GameState.player_status == GameState.STATUS.FROZEN :
		modulate = Color.PALE_TURQUOISE
	if GameState.player_status == GameState.STATUS.FLIPPED :
		scale.y = -1
	if GameState.player_status == GameState.STATUS.FOOL :
		var flag = get_tree().get_first_node_in_group("flag")
		var mob = get_tree().get_first_node_in_group("mob")
		var flag_pos = flag.position
		flag.position = mob.position
		mob.position = flag_pos
	
	if GameState.player_status == GameState.STATUS.FAITH :
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
	if type == TYPE.QUEEN :
		GameUi.time_hint.show()
	GameUi.time_label.text = "10"
	


func _physics_process(delta: float) -> void:
	var dir := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	# Inversion des controls
	if GameState.player_status == GameState.STATUS.FLIPPED :
		dir = -dir
	
	if chrono >= 0 :
		chrono -= delta
		GameUi.time_label.text = str(int(ceil(chrono)))
	elif type == TYPE.QUEEN :
		GameState.win()
		SoundManager.play_sound(WIN_SOUND, true)
		GameUi.time_hint.hide()
		
	# Si frozen on bouge pas
	if GameState.player_status == GameState.STATUS.FROZEN :
		return
	
	# pour gerer l'effet glace
	var friction: float = 0.01 if GameState.world_status == GameState.STATUS.FROZEN else 0.98
	velocity = lerp(velocity, dir*SPEED, friction)
	
	if GameState.mob_status == GameState.STATUS.LOVE :
		velocity += LOVE_SPEED * position.direction_to(Mob.position)
	if GameState.world_status == GameState.STATUS.LOVE :
		velocity += LOVE_SPEED * position.direction_to(Flag.position)
	
	move_and_slide()
