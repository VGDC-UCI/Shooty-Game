"""
UI element that displays a players health, shield, name, kills, and deaths.

Author: Kang Rui Yu
"""


extends PanelContainer


"References"
var player: Player = null

onready var portrait := $Center/Portrait
onready var name_label := $Center/PlayerInformation/Name
onready var team_label := $Center/PlayerInformation/Team
onready var score_label := $Center/PlayerInformation/Score


func _process(_delta: float) -> void:
	score_label.text = "K: " + str(player.get_kills()) + " / D: " + str(player.get_deaths())


func track_player(target: Player) -> void:
	player = target
	portrait.texture = characters.get_character_portrait(player.get_character_id())
	name_label.text = player.get_username()
	team_label.text = "Team: " + str(player.get_team())
