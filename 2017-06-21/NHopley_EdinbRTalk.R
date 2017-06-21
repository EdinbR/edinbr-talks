library(tidyverse)

n <- 70
categories <- 4
values <- 3
set.seed(20170621)
categories_vector <- sample(letters[1:categories], n, replace = TRUE)
values_vector <- sample(1:values , n, replace = TRUE)
df <- data.frame(categories_vector,values_vector)

ggplot(df, aes( x = categories_vector, y = values_vector)) +
  geom_dotplot(binaxis = 'y', stackdir = 'center') +
  theme( text = element_text( size = 17 ) ) +
  ggtitle( "Dot Plot" ) +
  labs( x = "Categories", y = "Values" )

ggplot(df, aes( x = categories_vector, y = values_vector)) +
  geom_jitter(width = 0.15, height = 0.15) +
  theme( text = element_text( size = 17 ) ) +
  ggtitle( "Scatterplot with Jitter" ) +
  labs( x = "Categories", y = "Values" )

ggplot(df, aes( x = categories_vector, y = values_vector)) +
  geom_count() +
  theme( text = element_text( size = 17 ) ) +
  ggtitle( "Count Plot" ) +
  labs( x = "Categories", y = "Values" )


dpxy <- function(n,dot){  
  size <- ceiling(sqrt(n))
  yc <- (dot-1) %/% size
  xc <- (dot-1) %% size
  if ((yc %% 2)==1) {xc <- (size-1)-xc} # reverse direction every second row
  yc <- yc - ((n-1) %/% size)/2 # shift centre of cluster down
  xc <- xc - (size-1)/2 # shift centre of cluster left
  return(c(xc,yc))
}

# plot sizes - move outside of the loops when all dimensions finalised.
size_dot <- 3 # dot size in scatterplot
size_bdot_x <- 0.1 # horizontal size of gap between dots 
size_bdot_y <- 0.1 # vertical size of gap between dots
size_gaps_x <- 1 # horizontal gaps between clusters
size_gaps_y <- 1 # vertical gaps between clusters

freq_table <- table(df$categories_vector,df$values_vector)
count_table <- freq_table

xlabels <- levels(factor(df$categories_vector))
ylabels <- levels(factor(df$values_vector))

for (i in 1:n) {
  df$xc[i] <- NA
  df$yc[i] <- NA
  row_name <- df$categories_vector[i] # get category of data point i
  cell_row <- match(row_name, rownames(freq_table)) # find which row in the freq_table it is
  
  col_name <- df$values_vector[i]
  cell_col <- match(col_name, colnames(freq_table))
  
  total_dots <- freq_table[cell_row, cell_col]
  current_dot <- count_table[cell_row, cell_col]
  count_table[cell_row, cell_col] <- count_table[cell_row, cell_col] - 1
  coords_xy <- dpxy(total_dots, current_dot)
  df$xc[i] <- size_gaps_x * match(row_name, xlabels) + size_bdot_x * coords_xy[1]
  df$yc[i] <- size_gaps_y * match(col_name, ylabels) + size_bdot_y * coords_xy[2]
  
}

ggplot(df, aes( x = xc, y = yc)) + 
  scale_x_continuous(breaks = size_gaps_x * c(1:length(xlabels)), labels = xlabels) +
  scale_y_continuous(breaks = size_gaps_y * c(1:length(ylabels)), labels = ylabels) +
  geom_point(size = size_dot, na.rm = TRUE) + 
  theme( text = element_text( size = 17 ) ) +
  ggtitle( "Breakdown Plot" ) +
  labs( x = "Categories", y = "Values" )
