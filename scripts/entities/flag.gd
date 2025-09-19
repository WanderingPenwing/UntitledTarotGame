extends CharacterBody2D

const LOVE_SPEED : float = 10 
const WIN_SOUND : Resource = preload("res://audio/sfx/win2.wav")

@onready var Player = get_tree().get_first_node_in_group("player")
@onready var Mob = get_tree().get_first_node_in_group("mob")


func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	$Heart.hide()
	$Shadow.hide()
	if GameState.world_status == GameState.STATUS.LOVE :
		tween.tween_callback($Heart.show)
	if GameState.world_status == GameState.STATUS.ILLUSION :
		tween.tween_callback($sprite.hide)
		tween.parallel().tween_callback($Shadow.show)
	
	GameUi.FlagSprite = $sprite

func _physics_process(_delta: float) -> void:
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
	GameState.win()
	SoundManager.play_sound(WIN_SOUND, true)
