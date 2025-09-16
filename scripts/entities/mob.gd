extends CharacterBody2D

const SPEED: float = 80
const DEATH_SOUND: Resource = preload("res://audio/sfx/death.wav")

# Une facon de recup une node random et y avoir acces plus tard
@onready var Player = get_tree().get_first_node_in_group("player")

# pour controler le mouvement du mob
var target: Vector2 = Vector2(randi_range(0,160), randi_range(0,144))


func _ready() -> void:
	if GameState.mob_status == GameState.STATUS.FROZEN :
		modulate = Color.PALE_TURQUOISE
	elif GameState.mob_status == GameState.STATUS.BLIND :
		modulate = Color.BLACK 
	if GameState.mob_status == GameState.STATUS.FLIPPED :
		scale.y = -1
	if GameState.mob_status == GameState.STATUS.FOOL :
		var flag = get_tree().get_first_node_in_group("flag")
		var flag_pos = flag.position
		var player_pos = Player.position
		Player.position = Vector2(-100, -100)
		flag.position = player_pos
		Player.position = flag_pos


func _process(_delta: float) -> void:
	# si le mob est freeze
	if GameState.mob_status == GameState.STATUS.FROZEN :
		return
	
	# si le mob est pas aveugle on target le joueur
	if GameState.mob_status != GameState.STATUS.BLIND :
		target = Player.position
	
	var dir = (target - position).normalized()
	# Inversion des controls
	if GameState.mob_status == GameState.STATUS.FLIPPED :
		dir = -dir
	
	# pour gerer l'effet glace
	var friction = 0.05 if GameState.world_status == GameState.STATUS.FROZEN else 0.98
	velocity = lerp(velocity, dir*SPEED, friction)
	
	for body in $detect.get_overlapping_bodies() :
		if not body.is_in_group("player") :
			continue
		get_tree().paused = true
		GameState.call_deferred("reset_level")
		SoundManager.play_sound(DEATH_SOUND, true)
	
	move_and_slide()


#func _on_detect_body_entered(body: Node2D) -> void:
	#if not body.is_in_group("player") or body.position.distance_to(position) > 16:
		#return
	#get_tree().paused = true
	#GameState.call_deferred("reset_level")
	#SoundManager.play_sound(DEATH_SOUND, true)
