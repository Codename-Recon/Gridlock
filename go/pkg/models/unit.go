package models

import (
	"github.com/Codename-Recon/Codename-Recon/go/pkg/enums/movement"
	"github.com/Codename-Recon/Codename-Recon/go/pkg/enums/unit"
)

type Unit struct {
	Name             string                 `json:"name"`
	Description      string                 `json:"description"`
	Cost             int                    `json:"cost"`
	Health           int                    `json:"health"`
	Mp               int                    `json:"mp" description:"movement_points"`     // movement_points
	MovementType     movement.EMovementType `json:"movement_type" jsonschema:"minimum=0"` // Uses index of enum/movement_type as an id reference
	Fuel             int                    `json:"fuel"`
	TurnFuel         int                    `json:"turn_fuel"`
	HiddenTurnFuel   int                    `json:"hidden_turn_fuel"`
	Vision           int                    `json:"vision"`
	Ammo             int                    `json:"ammo"`
	Weapons          [2]int                 `json:"weapons" jsonschema:"minimum=-1"` // Uses index of enum/weapon as an id reference. Uses -1 for null.
	MinRange         int                    `json:"min_range"`
	MaxRange         int                    `json:"max_range"`
	CanSupply        bool                   `json:"can_supply"`
	CanRepair        bool                   `json:"can_repair"`
	CanCapture       bool                   `json:"can_capture"`
	CanMoveAndAttack bool                   `json:"can_move_and_attack"`
	CanHide          bool                   `json:"can_hide"`
	CanDive          bool                   `json:"can_dive"`
	CanCarry         bool                   `json:"can_carry"`
	CarryingTypes    []unit.EUnit           `json:"carrying_types"` // Uses index of enum/unit as an id reference
	CarryingSize     int                    `json:"carrying_size"`
}
