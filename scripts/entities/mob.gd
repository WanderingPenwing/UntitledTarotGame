extends CharacterBody2D

const SPEED: float = 10

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


func _process(_delta: float) -> void:
	# si le mob est freeze
	if GameState.mob_status == GameState.STATUS.FROZEN :
		return
	
	# si le mob est pas aveugle on target le joueur
	if GameState.mob_status != GameState.STATUS.BLIND :
		target = Player.position
	
	var dir = (target - position).normalized()
	
	# pour gerer l'effet glace
	var friction = 0.01 if GameState.world_status == GameState.STATUS.FROZEN else 0.98
	velocity = lerp(velocity, dir*SPEED, friction)
	
	move_and_slide()
