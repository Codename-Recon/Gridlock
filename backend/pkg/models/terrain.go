package models

import "github.com/Codename-Recon/Codename-Recon/backend/pkg/enums/terrain"

type Terrain struct {
	Name         string           `json:"name"`
	Description  string           `json:"description"`
	Type         terrain.ETerrain `json:"type" jsonschema:"minimum=0,maximum=17"` // Uses index of enum/terrain as an id reference
	Defense      int              `json:"defense" jsonschema:"minimum=0,maximum=4"`
	Health       int              `json:"health" jsonschema:"minimum=0,maximum=100"`
	CanCapture   bool             `json:"can_capture"`
	CaptureValue int              `json:"capture_value" jsonschema:"minimum=0,maximum=20"` // Current status of capture by Infantry or Mech
	Owner        int              `json:"owner" jsonschema:"minimum=0"`                    // 0 = neutral, all ohter numbers correspond to player number
	Funds        int              `json:"funds" jsonschema:"minimum=0"`                    // Funds provided to owner per turn
	Ammo         int              `json:"ammo" jsonschema:"minimum=0"`                     // Primarily used for missile silos
}
