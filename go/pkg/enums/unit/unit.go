package unit

type EUnit uint8

const (
	ANTI_AIR EUnit = iota
	APC
	ARTILLERY
	BCOPTER
	BATTLESHIP
	BLACK_BOAT
	BLACK_BOMB
	BOMBER
	CARRIER
	CRUISER
	FIGHTER
	INFANTRY
	LANDER
	MD_TANK
	MECH
	MEGA_TANK
	MISSILE
	NEOTANK
	PIPERUNNER
	RECON
	ROCKET
	STEALTH
	SUB
	TCOPTER
	TANK
	SIZE
)

func (e EUnit) String() string {
	return [SIZE]string{
		"ANTI_AIR",
		"APC",
		"ARTILLERY",
		"B-COPTER",
		"BATTLESHIP",
		"BLACK_BOAT",
		"BLACK_BOMB",
		"BOMBER",
		"CARRIER",
		"CRUISER",
		"FIGHTER",
		"INFANTRY",
		"LANDER",
		"MD_TANK",
		"MECH",
		"MEGA_TANK",
		"MISSILE",
		"NEOTANK",
		"PIPERUNNER",
		"RECON",
		"ROCKET",
		"STEALTH",
		"SUB",
		"T-COPTER",
		"TANK",
	}[e]
}

func (e EUnit) IsValid() bool {
	return e >= 0 && e < SIZE
}
