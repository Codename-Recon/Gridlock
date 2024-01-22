package models

import "github.com/Codename-Recon/Codename-Recon/go/pkg/enums/terrain"

type Terrain struct {
	Name         string           `json:"name" description:"Uses index of enum/terrain as an id reference."`
	Description  string           `json:"description"`
	Type         terrain.ETerrain `json:"type" description:"Uses index of enum/terrain as an id reference." minimum:"0" maximum:"17"`
	Defense      uint8            `json:"defense" minimum:"0" maximum:"4"`
	Health       uint8            `json:"health" minimum:"0" maximum:"100"`
	CanCapture   bool             `json:"can_capture"`
	CaptureValue uint8            `json:"capture_value" description:"Current status of capture by Infantry or Mech." minimum:"0" maximum:"20"`
	Owner        uint8            `json:"owner" description:"0 = neutral, all other numbers correspond to player number" minimum:"0"`
	Funds        uint16           `json:"funds" description:"Funds provided to owner per turn." minimum:"0"`
	Ammo         uint8            `json:"ammo" description:"Primarily used for missile silos" minimum:"0"`
}
