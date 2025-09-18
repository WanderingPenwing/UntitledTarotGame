extends CanvasLayer

# pour rendre accessible les elements en utilisant GameUi.element
@export var blindness: Node
@export var draw_tarot_label: Node
@export var start_label: Node
@export var win_label: Node


func _process(_delta: float) -> void:
	blindness.visible = (GameState.player_status == GameState.STATUS.BLIND) and not win_label.visible
	draw_tarot_label.visible = GameState.in_game
