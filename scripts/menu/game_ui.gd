extends CanvasLayer

# pour rendre accessible les elements en utilisant GameUi.element
@export var blindness: Node
@export var draw_tarot_label: Node
@export var start_label: Node
@export var win_label: Node
@export var reset_label: Node
@export var time_hint: Node
@export var time_label: Node
@export var level_type: Node
@export var level_index: Node
@export var snow: Node
@export var snow_particles: Node
@export var objectives_hints: Array[Node]

const ANIMATION_DELAY : float = 0.5

var animation_timer : float = 0
var PlayerSprite : Sprite2D
var MobSprite : Sprite2D
var FlagSprite : Sprite2D

func _process(delta: float) -> void:
	draw_tarot_label.visible = GameState.in_game
	
	if animation_timer > 0 :
		animation_timer -= delta
	else :
		animation_timer = ANIMATION_DELAY
		if PlayerSprite :
			toggle_anim(PlayerSprite)
		if FlagSprite :
			toggle_anim(FlagSprite)
		if MobSprite :
			toggle_anim(MobSprite)
	if not PlayerSprite :
		return
	update_sprites()

func reset_ui() -> void :
	win_label.hide()
	blindness.hide()
	reset_label.hide()
	time_hint.hide()
	level_index.hide()
	start_label.hide()
	snow_particles.hide()
	snow.emitting = false
	for hint in objectives_hints :
		hint.hide()

func show_start() -> void :
	if not TarotSelect.ContinueLabel.visible :
		return
	for hint in objectives_hints :
		hint.hide()
	start_label.show()

func toggle_anim(sprite:Sprite2D) -> void :
	if not sprite :
		return
	sprite.region_rect.position.y = 16 if sprite.region_rect.position.y == 0 else 0

func update_sprites() -> void :
	var player_type = PlayerSprite.get_parent().type
	level_type.region_rect.position.x = player_type * 16
	PlayerSprite.region_rect.position.x = player_type 
	if PlayerSprite.get_parent().velocity.length() > 5 and not get_tree().paused :
		PlayerSprite.region_rect.position.x += 4
		if PlayerSprite.get_parent().velocity.x > 0 :
			PlayerSprite.scale.x = 1
		if PlayerSprite.get_parent().velocity.x < 0 :
			PlayerSprite.scale.x = -1
	if GameState.player_status == GameState.STATUS.FROZEN and GameState.anim_pause < 0.6 :
		PlayerSprite.region_rect.position.x = 8 
	PlayerSprite.region_rect.position.x *= 16
	
	if not MobSprite :
		return
	
	MobSprite.region_rect.position.x = player_type
	if MobSprite.get_parent().velocity.length() > 5 and not get_tree().paused :
		MobSprite.region_rect.position.x += 4
		if MobSprite.get_parent().velocity.x > 0 :
			MobSprite.scale.x = -1
		if MobSprite.get_parent().velocity.x < 0 :
			MobSprite.scale.x = 1
	if GameState.mob_status == GameState.STATUS.FROZEN and GameState.anim_pause < 0.3:
		MobSprite.region_rect.position.x = 8
	if GameState.mob_status == GameState.STATUS.BLIND and GameState.anim_pause < 0.3 :
		MobSprite.region_rect.position.x = 9
		if MobSprite.get_parent().velocity.length() > 5 and not get_tree().paused :
			MobSprite.region_rect.position.x += 1
	MobSprite.region_rect.position.x *= 16
