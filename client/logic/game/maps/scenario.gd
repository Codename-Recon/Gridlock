class_name Scenario
extends RefCounted

var order: int
var stats: Stats
var conditions: Conditions


class Stats:
	var killed_value: int
	var lost_value: int


class Conditions:
	var max_round: int
	var s_rank_stats: Stats
