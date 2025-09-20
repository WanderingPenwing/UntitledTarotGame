extends CanvasLayer

const TAROT_CHECK_SOUND: Resource = preload("res://audio/sfx/validate.wav")
const PICK_UP_SOUND: Resource = preload("res://audio/sfx/place.wav")
const SHUFFLE_SOUND = preload("res://audio/sfx/carte.wav")
const LOW_SHUFFLE_SOUND = preload("res://audio/sfx/carte_low.wav")
const BIP_SOUND: Resource = preload("res://audio/sfx/tarot_check.wav")

@export var ContinueLabel : Sprite2D
@export var HintCards : Node2D
@export var HintControl : Node2D

var slots : Array[Array] = [[null, null, null], [null, null, null]]
var backup_slots : Array[Array] = [[null, null, null], [null, null, null]]
var holding = null
var cursor: Vector2i = Vector2i(0, 1)
var just_visible = false


func _ready() -> void:
	reset()
	hide()
	if GameState.level_unlocked > 0 :
		HintControl.hide()
	ContinueLabel.hide()


func _process(_delta: float) -> void:
	if not GameState.in_game : return
	if not visible :
		# cette idee de just_visible c'est a cause de Input.is_action_just_pressed :
		# Si on est en jeu, on appuie sur B et ca affiche le tarot_select, la frame est pas terminee
		# Donc tarot_select va voir l'input de B et va revenir sur le jeu immediatement
		# Le just visible permet donc d'attendre une frame avant d'accepter les inputs
		just_visible = true
		return
	
	GameUi.snow.emitting = false
	HintCards.visible = (GameState.level_unlocked < 1)
	# Mouvement du curseur
	var old_cursor = cursor
	var dir = -int(Input.is_action_just_pressed("ui_left"))+int(Input.is_action_just_pressed("ui_right"))
	if dir != 0 :
		cursor.x = (cursor.x + dir + 3) % 3
	
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down")) :
		# comme on loop osef de savoir si on va vers le haut ou le bas, dans les deux cas on change de ligne
		cursor.y = (cursor.y + 1) % 2
	
	if old_cursor != cursor and holding :
		SoundManager.play_sound(SHUFFLE_SOUND, true)

	# Le reste : Ui sheneniganns
	# je te ferais un topo en voc si tu es curieux et que mon code est trop horrible a lire
	
	restore()
	
	if slots[cursor.y][cursor.x] and holding :
		if cursor.x == 0 or (cursor.x == 1 and slots[cursor.y][2] == null) :
			for i in range(len(slots[cursor.y])-1, cursor.x, -1) :
				if not slots[cursor.y][i-1] :
					continue
				slots[cursor.y][i] = slots[cursor.y][i-1]
		else :
			for i in range(0, cursor.x) :
				if not slots[cursor.y][i+1] :
					continue
				slots[cursor.y][i] = slots[cursor.y][i+1]
		slots[cursor.y][cursor.x] = null
	
	if Input.is_action_just_pressed("A") :
		if not holding :
			if slots[cursor.y][cursor.x] :
				SoundManager.play_sound(PICK_UP_SOUND, true)
				holding = slots[cursor.y][cursor.x]
				slots[cursor.y][cursor.x] = null
				backup()
				holding.z_index = 1
				if cursor.y == 1 :
					SoundManager.play_sound(SHUFFLE_SOUND, true)
				cursor = Vector2i(cursor.x, 0)
		else :
			SoundManager.play_sound(PICK_UP_SOUND, true)
			slots[cursor.y][cursor.x] = holding
			backup()
			holding.z_index = 0
			holding = null
			HintControl.hide()

	if (slots[0][0] and slots[0][1] and slots[0][2]) != ContinueLabel.visible :
		update_continue_label(slots[0][0] and slots[0][1] and slots[0][2])
	
	if Input.is_action_just_pressed("B") and not just_visible :
		self.hide()
		GameState.player_status = slots[0][0].status_index if slots[0][0] else GameState.STATUS.NORMAL
		GameState.mob_status = slots[0][1].status_index if slots[0][1] else GameState.STATUS.NORMAL
		GameState.world_status = slots[0][2].status_index if slots[0][2] else GameState.STATUS.NORMAL
		GameState.reset_level()
		SoundManager.play_sound(LOW_SHUFFLE_SOUND, true)
	
	update_cards()
	select(cursor)
	just_visible = false


func update_cards() :
	# Verifie que toutes les cartes sonnt bien placees
	for y in range(2) :
		for x in range(3) :
			if not slots[y][x] : continue
			move_card(slots[y][x],Vector2i(x,y))


func reset() :
	# On nettoie les cartes, puis on fait repop
	# ici on pourra mettre la logique qui change les cartes tirees selon le niveau actuel
	for card in get_tree().get_nodes_in_group("card") :
		card.queue_free()
	slots = [[null, null, null], [null, null, null]]
	var Level: Node2D = get_tree().get_first_node_in_group("level")
	if not Level :
		return
	var cards = [Level.tarot_card_1, Level.tarot_card_2, Level.tarot_card_3]
	for i in range(3) :
		var Card = cards[i].instantiate()
		move_card(Card, Vector2i(i, 1))
		$view_t.add_child(Card)
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
	# C'est juste une copie de slots dans backup, je fais comme ca a cause de python
	# Je t'expliquerais stv


func restore() :
	for y in range(2) :
		for x in range(3) :
			if backup_slots[y][x] == slots[y][x] :
				continue
			slots[y][x] = backup_slots[y][x]
	# C'est juste une copie de backup dans slots, je fais comme ca a cause de python
	# Je t'expliquerais stv


func select(vec: Vector2i) -> void :
	# deplace le curseur, et si une carte est en mouvement, ca la deplace avec
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($view_t/selector, 'position', Vector2(30 + 50 * (vec.x), 54 + 51 * (vec.y) - (10 if holding else 0)), 0.1)
	if holding :
		move_card(holding, vec)


func move_card(card: Sprite2D, vec: Vector2i) -> void :
	var target: Vector2 = Vector2(30 + 50 * (vec.x), 54 + 51 * (vec.y) - (10 if card == holding else 0))
	if card.position == target :
		return
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(card, 'position', target, 0.1)


func update_continue_label(visibility: bool) -> void :
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if visibility :
		ContinueLabel.show()
		ContinueLabel.position.y = 121
		tween.tween_property(ContinueLabel, "position", Vector2(80,68), 0.1)
		SoundManager.play_sound(TAROT_CHECK_SOUND)
	else :
		ContinueLabel.position.y = 68
		tween.tween_property(ContinueLabel, "position", Vector2(80,121), 0.1)
		tween.tween_callback(ContinueLabel.hide)
