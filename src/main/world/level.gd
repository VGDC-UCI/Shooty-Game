"""
Empty Script for Level stuff. May be useful later

Author: Srayan Jana, Kang Rui Yu
"""

extends Node2D

# References
onready var players_node: Node2D = $Players
onready var camera: Camera2D = $Camera2D
onready var score_board: Control = $CanvasLayer/ScoreBoard


func _ready() -> void:
	#check_hittable()
	#print("do you even work bro?")
	camera.targets = players_node.get_children()
	score_board.initialize_board(players_node.get_children())

#func check_hittable():
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

