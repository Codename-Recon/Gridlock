package weather

type EWeather uint8

const (
	CLEAR EWeather = iota
	RAIN
	SNOW
	SIZE
)

func (e EWeather) String() string {
	return [SIZE]string{"CLEAR", "RAIN", "SNOW"}[e]
}

func (e EWeather) IsValid() bool {
	return e >= 0 && e < SIZE
}
