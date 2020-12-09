"""
UI element that displays a players health, shield, name, kills, and deaths.

Author: Kang Rui Yu
"""

extends PanelContainer

# References
var player: Player = null
onready var portrait := $MarginContainer/HBoxContainer/Portrait
onready var health_bar := $MarginContainer/HBoxContainer/VBoxContainer/HealthBar
onready var shield_bar := $MarginContainer/HBoxContainer/VBoxContainer/ShieldBar
onready var name_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Name
onready var team_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Team
onready var score_label := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Score


func track_player(target: Player) -> void:
	player = target
	portrait.texture = player.player_portrait
	name_label.text = player.player_name
	team_label.text = str(player.team)

	health_bar.max_value = player.default_health
	shield_bar.max_value = player.default_shield


func _process(_delta: float) -> void:
	health_bar.value = player.player_health
	shield_bar.value = player.shield_health

	score_label.text = "K: " + str(player.numb_of_kills) + " / D: " + str(player.numb_of_deaths)
