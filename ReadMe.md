---------------------------------
# DSSAT/CANEGRO Calibration
Murilo Vianna (Jun-2018)
----------------------------------


# Main Goal:
Calibrate .CUL and .ECO crop parameters of DSSAT/CANEGRO (PBM)

# Methods:
It uses the general purpose optimization function "optim()" embedded in R environment. User can set up the optimization method, objective function, observed data, and parameters to be calibrated. Charts and tables are provided as outputs with calibrated parameters in folder 'results'.

![alt text](https://github.com/Murilodsv/dssat_sscan_calib/blob/master/framework.png)

# How to Use:
1) Set the dssat_canegro_calib_par.csv file with initial parameters and boundaries
2) Open dssat_sccan_calib.R and follow the comented instructions

# Example Run:
An example is already set in file dssat_sccan_calib.R. To run it make sure to copy the files SCGO0001.SCX and GOGO.WTH into the  DSSAT47/Sugarcane folder.

The script runs for a snipped cultivar database provided in the db folder

