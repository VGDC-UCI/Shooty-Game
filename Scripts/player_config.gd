extends Resource


# Properties
var name: String
var class_id: int
var input_id: int


func initialize(given_name: String, given_class: int = 0, given_input: int = 0) -> void:
	name = given_name	
	class_id = given_class
	input_id = given_input
