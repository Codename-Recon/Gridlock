@icon("res://assets/images/icons/paper-plane-outline.svg")
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
