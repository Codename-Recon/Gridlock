package models

import (
	"math"

	"github.com/Codename-Recon/Codename-Recon/backend/pkg/enums/movement"
	"github.com/Codename-Recon/Codename-Recon/backend/pkg/enums/terrain"
	"github.com/Codename-Recon/Codename-Recon/backend/pkg/enums/weather"
)

type MovementCostArr [terrain.SIZE][weather.SIZE][movement.SIZE]int

type Movement struct {
	CostArr MovementCostArr
	Weather weather.EWeather
}

var MovementEngine = Movement{
	CostArr: MovementCostArr{
		{{1, 1, 1, 2, 1, 0, 0, 0}, {1, 1, 2, 3, 1, 0, 0, 0}, {2, 1, 2, 3, 2, 0, 0, 0}},
		{{2, 1, 0, 0, 1, 0, 0, 0}, {2, 1, 0, 0, 1, 0, 0, 0}, {4, 2, 0, 0, 2, 0, 0, 0}},
		{{1, 1, 2, 3, 1, 0, 0, 0}, {1, 1, 3, 4, 1, 0, 0, 0}, {2, 1, 2, 3, 2, 0, 0, 0}},
		{{2, 1, 0, 0, 1, 0, 0, 0}, {2, 1, 0, 0, 1, 0, 0, 0}, {2, 1, 0, 0, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{0, 0, 0, 0, 1, 1, 1, 0}, {0, 0, 0, 0, 1, 1, 1, 0}, {0, 0, 0, 0, 2, 2, 2, 0}},
		{{1, 1, 1, 1, 1, 0, 1, 0}, {1, 1, 1, 1, 2, 0, 1, 0}, {1, 1, 1, 1, 1, 0, 1, 0}},
		{{0, 0, 0, 0, 1, 2, 2, 0}, {0, 0, 0, 0, 1, 2, 2, 0}, {0, 0, 0, 0, 2, 2, 2, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 1}, {1, 1, 1, 1, 1, 0, 0, 1}, {1, 1, 1, 1, 2, 0, 0, 1}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 1, 1, 0}, {1, 1, 1, 1, 1, 1, 1, 0}, {1, 1, 1, 1, 2, 2, 2, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{0, 0, 0, 0, 0, 0, 0, 1}, {0, 0, 0, 0, 0, 0, 0, 1}, {0, 0, 0, 0, 0, 0, 0, 1}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
		{{1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 1, 0, 0, 0}, {1, 1, 1, 1, 2, 0, 0, 0}},
	},
}

func (m Movement) Cost(terrainType terrain.ETerrain, movementType movement.EMovementType) int {
	return m.CostArr[terrainType][m.Weather][movementType]
}

func ManhattanDistance(x1, y1, x2, y2 int) int {
	return int(math.Abs(float64(x1-x2)) + math.Abs(float64(y1-y2)))
}
