extends Node2D

export var game_path: NodePath
onready var game = get_node(game_path)

func _ready():
	print("Appear?")
	$AnimationPlayer.play("Appear")

func _on_Start_pressed():
	$AnimationPlayer.play("Disappear")
	yield($AnimationPlayer, "animation_finished")
	game.start()
	queue_free()

func _on_Exit_pressed():
	get_tree().quit()
