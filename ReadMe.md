---------------------------------
# DSSAT/CANEGRO Calibration
Murilo Vianna (Jun-2018)
----------------------------------


# Main Goal:
Calibrate .CUL and .ECO crop parameters of DSSAT/CANEGRO (PBM)

# Methods:
It uses the general purpose optimization function "optim()" embedded in R environment. User can set up the optimization method, objective function, observed data, and parameters to be calibrated. Charts and tables are provided as outputs with calibrated parameters in folder 'results'.

![alt text](https://github.com/Murilodsv/dssat_sscan_calib/blob/master/framework.png)

# Example Run:
An example is already set in the table dssat_canegro_calib_par.csv and file dssat_sccan_calib.R
To run it make sure to copy the files SCGO0001.SCX and GOGO.WTH into the DSSAT47/Sugarcane folder.

Then, open dssat_sccan_calib.R and follow the comented instructions.

# How to Use:
1) Set the dssat_canegro_calib_par.csv file with initial parameters and boundaries:
Specify in the column 'Calibrate' which parameter will be calibrated by writing T or F
In Columns 'Init_values' 'Calib_range_min'	'Calib_range_max' specify the initial parameters values, the minimum and maximum range.

2) Open dssat_sccan_calib.R and follow the comented instructions
