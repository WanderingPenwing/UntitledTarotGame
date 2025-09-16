extends CharacterBody2D

const SPEED: float = 100


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


func _physics_process(_delta: float) -> void:
	var dir := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	# Inversion des controls
	if GameState.player_status == GameState.STATUS.FLIPPED :
		dir = -dir
	
	# Si frozen on bouge pas
	if GameState.player_status == GameState.STATUS.FROZEN :
		return
	
	# pour gerer l'effet glace
	var friction: float = 0.01 if GameState.world_status == GameState.STATUS.FROZEN else 0.98
	velocity = lerp(velocity, dir*SPEED, friction)
	
	move_and_slide()
