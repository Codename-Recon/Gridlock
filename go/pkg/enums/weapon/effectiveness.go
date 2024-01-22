package weapon

type EEffectiveness int8

const (
	Ineffective EEffectiveness = iota - 1
	Neutral
	Effective
)

func (e EEffectiveness) String() string {
	return [3]string{"Ineffective", "Neutral", "Effective"}[e+1]
}

func (e EEffectiveness) IsValid() bool {
	return e >= -1 && e <= 1
}
