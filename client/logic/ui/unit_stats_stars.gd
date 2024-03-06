@tool
class_name UnitStatsStars
extends Control

@export var star_number: int = 0:
	set(value):
		star_number = value
		for i: int in stars.size():
			if i + 1 <= value:
				stars[i].show()
			else:
				stars[i].hide()

@export var stars: Array[TextureRect]
