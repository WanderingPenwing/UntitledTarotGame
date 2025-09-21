extends CharacterBody2D

enum TYPE {KING, QUEEN, JACK, WITCH}

const WIN_SOUND : Resource = preload("res://audio/sfx/win2.wav")
const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")
const BLOOD: Resource = preload("res://prefabs/env/blood.tscn")
const SPEED: float = 100
const LOVE_SPEED: float = 10

@onready var Flag = get_tree().get_first_node_in_group("flag")
@onready var Mob = get_tree().get_first_node_in_group("mob")

@export var type : TYPE = TYPE.KING

var chrono = 10.0
var dead = false

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.3)
	$sprite.material.set_shader_parameter("hurt", false)
	$sprite.material.set_shader_parameter("blind", false)
	$Heart.hide()
	$Faith.hide()
	$Stun.hide()
	$Tradition.hide()
	#$Shadow.hide()
	if GameState.player_status == GameState.STATUS.LOVE :
		tween.tween_callback($Heart.show)
	if GameState.player_status == GameState.STATUS.BLIND :
		tween.tween_callback(GameUi.blindness.show)
	if GameState.player_status == GameState.STATUS.CHAOS :
		tween.tween_callback($Stun.show)
	if GameState.player_status == GameState.STATUS.TRADITION :
		tween.tween_callback($Tradition.show)
	if GameState.player_status == GameState.STATUS.FAITH :
		tween.tween_callback($Faith.show)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
	if GameState.player_status == GameState.STATUS.INV_FAITH :
		set_collision_layer_value(5, false)
		set_collision_mask_value(5, false)
	if GameState.player_status == GameState.STATUS.ILLUSION :
		tween.tween_callback($sprite.hide)
		tween.parallel().tween_callback($Shadow.show)
	
	if GameState.player_status == GameState.STATUS.FLIPPED :
		tween.tween_property(self, "scale", Vector2(1, -1), 0.1)
	if GameState.player_status == GameState.STATUS.FOOL :
		var flag = get_tree().get_first_node_in_group("flag")
		var mob = get_tree().get_first_node_in_group("mob")
		var flag_pos = flag.position
		var mob_pos = mob.position
		tween.tween_property(mob, "position", flag_pos, 0.1)
		tween.parallel().tween_property(flag, "position", mob_pos, 0.1)
	
	GameUi.time_label.text = "10"
	GameUi.PlayerSprite = $sprite
	


func _physics_process(delta: float) -> void:
	if dead :
		return
	
	var dir := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	# Inversion des controls
	if GameState.player_status == GameState.STATUS.FLIPPED :
		dir = -dir
	
	if chrono >= 0 :
		chrono -= delta
		GameUi.time_label.text = str(int(ceil(chrono)))
	elif type == TYPE.QUEEN :
		Flag.win()
		GameUi.time_hint.hide()
	
	if GameState.player_status == GameState.STATUS.CHAOS and chrono < 5 :
		$sprite.rotation_degrees = -90
		$Stun.hide()
		return
		
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

func die() -> void :
	if dead :
		return
	dead = true
	$sprite.material.set_shader_parameter("hurt", true)
	get_tree().paused = true
	GameUi.reset_label.show()
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.1)
	tween.tween_callback(end_blink)
	var blood = BLOOD.instantiate()
	blood.position = position + Vector2(0, 3)
	get_parent().add_child(blood)
	blood.emitting = true
	tween.tween_interval(0.1)
	tween.tween_callback(queue_free)
	tween.tween_interval(0.2)
	tween.tween_callback(blood.queue_free)
	SoundManager.play_sound(DEATH_SOUND, true)

func end_blink() -> void :
	$sprite.material.set_shader_parameter("hurt", false)
	
