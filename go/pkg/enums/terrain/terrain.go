package terrain

type ETerrain uint8

const (
	PLAIN ETerrain = iota
	MOUNTAIN
	WOOD
	RIVER
	ROAD
	BRIDGE
	SEA
	SHOAL
	CITY
	BASE
	AIRPORT
	PORT
	HQ
	PIPE
	SILO
	COM_TOWER
	LAB
	REEF
	SIZE
)

func (e ETerrain) String() string {
	return [SIZE]string{
		"PLAIN",
		"MOUNTAIN",
		"WOOD",
		"RIVER",
		"ROAD",
		"BRIDGE",
		"SEA",
		"SHOAL",
		"CITY",
		"BASE",
		"AIRPORT",
		"PORT",
		"HQ",
		"PIPE",
		"SILO",
		"COM_TOWER",
		"LAB",
		"REEF",
	}[e]
}

func (e ETerrain) IsValid() bool {
	return e >= 0 && e < SIZE
}
