extends CanvasLayer

const CARD = preload("res://prefabs/menu/tarot_card.tscn")

@export var cards: Array[Texture2D] = []
@export var ContinueLabel : Sprite2D

var slots : Array[Array] = [[null, null, null], [null, null, null]]
var backup_slots : Array[Array] = [[null, null, null], [null, null, null]]
var holding = null
var cursor: Vector2i = Vector2i(0, 1)
var just_visible = false

func _ready() -> void:
	reset()
	hide()

func _process(_delta: float) -> void:
	if not visible :
		just_visible = true
		return
	
	var dir = -int(Input.is_action_just_pressed("ui_left"))+int(Input.is_action_just_pressed("ui_right"))
	if dir != 0 :
		cursor.x = (cursor.x + dir + 3) % 3
		select(cursor)
	
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down")) :
		cursor.y = (cursor.y + 1) % 2
		select(cursor)
	
	restore()
	
	
	if slots[cursor.y][cursor.x] and holding :
		if cursor.x == 0 or (cursor.x == 1 and slots[cursor.y][2] == null) :
			for i in range(len(slots[cursor.y])-1, cursor.x, -1) :
				if not slots[cursor.y][i-1] :
					continue
				slots[cursor.y][i] = slots[cursor.y][i-1]
				move_card(slots[cursor.y][i], Vector2i(i, cursor.y))
		else :
			for i in range(0, cursor.x) :
				if not slots[cursor.y][i+1] :
					continue
				slots[cursor.y][i] = slots[cursor.y][i+1]
				move_card(slots[cursor.y][i], Vector2i(i, cursor.y))
		slots[cursor.y][cursor.x] = null
	
	if Input.is_action_just_pressed("A") :
		if not holding :
			if slots[cursor.y][cursor.x] :
				holding = slots[cursor.y][cursor.x]
				slots[cursor.y][cursor.x] = null
				backup()
				holding.z_index = 1
				cursor = Vector2i(cursor.x, 0)
				select(cursor)
		else :
			slots[cursor.y][cursor.x] = holding
			backup()
			holding.z_index = 0
			holding = null
			move_card(slots[cursor.y][cursor.x], cursor)
			select(cursor)
	
	if (slots[0][0] and slots[0][1] and slots[0][2]) != ContinueLabel.visible :
		update_continue_label(slots[0][0] and slots[0][1] and slots[0][2])
	
	if Input.is_action_just_pressed("B") and ContinueLabel.visible and not just_visible :
		self.hide()
		GameState.player_status = slots[0][0].status_index
		GameState.mob_status = slots[0][1].status_index
		GameState.world_status = slots[0][2].status_index
		GameState.reset_entities()
	
	update_cards()
	just_visible = false

func update_cards() :
	for y in range(2) :
		for x in range(3) :
			if not slots[y][x] : continue
			move_card(slots[y][x],Vector2i(x,y))


func reset() :
	for card in get_tree().get_nodes_in_group("card") :
		card.queue_free()
	slots = [[null, null, null], [null, null, null]]
	for i in range(3) :
		var Card = CARD.instantiate()
		Card.texture = cards[i]
		Card.status_index = i
		move_card(Card, Vector2i(i, 1))
		$view.add_child(Card)
		slots[1][i] = Card
	cursor = Vector2i(0, 1)
	backup()
	select(cursor)


func backup() :
	for y in range(2) :
		for x in range(3) :
			if backup_slots[y][x] == slots[y][x] :
				continue
			backup_slots[y][x] = slots[y][x]

func restore() :
	for y in range(2) :
		for x in range(3) :
			if backup_slots[y][x] == slots[y][x] :
				continue
			slots[y][x] = backup_slots[y][x]

func select(vec: Vector2i) -> void :
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($view/selector, 'position', Vector2(30 + 50 * (vec.x), 54 + 55 * (vec.y) - (10 if holding else 0)), 0.1)
	if holding :
		move_card(holding, vec)

func move_card(card: Sprite2D, vec:Vector2i) -> void :
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(card, 'position', Vector2(30 + 50 * (vec.x), 54 + 55 * (vec.y) - (10 if card == holding else 0)), 0.1)



func update_continue_label(visibility: bool) -> void :
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if visibility :
		ContinueLabel.show()
		ContinueLabel.position.y = 121
		tween.tween_property(ContinueLabel, "position", Vector2(80,72), 0.1)
	else :
		ContinueLabel.position.y = 72
		tween.tween_property(ContinueLabel, "position", Vector2(80,121), 0.1)
		tween.tween_callback(ContinueLabel.hide)
