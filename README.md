# LD_Analysis
This script measures Lipid Droplets within cells by using nested analyse particles commands.

## Running the script
The first screen to appear is the main splash screen displaying information about the script and its author.
The following window allows the user to set parameters for this script it includes the expected file extension.
Next, the user can select the working directory location.

The script first takes channel 3 and identifies cellular membranes and uses this metric to find the number of cells.

The total cellular area is determined by summing each found cells' area.

Next, each cell is indivually selected and the number of lipid droplets within this ROI is counted and measured using the analyse particles tool.

Results information is reported out into the spreadsheet and relevant windows and masks are saved before being closed.

## Output Data
An output spreadsheet is created with the following format:
| File Name 	| Cell Number 	| Cell Area 	| Lipid Droplet Number 	| Lipid Droplet Area 	|
|-----------	|-------------	|-----------	|----------------------	|--------------------	|
|           	|             	|           	|                      	|                    	|

While the Lipid Droplet threshold image and cellular mask images are also saved within the output directory.
