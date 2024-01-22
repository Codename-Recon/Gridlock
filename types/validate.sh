#!/bin/sh
yajsv -s ./schemas/unit.json 'units/*.json'
yajsv -s ./schemas/dmg_chart.json damage/primary.json
yajsv -s ./schemas/dmg_chart.json damage/secondary.json
yajsv -s ./schemas/movement_chart.json movement/chart.json