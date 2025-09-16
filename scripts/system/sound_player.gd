extends AudioStreamPlayer
@export var loop_sound = true

# Je suis oblige de faire ce bricolage pour looper la musique
# parce que juste cocher l'option looping fait looper la musique dans l'editeur
# mais pas dans l'export

func _ready():
	connect("finished", _on_finished)

func _on_finished():
	if loop_sound == true:
		play();
