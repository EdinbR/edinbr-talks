quickSort <- function(v){
  
  n <- length(v) # size of the vector
  
  if( n <= 1 ) return( v )
  if( n == 2 ) return( c( min(v), max(v) ) )
  
  # partition
  pivot <- v[ ceiling(n / 2) ]
  
  left <- v[v < pivot]
  right <- v[v > pivot]
   
  c( quickSort(left), quickSort(right) )
}

testQuicksort <- function(){
  
  v <- sample(100, 10, replace = FALSE)
  
  cat("\nTesting on v = [", paste0(v, collapse = ", "), "]")
  
  quicksorted <- quickSort(v) # using our function
  
  sorted <- sort(v) # using base R
  
  works <- identical(sorted, quicksorted) # should be identical
  
  cat("\n\tGot quicksorted = [", paste0(quicksorted, collapse = ", "), "]")
  
  if(works){
    cat("\n\t it works.")
  } else {
    cat("\n\t it doesn't work.")  
  }
  
  invisible(v)
}



















# /!\ For pedagogical purposes only. Purposefully buggy and limited to vectors not containing duplicated values.