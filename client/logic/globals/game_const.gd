@icon("res://assets/images/icons/nodes/paper-plane-outline.svg")
class_name GameConst
extends Node

enum Actions {
	NONE,
	MOVE,
	ATTACK,
	ENTER,
	DEPLOY,
	JOIN,
	REFILL,
	CAPTURE,
}

enum State {
	NONE,
	EARNING,
	REPAIRING,
	SELECTING,
	COMMANDING,
	BUYING,
	ACTION,
	ATTACKING,
	DEPLOYING,
	REFILLING,
	ENDING,
}

enum Event {
	NONE,
	CLICKED_RIGHT,
	CLICKED_LEFT,
	CLICKED_ACTION,
	CLICKED_SHOP,
	CLICKED_END_ROUND,
}

enum InputType {
	HUMAN,
	AI,
	NETWORK,
}

enum AiDifficulty {
	SELECTABLE,
	EASY,
	MEDIUM,
	HARD,
}

enum GameMode { SINGLE, HOTSEAT, NETWORK }

# TODO: Should be generated
enum Weather { CLEAR, RAIN, SNOW }

# TODO: Should be generated
enum MovementType {
	FOOT,
	BAZOOKA,
	TREADS,
	WHEELS,
	AIR,
	SEA,
	LANDER,
	PIPERUNNER
}

# TODO: Should be generated
enum WeaponType {
	ARTILLERY_CANON,
	BAZOOKA,
	LIGHT_TANK_CANON,
	MACHINE_GUN,
	MEDIUM_TANK_CANON,
	ROCKETS,
	TANK_MACHINE_GUN,
	VUCLAN_CANNON
}
