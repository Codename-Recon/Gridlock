package movement

type EMovementType uint8

const (
	FOOT EMovementType = iota
	BAZOOKA
	TREADS
	WHEELS
	AIR
	SEA
	LANDER
	PIPERUNNER
	SIZE
)

func (e EMovementType) String() string {
	return [SIZE]string{
		"FOOT",
		"BAZOOKA",
		"TREADS",
		"WHEELS",
		"AIR",
		"SEA",
		"LANDER",
		"PIPERUNNER",
	}[e]
}

func (e EMovementType) IsValid() bool {
	return e >= 0 && e < SIZE
}
