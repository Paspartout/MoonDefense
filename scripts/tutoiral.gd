class_name Tutorial
extends Node

func start():
	$AnimationPlayer.play("Appear")
	enabled = true

signal done()

var enabled = false
var movement = true

onready var keys_dict = {
	"move_up": $"Tutorial/01_Movement/HBoxContainer/Buttons/W",
	"move_down": $"Tutorial/01_Movement/HBoxContainer/Buttons/S",
	"move_right": $"Tutorial/01_Movement/HBoxContainer/Buttons/D",
	"move_left": $"Tutorial/01_Movement/HBoxContainer/Buttons/A",
	"shoot": $"Tutorial/02_Shoot/Space",
}

var correct = 0

func _input(event):
	if not enabled:
		return
	if movement:
		for k in keys_dict.keys():
			if event.is_action(k):
				if !keys_dict[k].disabled:
					keys_dict[k].disabled = true
					correct += 1
					$SelectPlayer.play()

		if correct >= 4:
			$"Tutorial/01_Movement".visible = false
			$"Tutorial/02_Shoot".visible = true
			movement = false
			$DonePlayer.play()
	else:
		if event.is_action("shoot"):
			keys_dict["shoot"].disabled = true
			$DonePlayer.play()
			enabled = false
			$AnimationPlayer.play("Disappear")
			emit_signal("done")
