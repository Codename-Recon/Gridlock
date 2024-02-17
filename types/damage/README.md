# CSV to JSON Conversion Script

This script converts a CSV file containing numeric data into a JSON format file. The input and output filenames are specified using command-line arguments, and the first row of the CSV file is assumed to be a header that should not be included in the output JSON file.

## Prerequisites

* Python 3.x

## Usage

1. Open a terminal or command prompt and navigate to the directory of this script.
2. Run the following command to generate primary damage JSON file:
```bash
python csv_to_json.py primary.csv
```
3. The script will create a new JSON file in the same directory with the same name as the input file, but with a `.json` extension.