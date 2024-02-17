import csv
import json
import os
import sys

# Get the input and output filenames using os.path.splitext
input_filename, ending = os.path.splitext(sys.argv[1])
output_filename = f"{input_filename}.json"

# Open the input file
with open(input_filename + ending, 'r') as infile:
    # Create a CSV reader object
    reader = csv.reader(infile)

    # Skip the header row
    next(reader)

    # Initialize an empty list to store the data
    data = []

    # Iterate through each row in the CSV file
    for row in reader:
        # Append a list of integers (excluding the first column) to the data list
        data.append([int(x) for x in row[1:]])

# Create a JSON formatted string from the data list
json_data = json.dumps(data)

# Open the output file and write the JSON data to it
with open(output_filename, 'w') as outfile:
    outfile.write(json_data)