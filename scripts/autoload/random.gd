extends Node2D

var characters: String = "abcdefghijklmnopqrstuvwxyz"


func _ready():
	print("setting random seed")
	randomize()


func generate_word(length, chars: String = characters) -> String:
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word
