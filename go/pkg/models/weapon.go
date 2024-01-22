package models

import "github.com/Codename-Recon/Codename-Recon/go/pkg/enums/weapon"

type WeaponEffectiveness struct {
	Infantry   weapon.EEffectiveness `json:"infantry" minimum:"-1" maximum:"1"`
	Vehicle    weapon.EEffectiveness `json:"vehicle" minimum:"-1" maximum:"1"`
	Air        weapon.EEffectiveness `json:"air" minimum:"-1" maximum:"1"`
	Helicopter weapon.EEffectiveness `json:"helicopter" minimum:"-1" maximum:"1"`
	Ship       weapon.EEffectiveness `json:"ship" minimum:"-1" maximum:"1"`
	Sub        weapon.EEffectiveness `json:"sub" minimum:"-1" maximum:"1"`
}

type Weapon struct {
	Name          string              `json:"name"`
	Description   string              `json:"description"`
	Effectiveness WeaponEffectiveness `json:"effectiveness"`
}
