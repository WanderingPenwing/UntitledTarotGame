extends Node

# Pour eviter d'avoir a les retenir, 
# comme ca je peux utiliser (status == GameState.STATUS_BLINND) 
const STATUS_NORMAL: int = -1
const STATUS_FLIPPED: int = 0
const STATUS_BLIND: int = 1
const STATUS_FROZEN: int = 2

# Une facon de recup une node random et y avoir acces plus tard
@onready var Player: Node = get_tree().get_first_node_in_group("player")
@onready var World: Node = get_tree().get_first_node_in_group("world")
@onready var Mob: Node = get_tree().get_first_node_in_group("mob")

# status par defauts
# en fonction de l'evolution du jeu faudra ptet rendre ca plus extensible q
var player_status = STATUS_NORMAL
var mob_status = STATUS_NORMAL
var world_status = STATUS_NORMAL


func _ready() -> void:
	get_tree().paused = true
	GameUi.draw_tarot_label.show()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("B") and not TarotSelect.visible:
		get_tree().paused = true
		TarotSelect.show()
	
	GameUi.draw_tarot_label.visible = not TarotSelect.visible
	GameUi.start_label.visible = TarotSelect.ContinueLabel.visible and not TarotSelect.visible and get_tree().paused
	
	if get_tree().paused and Input.is_action_just_pressed("A") and not TarotSelect.visible and TarotSelect.ContinueLabel.visible :
		get_tree().paused = false
	
	Player.modulate = Color.AQUA if player_status == STATUS_FROZEN else Color.WHITE
	GameUi.blindness.visible = (player_status == STATUS_BLIND)
	Player.scale.y = -1 if player_status == STATUS_FLIPPED else 1
	
	if world_status == STATUS_FROZEN :
		World.modulate = Color.AQUA 
	elif world_status == STATUS_BLIND :
		World.modulate = Color.BLACK 
	else :
		World.modulate = Color.WHITE
	World.scale.y = -1 if world_status == STATUS_FLIPPED else 1
	
	if mob_status == STATUS_FROZEN :
		Mob.modulate = Color.AQUA 
	elif mob_status == STATUS_BLIND :
		Mob.modulate = Color.BLACK 
	else :
		Mob.modulate = Color.WHITE
	Mob.scale.y = -1 if mob_status == STATUS_FLIPPED else 1

func reset_entities() :
	Player.position = Vector2(40, 40)
	Player.velocity = Vector2(0,0)
	Mob.position = Vector2(112, 72)
	Mob.velocity = Vector2(0,0)
	Mob.target = Vector2(randi_range(0,160), randi_range(0,144))


func win() -> void :
	get_tree().paused = true
	# j'utilise le fait que GameUi est une node globale
	GameUi.win_label.show()
	# a completer avec transition vers les autres niveaux
