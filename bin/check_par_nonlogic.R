#--- Check parameters phyiological consistency 

check_par_nonlogic = function(calib){
  
  #--- check parameter physilogical logic
  out = F
  
  if(calib$pvalue[calib$Par_orig=="CHUPIBASE"] < calib$pvalue[calib$Par_orig=="TTPLNTEM"]){
    message("")
    message("Warning: CHUPIBASE lower than TTPLNTEM (Objective increased)")
    out = T
  }
  
  if(calib$pvalue[calib$Par_orig=="CHUPIBASE"] < calib$pvalue[calib$Par_orig=="TTRATNEM"]){
    message("")
    message("Warning: CHUPIBASE lower than TTRATNEM (Objective increased)")
    out = T
  }
  
  if(calib$pvalue[calib$Par_orig=="PI2"]   < calib$pvalue[calib$Par_orig=="PI1"]){
    message("")
    message("Warning: PI2 lower than PI1 (Objective increased)")
    out = T
  }
  
  if(calib$pvalue[calib$Par_orig=="PI2"]   < calib$pvalue[calib$Par_orig=="PI1"]){
    message("")
    message("Warning: PI2 lower than PI1 (Objective increased)")
    out = T
  }
  
  return(out)
  
}