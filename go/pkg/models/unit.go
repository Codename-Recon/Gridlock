package models

import (
	"github.com/Codename-Recon/Codename-Recon/go/pkg/enums/movement"
	"github.com/Codename-Recon/Codename-Recon/go/pkg/enums/unit"
)

type Unit struct {
	Name             string                 `json:"name"`
	Description      string                 `json:"description"`
	Cost             uint16                 `json:"cost"`
	Health           uint8                  `json:"health"`
	Mp               uint8                  `json:"mp" description:"movement_points"`
	MovementType     movement.EMovementType `json:"movement_type" description:"Uses index of enum/movement_type as an id reference."`
	Fuel             uint8                  `json:"fuel"`
	TurnFuel         uint8                  `json:"turn_fuel"`
	HiddenTurnFuel   uint8                  `json:"hidden_turn_fuel"`
	Vision           uint8                  `json:"vision"`
	Ammo             uint8                  `json:"ammo"`
	Weapons          [2]int8                `json:"weapons" description:"Uses index of enum/weapon as an id reference. Uses -1 for null."`
	MinRange         uint8                  `json:"min_range"`
	MaxRange         uint8                  `json:"max_range"`
	CanSupply        bool                   `json:"can_supply"`
	CanRepair        bool                   `json:"can_repair"`
	CanCapture       bool                   `json:"can_capture"`
	CanMoveAndAttack bool                   `json:"can_move_and_attack"`
	CanHide          bool                   `json:"can_hide"`
	CanDive          bool                   `json:"can_dive"`
	CanCarry         bool                   `json:"can_carry"`
	CarryingTypes    []unit.EUnit           `json:"carrying_types" description:"Uses index of enum/unit as an id reference."`
	CarryingSize     uint8                  `json:"carrying_size"`
}
