#---------------------------------#
#--- DSSAT CANEGRO Calibration ---#
#---------------------------------#

#--- Goal: Calibrate crop parameters of DSSAT/CANEGRO 
#---       (this is not GLUE or GenCalc)

#--- History
#--- Jun-2018: Created (Murilo Vianna)
#--- Jan-2020: Updated for new CANEGRO version (Murilo Vianna)

#----------------------------#
#--- Running this example ---#
#----------------------------#

#--- Before start copy the below files to DSSATv47/Sugarcane folder:
#--- 'repository'/db/SCGO0001.SCX     (X file for this example)
#--- 'repository'/db/GOGO.WTH         (Weather file for this example)

#--- This example will optimize the tillering coefficients of DSSAT/CANEGRO for
#--- different varieties using the variety Nco376 as base

#--------------------#
#--- Script Setup ---#
#--------------------#
wd        = "C:/Murilo/dssat_sscan_calib" # Working directory (repository)            
ds_v      = 47                            # DSSAT version
crop      = "Sugarcane"                   # Crop name
xfile     = "SCGO0001.SCX"                # X file
parnm     = "SCCAN047"                    # Model name SCCAN047 = CANEGRO
pdssat    = F                             # Print DSSAT echo while running
savepng   = T                             # save optimization dev to png file?

#--------------------------#
#--- Optimization Setup ---#
#--------------------------#
op_reltol     = 1e-5          # Relative convergence tolerance
method.opt    = "Nelder-Mead" # More options can be set for other methds (see ?optim)
nopt          = 15            # Number of optimization repetitions (repeat process with randomly different initial conditions)

#--- Observed data used for calibration
#--- Note: here we are using one variable but you can add as many as needed
#---  As long as the model outputs that...
used.data     = "Tillering_n_m-2"

#--- model output to be compared with observation
sscan_out     = "t.ad" # is possible to add as many outputs as needed

#--- Statistical index used as objective function by the optimization (for different indexes see mperf())
outidx      = "rmse" # Using Root Mean Squared Error (RMSE). See mperf() function for more options

#--- Load Functions (~/bin/) 
invisible(sapply(list.files(path = paste0(wd,"/bin/"),full.names = T),
                               function(x) source(x)))

#--- Reading plant observations and PlantGro Header
obs_raw   = read.csv(paste0(wd,"/db/gogo_field_data.csv"))
pgro_head = read.csv(paste0(wd,"/db/PlantGro_Head.csv"))

#--- PlantGro header
pgro_names  = pgro_head$R_head

#--- prepare batch call
bfile = readLines(paste(wd,"/DSSBatch_Master.v47",sep=""))
bfile[4] = gsub("<calib_xfile>",xfile,bfile[4])

#--- write batch in Crop folder
write(bfile,file = paste("C:/DSSAT",ds_v,"/",crop,"/","DSSBatch.v",ds_v,sep = ""))

#--- Read parameters set up
par_set   = read.csv(paste(wd,"/dssat_canegro_calib_par.csv",sep=""))
calib     = par_set

l_cv = unique(obs_raw$Cultivar)

for(cv in l_cv){

  #--- logical settings
  plotperf = F # plot sim x obs?
  plotdev  = T # follow-up optimization?
  uselimits= T # use min and max boudaries to drive optimization? (in set_par max and min) 
  
  #--- current cultivar
  calib_id  = cv

  message(paste("Start of optimization for ",cv,sep=""))
  
  #--- Feature scaling (0-1)
  calib$svalue = (calib$Init_values - calib$Calib_range_min) /  (calib$Calib_range_max - calib$Calib_range_min)
  
  #--- Parameters to be calibrated
  svalue = calib$svalue[calib$Calibrate]
  
  #--- number of parameters
  npar = length(svalue)
  
  #--- wipe optimization file
  obj_df = data.frame(n = 0, obj = 0,inbounds = T)
  
  for(i in 1:length(svalue)) {
    df = data.frame(v = calib$Init_values[calib$Calibrate][i])
    colnames(df) = calib$Par_orig[calib$Calibrate][i]
    obj_df = cbind(obj_df,df)
  }
  
  #--- write a temporary file with optimization progression
  write.csv(obj_df,file = paste(wd,"/optim_dev.csv",sep=""),row.names = F)
  
  #--- read observed data for cultivar (cv)
  obs_df      = data.frame(cv  = cv,
                           dap = obs_raw$DAP[obs_raw$Cultivar==calib_id & obs_raw$Type==used.data],
                           obs = obs_raw$Value[obs_raw$Cultivar==calib_id & obs_raw$Type==used.data])
  
  
for(i in 1:nopt){
  
  #--------------------#
  #--- Optimization ---#
  #--------------------#
  
  #--- Optimize 
  optim(svalue,dssat_sccan_calib,control = list(reltol = op_reltol),
        method = method.opt)
  
  #--- restart iniial conditions (try to fall on global minimum)
  new_val = rnorm(1000,0.5,0.25)
  new_val = new_val[new_val>=0 & new_val<=1]
  
  #--- pick randomized points within the distribution
  new_val = new_val[abs(rnorm(length(svalue),500,100))]
  
  #--- check if the number of paramters match with requirements
  if(length(new_val) < npar){
    ntry = 1
    while(length(new_val) == npar){
      new_val = new_val[abs(rnorm(length(svalue),500,100))]
      ntry = ntry + 1
      if(ntry > 1000){stop("Failed to find new inital conditions, please review the initial parameters setup.")}
    }
  }
  
  svalue = new_val
}
  
  message(paste("End of optimization for ",cv,sep=""))
  
  #--- write optimization parameters
  opt_par = read.csv(paste(wd,"/optim_dev.csv",sep=""))
  write.csv(opt_par,file = paste(wd,"/optim_dev_",cv,".csv",sep=""),row.names = F)
  
  #--- save to png file (there is room for using ggplot here)
  if(savepng){
    png(paste(wd,"/optimization_",calib_id,".png",sep=""),
        units="in", 
        width=24, 
        height=12, 
        pointsize=24, 
        res=300)
    plot(opt_par$obj~opt_par$n, type = "l",ylab = outidx,xlab = "Number of iterations", ylim = c(0,max(opt_par$obj)))
    lines(c(min(opt_par$obj),min(opt_par$obj))~c(-1000,max(opt_par$n)*1000), lty = 3,col = "red")
    
    dev.off()
    
  }
  
  
  #--- Best set of parameters
  svalue_df =  opt_par[opt_par$obj==min(opt_par$obj[opt_par$inbounds]),as.character(calib$Par_orig[calib$Calibrate])]
  
  if(length(svalue_df[,as.character(calib$Par_orig[calib$Calibrate][1])]) > 1){
    #---use pick up the median minimun values
    svalue_df = sapply(as.character(calib$Par_orig[calib$Calibrate]),function(x) median(svalue_df[,x]))
  }
  
  svalue = svalue_df
  
  #--- scale paramters
  svalue = (svalue - calib$Calib_range_min[calib$Calibrate]) / (calib$Calib_range_max[calib$Calibrate] - calib$Calib_range_min[calib$Calibrate])
  
  #--- check best parameters performance
  plotperf = T # plot sim x obs?
  plotdev  = F # follow-up optimization?
  dssat_sccan_calib(svalue)

}

