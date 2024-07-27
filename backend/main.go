package main

import (
	"fmt"

	"github.com/Codename-Recon/Gridlock/backend/pkg/enums/movement"
	"github.com/Codename-Recon/Gridlock/backend/pkg/enums/unit"
	"github.com/Codename-Recon/Gridlock/backend/pkg/models"
)

func main() {
	aa := models.Unit{
		Name:             "ANTI_AIR",
		Description:      "ANTI_AIR_DESCRIPTION",
		Cost:             8000,
		Health:           100,
		Mp:               6,
		MovementType:     movement.EMovementType(2),
		Fuel:             60,
		TurnFuel:         0,
		HiddenTurnFuel:   0,
		Vision:           2,
		Ammo:             9,
		Weapons:          [2]int{7, -1},
		MinRange:         1,
		MaxRange:         1,
		CanSupply:        false,
		CanRepair:        false,
		CanCapture:       false,
		CanMoveAndAttack: true,
		CanHide:          false,
		CanDive:          false,
		CanCarry:         false,
		CarryingTypes:    []unit.EUnit{},
		CarryingSize:     0,
	}

	fmt.Printf("%+v\n", aa)
}
