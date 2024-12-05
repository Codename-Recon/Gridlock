class_name Scenario

var id: String
var order: int
var stats: Stats
var conditions: Conditions


class Stats:
	var killed_value: int
	var lost_value: int


class Conditions:
	var max_round: int
	var a_round: int
	var c_round: int
