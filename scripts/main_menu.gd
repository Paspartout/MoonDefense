extends Node2D

export var game_path: NodePath
onready var game = get_node(game_path)

onready var main = $Panel/Main
onready var levels = $Panel/Levels

func _ready():
	$AnimationPlayer.play("Appear")
	$Panel/Main/Start.grab_focus()

func start(level: int):
	$AnimationPlayer.play("Disappear")
	yield($AnimationPlayer, "animation_finished")
	game.current_section = level
	game.start()
	queue_free()	

func _on_Start_pressed():
	start(0)

func _on_Exit_pressed():
	get_tree().quit()

func _on_Levels_pressed():
	main.visible = false
	levels.visible = true

func _on_Level1_pressed():
	game.skip_tutorial = true
	start(0)

func _on_Level2_pressed():
	game.skip_tutorial = true
	start(1)

func _on_Level3_pressed():
	game.skip_tutorial = true
	start(2)

func _on_Level4_pressed():
	game.skip_tutorial = true
	start(3)

func _on_Back_pressed():
	main.visible = true
	levels.visible = false
