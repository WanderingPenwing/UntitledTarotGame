extends CharacterBody2D

const LOVE_SPEED : float = 10 
const WIN_SOUND : Resource = preload("res://audio/sfx/win2.wav")
const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")

@onready var Player = get_tree().get_first_node_in_group("player")
@onready var Mob = get_tree().get_first_node_in_group("mob")

var dead = false

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	$Heart.hide()
	$Shadow.hide()
	$sprite.material.set_shader_parameter("hurt", false)
	$sprite.material.set_shader_parameter("blind", false)
	if GameState.world_status == GameState.STATUS.LOVE :
		tween.tween_callback($Heart.show)
	if GameState.world_status == GameState.STATUS.ILLUSION :
		tween.tween_callback($sprite.hide)
		tween.parallel().tween_callback($Shadow.show)
	if GameState.world_status == GameState.STATUS.BLIND :
		tween.tween_callback(blind)
	GameUi.FlagSprite = $sprite

func _physics_process(_delta: float) -> void:
	if dead :
		return
	velocity = Vector2(0, 0)
	if GameState.mob_status == GameState.STATUS.LOVE :
		velocity = LOVE_SPEED * position.direction_to(Mob.position)
	if GameState.player_status == GameState.STATUS.LOVE :
		velocity = LOVE_SPEED * position.direction_to(Player.position)
	move_and_slide()

func _on_flag_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or body.position.distance_to(position) > 16 :
		return
	if body.type != body.TYPE.KING :
		return
	# si le joueur touche le drapeau on a gagneeeee
	win()

func win() -> void :
	$particles.emitting = true
	GameState.win()
	SoundManager.play_sound(WIN_SOUND, true)

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
	tween.tween_interval(0.1)
	tween.tween_callback(queue_free)
	SoundManager.play_sound(DEATH_SOUND, true)

func end_blink() -> void :
	$sprite.material.set_shader_parameter("hurt", false)
	

func blind() -> void :
	$sprite.material.set_shader_parameter("blind", true)
