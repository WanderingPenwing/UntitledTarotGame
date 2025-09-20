extends TileMapLayer

const WATER = Vector2i(3, 0)
const ICE = Vector2i(3, 1)
const BRIDGE_V = Vector2i(2, 3)
const BRIDGE_H = Vector2i(3, 3)

const EXPLOSION = preload("res://prefabs/env/explosion.tscn")
const EXPLOSION_SOUND = preload("res://audio/sfx/explosion.wav")

func _ready() -> void:
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.9)
	
	if GameState.world_status == GameState.STATUS.FROZEN :
		tween.tween_callback(freeze)
	if GameState.world_status == GameState.STATUS.CHAOS :
		tween.tween_callback(collapse)
	$Blind.hide()
	if GameState.world_status == GameState.STATUS.BLIND :
		tween.tween_callback($Blind.show)
	
	if GameState.world_status == GameState.STATUS.FOOL :
		var mob = get_tree().get_first_node_in_group("mob")
		var player = get_tree().get_first_node_in_group("player")
		var mob_pos = mob.position
		var player_pos = player.position
		tween.tween_property(mob, "position", player_pos, 0.1)
		tween.parallel().tween_property(player, "position", mob_pos, 0.1)

func freeze() -> void :
	for x in range(0, 9) :
		for y in range(0, 8) :
			if get_cell_atlas_coords(Vector2i(x,y)) == WATER or get_cell_source_id(Vector2i(x,y)) == 2 :
				set_cell(Vector2i(x,y), 0, ICE)
	GameUi.snow.emitting = true

func collapse() -> void :
	for x in range(0, 9) :
		for y in range(0, 8) :
			var cell = get_cell_atlas_coords(Vector2i(x,y))
			if not(cell == BRIDGE_V or cell == BRIDGE_H) :
				continue
			set_cell(Vector2i(x,y), 0, WATER)
			explode(map_to_local(Vector2i(x,y)))
	
	for prop in get_tree().get_nodes_in_group("prop") :
		if prop.is_in_group("door") :
			var door_pos = local_to_map(prop.position)
			set_cell(door_pos, 0, Vector2(1,0))
		prop.queue_free()
		explode(prop.position)
	SoundManager.play_sound(EXPLOSION_SOUND)

func explode(pos: Vector2) -> void :
	var explosion = EXPLOSION.instantiate()
	explosion.position = pos
	add_child(explosion)
	explosion.emitting = true
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.4)
	tween.tween_callback(explosion.queue_free)
