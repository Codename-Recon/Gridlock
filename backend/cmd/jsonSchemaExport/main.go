package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/Codename-Recon/Codename-Recon/backend/pkg/models"
	"github.com/invopop/jsonschema"
)

const (
	REPO_BASE string = "github.com/Codename-Recon/Codename-Recon/backend"
)

func saveStructToJson(r *jsonschema.Reflector, obj any, filename string) error {
	s := r.Reflect(obj)
	data, err := json.MarshalIndent(s, "", " ")
	if err != nil {
		return err
	}

	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.Write(data)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	r := &jsonschema.Reflector{
		ExpandedStruct: true,
	}
	if err := r.AddGoComments(REPO_BASE, "./"); err != nil {
		panic(err.Error())
	}

	if err := saveStructToJson(r, &models.Terrain{}, "./terrain.schema.json"); err != nil {
		fmt.Println(err)
	}
	if err := saveStructToJson(r, &models.Unit{}, "./unit.schema.json"); err != nil {
		fmt.Println(err)
	}
	if err := saveStructToJson(r, &models.Weapon{}, "./weapon.schema.json"); err != nil {
		fmt.Println(err)
	}

}
