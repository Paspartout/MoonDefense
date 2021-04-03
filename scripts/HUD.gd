extends Panel

export var player_path: NodePath
var player: Player 

func set_player(new_player: Player):
	player = new_player
	player.connect("hp_changed", self, "update_hp")
	$HP.text = "HP: %d" % player.health

func update_hp(new_hp):
	$HP.text = "HP: %d" % new_hp
