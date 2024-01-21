#!/bin/sh
yajsv -s ./schema/unit.json 'units/*.json'
yajsv -s ./schema/dmg_chart.json damage/primary.json
yajsv -s ./schema/dmg_chart.json damage/secondary.json
yajsv -s ./schema/movement_chart.json movement/chart.json