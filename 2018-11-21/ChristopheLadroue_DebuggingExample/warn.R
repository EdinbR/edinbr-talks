
as.numeric("456")
as.numeric("xyz")

tmp <- function(){
  cat("\nRunning with warn = ", getOption("warn"))
  
  cat("\n first part of the script")
  for(x in sample(c("42", "3.14", "2.71", "-743", "443", "xyz"), 100, replace = TRUE)){
    y <- as.numeric(x)
  }
  
  cat("\n second part of the script")
  for(x in sample(c("0","1","2"), 100, replace = TRUE)){
    y <- as.numeric(x)
  }
  cat("\n")
}
