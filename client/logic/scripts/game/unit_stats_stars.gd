@tool
class_name UnitStatsStars
extends Control

@export var star_number: int = 0:
	set(value):
		star_number = value
		if value > 0:
			($"1" as TextureRect).show()
		else:
			($"1" as TextureRect).hide()

		if value > 1:
			($"2" as TextureRect).show()
		else:
			($"2" as TextureRect).hide()

		if value > 2:
			($"3" as TextureRect).show()
		else:
			($"3" as TextureRect).hide()

		if value > 3:
			($"4" as TextureRect).show()
		else:
			($"4" as TextureRect).hide()
