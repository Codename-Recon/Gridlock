package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"text/template"

	"github.com/Codename-Recon/Codename-Recon/backend/pkg/models"
)

func isLast(index int, size int) bool {
	return index == size-1
}

func createTemplate(templatePath string) (*template.Template, error) {
	tmplData, err := os.ReadFile(templatePath)
	if err != nil {
		return nil, err
	}

	tmpl, err := template.New("").Funcs(template.FuncMap{"isLast": isLast}).Parse(string(tmplData))
	if err != nil {
		return nil, err
	}
	return tmpl, nil
}

func loadUnits(cwd string) error {
	folderPath := filepath.Join(cwd, "../../../types/units")
	templatePath := filepath.Join(cwd, "./templates/units.tmpl")
	outputPath := filepath.Join(cwd, "../../pkg/models/gen_units.go")

	dirEntries, err := os.ReadDir(folderPath)
	if err != nil {
		return err
	}

	units := make([]models.Unit, len(dirEntries))

	for i, dirEntry := range dirEntries {
		filePath := folderPath + "/" + dirEntry.Name()
		jsonData, err := os.ReadFile(filePath)
		if err != nil {
			return err
		}
		err = json.Unmarshal([]byte(jsonData), &units[i])
		if err != nil {
			return err
		}
	}

	tmpl, err := createTemplate(templatePath)
	if err != nil {
		return err
	}

	outputFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	err = tmpl.Execute(outputFile, units)
	if err != nil {
		return err
	}

	return nil
}

func loadTerrain(cwd string) error {
	folderPath := filepath.Join(cwd, "../../../types/terrain")
	templatePath := filepath.Join(cwd, "./templates/terrain.tmpl")
	outputPath := filepath.Join(cwd, "../../pkg/models/gen_terrain.go")

	dirEntries, err := os.ReadDir(folderPath)
	if err != nil {
		return err
	}

	terrain := make([]models.Terrain, len(dirEntries))

	for i, dirEntry := range dirEntries {
		filePath := folderPath + "/" + dirEntry.Name()
		jsonData, err := os.ReadFile(filePath)
		if err != nil {
			return err
		}
		err = json.Unmarshal([]byte(jsonData), &terrain[i])
		if err != nil {
			return err
		}
	}

	tmpl, err := createTemplate(templatePath)
	if err != nil {
		return err
	}

	outputFile, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer outputFile.Close()

	err = tmpl.Execute(outputFile, terrain)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	_, filename, _, ok := runtime.Caller(0)
	if !ok {
		panic("unable to get the current filename")
	}
	cwd := filepath.Dir(filename)

	var err error
	err = loadUnits(cwd)
	if err != nil {
		fmt.Println(err)
	}
	err = loadTerrain(cwd)
	if err != nil {
		fmt.Println(err)
	}
}
