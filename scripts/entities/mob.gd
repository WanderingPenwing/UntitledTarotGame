extends CharacterBody2D

const SPEED: float = 60
const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")
const BLOOD: Resource = preload("res://prefabs/env/blood.tscn")

# Une facon de recup une node random et y avoir acces plus tard
@onready var Player = get_tree().get_first_node_in_group("player")
@onready var Flag = get_tree().get_first_node_in_group("flag")

# pour controler le mouvement du mob
var target: Vector2 = Vector2(80, 72)
var dead: bool = false

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.6)
	$sprite.material.set_shader_parameter("active", false)
	$Heart.hide()
	$Faith.hide()
	$Stun.hide()
	$Tradition.hide()
	#$Shadow.hide()
	if GameState.mob_status == GameState.STATUS.LOVE :
		tween.tween_callback($Heart.show)
	if GameState.mob_status == GameState.STATUS.CHAOS :
		tween.tween_callback($Stun.show)
	if GameState.mob_status == GameState.STATUS.TRADITION :
		tween.tween_callback($Tradition.show)
	if GameState.mob_status == GameState.STATUS.FAITH :
		tween.tween_callback($Faith.show)
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
	if GameState.mob_status == GameState.STATUS.ILLUSION :
		tween.tween_callback($sprite.hide)
		tween.parallel().tween_callback($Shadow.show)
	
	if GameState.mob_status == GameState.STATUS.FLIPPED :
		tween.tween_property(self, "scale", Vector2(1, -1), 0.1)
	if GameState.mob_status == GameState.STATUS.FOOL :
		var flag = get_tree().get_first_node_in_group("flag")
		var flag_pos = flag.position
		var player_pos = Player.position
		tween.tween_property(flag, "position", player_pos, 0.1)
		tween.parallel().tween_property(Player, "position", flag_pos, 0.1)
	
	GameUi.MobSprite = $sprite


func _physics_process(_delta: float) -> void:
	if dead :
		return
	# si le mob est freeze
	if GameState.mob_status == GameState.STATUS.FROZEN :
		return
	
	# choix de la cible
	if GameState.mob_status != GameState.STATUS.BLIND and Player.type == Player.TYPE.KING :
		target = Player.position
	
	if Player.type == Player.TYPE.JACK :
		if GameState.world_status == GameState.STATUS.LOVE :
			target = Flag.position
		else :
			target = Player.position
	
	if Player.type == Player.TYPE.QUEEN :
		if GameState.world_status != GameState.STATUS.ILLUSION and GameState.mob_status != GameState.STATUS.TRADITION :
			target = Flag.position
		elif GameState.player_status != GameState.STATUS.ILLUSION :
			target = Player.position
	
	if GameState.mob_status == GameState.STATUS.CHAOS :
		target = position + Vector2(10,0).rotated(-Player.chrono * 4)
	
	var dir = (target - position).normalized()
	# Inversion des controls
	if GameState.mob_status == GameState.STATUS.FLIPPED :
		dir = -dir
	
	if position.distance_to(target) < 5 :
		dir = Vector2(0, 0)
	
	# pour gerer l'effet glace
	var friction = 0.05 if GameState.world_status == GameState.STATUS.FROZEN else 0.98
	velocity = lerp(velocity, dir*SPEED, friction)
	
	for body in $detect.get_overlapping_bodies() :
		if body.position.distance_to(position) > 10 :
			continue
		if body.is_in_group("flag") or (body.is_in_group("player") and not GameState.player_status == GameState.STATUS.TRADITION) :
			body.die()
	
	move_and_slide()

func die() :
	if dead :
		return
	dead = true
	$sprite.material.set_shader_parameter("active", true)
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.1)
	tween.tween_callback(finish)
	var blood = BLOOD.instantiate()
	blood.position = position + Vector2(0, 3)
	get_parent().add_child(blood)
	blood.emitting = true
	tween.tween_interval(0.2)
	tween.tween_callback(blood.queue_free)

func finish() :
	if Player.type == Player.TYPE.JACK :
		Flag.win()
	queue_free()
