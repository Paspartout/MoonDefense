extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("MoveIn")

signal done()

var movement = true
var done = false

onready var keys_dict = {
	"move_up": $"Tutorial/01_Movement/VBoxContainer/HBoxContainer/Buttons/W",
	"move_down": $"Tutorial/01_Movement/VBoxContainer/HBoxContainer/Buttons/S",
	"move_right": $"Tutorial/01_Movement/VBoxContainer/HBoxContainer/Buttons/D",
	"move_left": $"Tutorial/01_Movement/VBoxContainer/HBoxContainer/Buttons/A",
	"shoot": $"Tutorial/02_Shoot/VBoxContainer/Buttons/Space",
}

var correct = 0

func _input(event):
	if done:
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
			done = true
			$AnimationPlayer.play("MoveOut")
			emit_signal("done")
