"""
UI element that displays a players health, shield, name, kills, and deaths.

Author: Kang Rui Yu
"""


extends PanelContainer


"References"
var player: Player = null

onready var portrait := $MarginContainer/HBoxContainer/Portrait
onready var name_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Name
onready var team_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Team
onready var score_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Score


func _process(_delta: float) -> void:
	score_label.text = "K: " + str(player.numb_of_kills) + " / D: " + str(player.numb_of_deaths)


func track_player(target: Player) -> void:
	player = target
	portrait.texture = player.player_portrait
	name_label.text = player.get_username()
	team_label.text = str(player.team)
