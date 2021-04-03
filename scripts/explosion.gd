extends AnimatedSprite

const sound1 = preload("res://sfx/explosion_01.wav")
const sound2 = preload("res://sfx/explosion_02.wav")
const sound3 = preload("res://sfx/explosion_03.wav")

func _ready():
	$AudioStreamPlayer.stream = [sound1, sound2, sound3][randi() % 3]
	$AudioStreamPlayer.play()
	play()

func _on_Explosion_animation_finished():
	visible = false

func _on_AudioStreamPlayer_finished():
	queue_free()
