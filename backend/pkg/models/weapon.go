package models

import "github.com/Codename-Recon/Gridlock/backend/pkg/enums/weapon"

type WeaponEffectiveness struct {
	Infantry   weapon.EEffectiveness `json:"infantry" jsonschema:"minimum=-1,maximum=1"`
	Vehicle    weapon.EEffectiveness `json:"vehicle" jsonschema:"minimum=-1,maximum=1"`
	Air        weapon.EEffectiveness `json:"air" jsonschema:"minimum=-1,maximum=1"`
	Helicopter weapon.EEffectiveness `json:"helicopter" jsonschema:"minimum=-1,maximum=1"`
	Ship       weapon.EEffectiveness `json:"ship" jsonschema:"minimum=-1,maximum=1"`
	Sub        weapon.EEffectiveness `json:"sub" jsonschema:"minimum=-1,maximum=1"`
}

type Weapon struct {
	Name          string              `json:"name"`
	Description   string              `json:"description"`
	Effectiveness WeaponEffectiveness `json:"effectiveness"`
}
