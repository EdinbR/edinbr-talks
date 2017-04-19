# Author info:
# Caterina Constantinescu, EdinbR meeting, 19 April 2016, @ The University of Edinburgh.
# Source: http://edinbr.org/edinbr/2017/04/12/april-meeting.html
# caterina.constantinescu @ gmail.com
# info @ edinbr.org

# Step 1 : Create a Twitter app for your account, at: https://dev.twitter.com/. 
# Grab the 4 authentication codes from there, and you're ready to continue in here:

# Step 2:


# Packages ---------------------------------------------------------------

# install.packages( c("googlesheets", "twitteR", "SocialMediaLab", "RSQLite", "data.table", "plyr", "dplyr", "stringr", "pander", "tm", "SnowballC", "wordcloud", "igraph", "ggplot2", "ggrepel") )

library(googlesheets)
library(twitteR)
library(SocialMediaLab)


library(RSQLite)
library(data.table)
library(plyr)
library(dplyr)
library(stringr)
library(pander)

library(tm)
library(SnowballC)
library(wordcloud)
library(igraph)
library(ggplot2)
library(ggrepel)



# If necessary, load some RData:
# load("~/Documents/PhD/EdinbR/TwitterArchive/TwitterAnalysisData.RData")




# Functions ---------------------------------------------------------------

# Small artifice to avoid confusion later:
delete_file <- function(path){ 
  unlink(path)
  }

# Prepping text data for wordclouds:
get_hashtag_wordcloud_data <- function( hashtag = hashtag, 
                                        number_of_words_included = number_of_words_included, 
                                        exclude_most_frequent_word = TRUE,
                                        sqlite_db_path = sqlite_db_path ) {
  
  # Example: 
  # The common way - which is prone to issues, e.g., search will prly not include tweets older than 7 days:
  # hashtag_db <- searchTwitter(hashtag, n = 100)

  # Different way:
  register_sqlite_backend( sqlite_db_path )
  hashtag_db <- search_twitter_and_store( hashtag, table_name = "twitter_data_" )
  hashtag_db <- load_tweets_db( as.data.frame = TRUE, table_name = "twitter_data_" )
  
  # Preliminary cleaning:
  hashtag_db$text <- gsub("http[^[:space:]]*", "", hashtag_db$text) # Remove URLs
  hashtag_db$text <- gsub("@[A-Za-z0-9[:punct:]]+", "", hashtag_db$text) # Remove user names
  hashtag_db$text <- str_replace_all(hashtag_db$text,"[^[:graph:]]", " ") # Remove graphical chars

  
  # Set up and continue cleaning the corpus:
  twitter_corpus <- Corpus( VectorSource( hashtag_db$text ) ) %>%
    tm_map( removeWords, c("RT ", "blablabla"), mc.cores = 1 ) %>%  # add words here as necessary
    tm_map( PlainTextDocument, mc.cores = 1 ) %>%
    tm_map( content_transformer( tolower ) ) %>%
    tm_map( removeNumbers, mc.cores = 1 ) %>%
    tm_map( removePunctuation, mc.cores = 1 ) %>%
    tm_map( removeWords, stopwords( 'english' ), mc.cores = 1 ) %>%
    tm_map( stemDocument, mc.cores = 1 )

  
  ## Eliminate extra white spaces if required
  # tm_map( stripWhitespace, mc.cores = 1 ) 
  
  tdm <- TermDocumentMatrix(twitter_corpus)
  
  # Ideas perhaps for later use outside this function:
  # tdm$dimnames$Terms
  # findAssocs(tdm, "someTerm", 0.5)
  
  tdm_matrix <- as.matrix(tdm)
  tdm_rowsums <- sort( rowSums( tdm_matrix ), decreasing = TRUE )
  word_frequencies <- data.frame( word = names( tdm_rowsums ), freq = tdm_rowsums )
  setDT(word_frequencies)
  
  
# Exclude most frequent word, as it is usually the hashtag itself: pointless to plot, and would also make the other words artificially appear far smaller on the plot (i.e., less frequent) in comparison:
  if ( exclude_most_frequent_word ) { 
    word_frequencies <- word_frequencies[ order(- freq), ] %>% 
      slice( 2 : number_of_words_included ) 
    
  } else {
    word_frequencies <- word_frequencies[ order(- freq), ] %>% 
      slice( 1 : number_of_words_included ) 
  }

  delete_file( sqlite_db_path ) # Not needed any more. Just used this as tool to download data.
  return(word_frequencies)
  
}



# 'Manually' downloaded Twitter data archive  -------------------------------------

# From Settings and privacy -> Your Twitter data -> Twitter archive
tw_dat <- fread("/home/caterina/Documents/PhD/EdinbR/TwitterArchive/tweets.csv")
names(tw_dat)

table( duplicated ( tw_dat$tweet_id ) ) # No duplicates. 

# Interestingly, does not contain number of retweets or likes for a given tweet. So, not good enough.



# TwitteR package login info ----------------------------------------------

# Source: http://bigdatainnovation.blogspot.co.uk/2016/12/how-to-analyse-twitter-connections.html
# Generate these codes from your Twitter app via http://dev.twitter.com -> My apps -> Create New App


apiKey <- "String1"
apiSecret <- "Sring2"
accessToken <- "String3"
accessSecret <- "String4"
setup_twitter_oauth(apiKey, apiSecret, accessToken, accessSecret)



# Pulling out data with package TwitteR -------------------------------------------

Edinburgh_R_usergroup <- getUser("edinb_r")
str(Edinburgh_R_usergroup)

# Despite room discussion, looks like one can actually try any user/account name here, e.g.,
str( getUser("DataFest_") )


# Social aspect ---------------------------------------------------


edinbr_friends <- lookupUsers( Edinburgh_R_usergroup$getFriendIDs() ) 
# Example:
str(edinbr_friends[[9]])
# Friends here = people *we* are following

edinbr_followers <- lookupUsers( Edinburgh_R_usergroup$getFollowerIDs() ) 
str(edinbr_followers[[42]])

# Most "popular" people we're following?
# Cumulative nb. of favorites (/likes) achieved by each friend:
friend_favorites <- data.frame( NbLikes = sapply(edinbr_friends, favoritesCount) )
# Friend IDs:
friend_IDs <- data.frame( Name = sapply(edinbr_friends, name) )

friend_favorites$PID <- rownames(friend_favorites)
friend_IDs$PID <- rownames(friend_IDs)

edinbr_friends_DF <- setDT( join( friend_IDs, friend_favorites, by = "PID") )
edinbr_friends_DF <- edinbr_friends_DF[ order(- NbLikes), ]

# The stars...
edinbr_friends_DF[1:20, ]
# The less favourite'd people...
list_end <- nrow(edinbr_friends_DF)
edinbr_friends_DF[ (list_end - 20) : list_end, ]


# Which of these people that we follow, are following us back?
followers <- data.frame( Followers = sapply( edinbr_followers, name ) )
followers$PID <- rownames(followers)

following_us_back <- join(edinbr_friends_DF, followers, by = "PID", type = "inner")
following_us_back$shall_we_plot_this <- ifelse(following_us_back$NbLikes > 19000,
                                               as.character(following_us_back$Name), 
                                               NA)

# Now express some of that info visually (warning is expected):
ggplot( following_us_back[1:50, ], 
        aes( x = 1:50,
             y = NbLikes, 
             label = shall_we_plot_this ) ) + 
  geom_point() +
  geom_label_repel( segment.size = 0, force = 1, 
                    color = "red", alpha = 0.85 ) +
  xlab("Friend index") + ylab("Number of likes")



# Two interesting functions, but currently not super-well documented:
mentions(n = 5, maxID = NULL, sinceID = NULL) 
# Seems to count backwards in time, i.e., you get 5 (or n) most recent ones.
retweetsOfMe(n = 5, maxID = NULL, sinceID = NULL)




# Get your own tweets from your account -----------------------------------


number_to_extract <- Edinburgh_R_usergroup$statusesCount
our_tweets <- userTimeline("edinb_r", 
                           n = number_to_extract, 
                           includeRts = T, 
                           excludeReplies = F)
str(our_tweets[[1]])


# Prepare nested URL information:
url_list_of_lists <- sapply(our_tweets, "[[", "urls" )

table( unlist( lapply( url_list_of_lists, nrow ) ) )
null_index <- lapply(url_list_of_lists, nrow) == 0

# Going one level deeper within the list of lists, to grab expanded URLs specifically:
url_list <- sapply( url_list_of_lists, "[[", "expanded_url" )
# Replace char(0), with NA, to preserve list length (otherwise char(0) list elements are chopped off):
url_list[null_index] <- NA 


# Concatenate multiple URLs (max 2 here), when they occur for the same tweet, into same cell:
multiple_urls <- lapply(url_list_of_lists, nrow) > 1
url_list[multiple_urls] <- lapply( url_list[multiple_urls], function(x){ paste("URL #1: ",
                                                                               x[[1]],
                                                                               "+ URL #2: ",
                                                                               x[[2]], sep = " " ) } )

url_vector <- unlist(url_list)
# Let's look at a few:
url_vector[ sample( 1 : length(url_vector), 10, replace = F ) ]



# A way to keep extracting data from the our_tweets object:
text <- sapply(our_tweets, "[[", "text")
text[1:5]

platform <- sapply(our_tweets, "[[", "statusSource")
platform[1:5]


# But here is the quick n dirty way:
edinbr_data <- twListToDF(our_tweets) 
names(edinbr_data)

# But this does not have URL info. Good thing we extracted it earlier.
edinbr_data$URL <- url_vector

# Some cleaning:
edinbr_data$platform <- str_replace_all( edinbr_data$statusSource, 
                                         c('<a.+">' = "", 
                                           '</a>' = "") )
edinbr_data$statusSource <- NULL
table( edinbr_data$platform )




# Some strange issues -----------------------------------------------------


# Checking data for anything unusual:

### ISSUE 1: isRetweet and retweeted show the same thing...

# Maybe they do not mean what we think they do?
table( edinbr_data$isRetweet, edinbr_data$retweeted )
?twitteR::status # check info on this class


# Any insight from checking downloaded archive instead?
# Joining that with TwitteR data, and looking at 'retweeted_status_id',
# since, if a case is a retweet, it should have some 'retweeted_status_id', otherwise it shouldn't:

setnames( tw_dat, "tweet_id", "id" )
full_tw_dat <- setDT( join( edinbr_data,
                            tw_dat[, .SD, .SDcols = c("id", "text", "retweeted_status_id")], 
                            by = c("id", "text") ) )

setcolorder(full_tw_dat, c( "id", "text", "created", 
                            "replyToSID", "replyToSN", "replyToUID", 
                            "retweeted", "isRetweet", "retweeted_status_id", "retweetCount", 
                            "favorited", "favoriteCount", 
                            "platform", "URL", "truncated", 
                            "longitude", "latitude", "screenName" ) )

# If retweeted_status_id == "", assign NA to that cell instead:
full_tw_dat[ retweeted_status_id == "", retweeted_status_id := NA ] 


# Now to see if retweet info matches from the two separate sources:
retweeted_status_id_present <- ! is.na(full_tw_dat$retweeted_status_id)
isRetweet_bool <- full_tw_dat$isRetweet

pandoc.table( data.frame( table( retweeted_status_id_present, 
                                 isRetweet_bool) ), 
              style = "grid" ) # Not entirely... 

discrepancy <- which( retweeted_status_id_present == FALSE & isRetweet_bool == TRUE )
pandoc.table( full_tw_dat[discrepancy, .SD, .SDcols = c("id", "retweeted", "isRetweet", 
                                                        "retweeted_status_id",  "retweetCount" ) ] ) 
# Looks like retweeted_status_id (from manually downloaded data) is just missing for some rtwts...




### ISSUE 2: isRetweet and retweeted can both be FALSE when retweetCount > 0...

summary(full_tw_dat$retweetCount)
aggregate( retweetCount ~ isRetweet + retweeted, data = full_tw_dat, FUN = sum)
# When both isRetweet and retweeted are FALSE, retweetCount should have been 0?


# All that isRetweet + retweeted seem to do, both of them, is capture whether there is an "RT" label saved in the text of the tweet... 
tweet_contains_RT_label <- str_detect(full_tw_dat$text, "RT @")
aggregate( tweet_contains_RT_label ~ isRetweet + retweeted, data = full_tw_dat, FUN = sum )

# Conclusion - probably best to stick with retweetCount values, rather than the booleans...



# Some simple plots showing trends over time ------------------------------

full_tw_dat[ , month := substr( months( created ), 1, 3) ]
full_tw_dat[ , month := ordered(month, levels = c( "Jan", "Feb", "Mar", "Apr", 
                                                   "May", "Jun", "Jul", "Aug", 
                                                   "Sep", "Oct", "Nov", "Dec")) ]

full_tw_dat[ , quarter := quarter( created ) ]
full_tw_dat[ , year := year( created ) ]


# Convert to long format:
full_tw_dat_long <- data.table::melt(full_tw_dat, 
                             id.vars = c("month", "year"), 
                             measure.vars = c("favoriteCount", "retweetCount"))


ggplot( full_tw_dat_long, aes( x = month, y = value, fill = variable ) ) + 
  stat_summary( fun.y = "mean", geom = "bar",  alpha = 0.6 ) + facet_wrap(~ year) +
  xlab("Month") + ylab("Average favourite / retweet count") + 
  ggtitle("Engagement (average no. tweets and favs) over time") +
  scale_fill_manual(name = "Engagement", values = c("retweetCount" = "orange",
                                                    "favoriteCount" = "black") ) 




# Adding context: merging Twitter data with meeting log from Google Sheets ------------------------------------------

# This sheet contains the topics of the meetings and the attendance level, which I have been tracking over time
# Same idea can apply to any interesting external data you have, and which you want to link up with Twitter activity

my_sheets <- gs_ls() # This will now ask for authentification
# Check out titles of sheets, and use in next line:

meeting_log <- gs_title("EdinbR meeting log")
meeting_log <- gs_read(meeting_log)
meeting_log <- meeting_log[1:25, ] # Random notes beyond row 25

meeting_log$Date <- as.POSIXct( as.Date( meeting_log$Date, format = "%d/%m/%Y") )


# Perform rolling join with tweet data, i.e., match tweets with log entries based on closest date:
setDT(meeting_log)

# Create column copy in both datasets, to perform join on.
full_tw_dat[ , MatchDate := created]
meeting_log[ , MatchDate := Date]

setkey(full_tw_dat, MatchDate)    ## set the column(s) to perform the join on
setkey(meeting_log, MatchDate)    ## same as above

# Perform rolling join, by the nearest dates:
tw_dat_with_meetings <- meeting_log[ full_tw_dat, roll = "nearest" ] 

# Let's see what tweeting intervals are covered within the "nearest" rolling join:
upper_bound <- setDT( aggregate( created ~ Date, FUN = max, data = tw_dat_with_meetings ) )
lower_bound <- setDT( aggregate( created ~ Date, FUN = min, data = tw_dat_with_meetings ) )

setnames( upper_bound, c( "MeetingDate", "MaxTweetDate" ) )
setnames( lower_bound, c("MeetingDate", "MinTweetDate" ) )

check <- data.table(lower_bound, MaxTweetDate = upper_bound$MaxTweetDate)
setcolorder( check, c( "MinTweetDate", "MeetingDate", "MaxTweetDate" ) )

# Subtract dates to get padding around meetings:
check[ , pre_padding := difftime( as.Date( MeetingDate ), as.Date( MinTweetDate ) ) ]
check[ , post_padding := difftime( as.Date( MaxTweetDate ), as.Date( MeetingDate ), unit  = "days" ) ]

pandoc.table( check[1:10, ], style = "grid", split.tables = 200 )
# looks ok



names(tw_dat_with_meetings)
dat_short <- tw_dat_with_meetings[ , .SD, .SDcol = c("Date", "DescrSpeaker1", "DescrSpeaker2", "Attendance", 
                                                     "created", "id", "text", "retweetCount", "favoriteCount", 
                                                     "platform")]

dat_short[ , MeetingTopic := paste(DescrSpeaker1, DescrSpeaker2, sep = " + ") ]
dat_short[ , DescrSpeaker1 := NULL]; dat_short[ , DescrSpeaker2 := NULL]

tweeting_activity <- aggregate(id ~ MeetingTopic, FUN = length, data = dat_short)
setnames( setDT( tweeting_activity ), c( "MeetingTopic", "tweeting_activity") )
dat_short <- join(dat_short, tweeting_activity, by = "MeetingTopic" )
head(dat_short)

summary_of_meetings <- ddply(dat_short, 
                             "MeetingTopic", 
                             function(x) colMeans( x [ c( "retweetCount", 
                                                          "favoriteCount",
                                                          "tweeting_activity", 
                                                          "Attendance" ) ] ) )

summary_of_meetings_long <- data.table::melt(summary_of_meetings,
                                             id.vars = "MeetingTopic",
                                             measure.vars = c( "retweetCount", 
                                                               "favoriteCount",
                                                               "tweeting_activity", 
                                                               "Attendance") )

# Chop off chars from extra long meeting topics:
summary_of_meetings_long$MeetingTopic <- substr( summary_of_meetings_long$MeetingTopic, 1, 20 )
summary_of_meetings_long$hjust_values <- ifelse(summary_of_meetings_long$MeetingTopic == "Managing many models" |
                                                  summary_of_meetings_long$MeetingTopic == "Inaugural planning m" ,
                                                1, 
                                                0 )


ggplot(summary_of_meetings_long, aes( x = MeetingTopic, y = value, fill = MeetingTopic) ) + 
  geom_bar(stat = "identity", show.legend = F) + 
  facet_wrap(~ variable) +
  theme(axis.text.x = element_text( angle = 45, hjust = 1) ) 



# World's smallest analysis -----------------------------------------------


names(summary_of_meetings)

# Create a groping for topics:
TopicType <- c( rep( "programmy", 7 ),   
                rep( "half_n_half", 2 ),
                NA, "programmy", "half_n_half", 
                rep( "statsy", 2 ),   
                rep( "half_n_half", 2 ),      
                rep( "programmy", 2 ),   
                rep( "statsy", 2 ),
                "programmy",   
                rep( "half_n_half", 2 ) ) 


summary_of_meetings$TopicType <- mapvalues(summary_of_meetings$MeetingTopic, 
                                           from = summary_of_meetings$MeetingTopic, 
                                           to = TopicType)
table(summary_of_meetings$TopicType)


summary( lm( Attendance ~ retweetCount + favoriteCount + TopicType, data = summary_of_meetings ) )
# Sadly, nothing going on.



# Hashtag wordclouds ---------------------------------------------

# Using ggplot2 and ggrepel. PS. Thanks Mhairi!
# http://mhairihmcneill.com/blog/2016/04/05/wordclouds-in-ggplot.html


hashtag_to_use <- "#ConfessionsOfAJuniorDoctor"
# "#MyFavoritePlaceIn3Words"
# "#wednesdaywisdom"
# "#Cannes2017"
# "#DataFest17"
  
# Run this but be prepared to wait some time...
hashtag_data <- get_hashtag_wordcloud_data( hashtag = hashtag_to_use,
                                            number_of_words_included = 200,
                                            exclude_most_frequent_word = TRUE,
                                            sqlite_db_path = "/home/caterina/Desktop/someFile" )

ggplot( hashtag_data, aes(x = 1, y = 1, size = freq, label = word, color = freq) ) +
  geom_text_repel( segment.size = 0, force = 3 ) +
  scale_size( range = c( 2, 15 ), guide = FALSE ) +
  scale_color_continuous( guide = FALSE ) +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = NULL) +
  labs(x = '', y = '') +
  ggtitle( paste( "When you think of", hashtag_to_use, ", you think of...") ) +
  theme_classic( base_size = 17 )









# Twitter networks with package 'SocialMediaLab'  -----------------------------------------------

# SocialMediaLab draws on twitteR, instaR, Rfacebook, and igraph to provide an integrated 'work flow' for collecting different types of social media data, and creating different types of networks out of these data. 

# Example
# Careful about what search terms you type in !!
# "The Twitter Search API searches against a sampling of recent Tweets published in the past 7 days."
actor_network <- Authenticate("twitter", 
                              apiKey, 
                              apiSecret, 
                              accessToken, 
                              accessTokenSecret = accessSecret) %>% 
  Collect(ego = F, searchTerm = "EdinbR OR DataFest17", numTweets = 500, language = "en") %>%
  Create( type = "Actor" ) # in theory supports "actor", "bimodal", "dynamic", "semantic" and "ego", but Dynamic Twitter networks are not currently implemented in the SocialMediaLab package. This will be implemented in a future release.

print(actor_network)
# plot(actor_network) # Only for little data.
igraph::tkplot(actor_network, vertex.color = "yellow", 
               edge.color = "blue", 
               vertex.frame.color = "red",
               vertex.size = 20 )



# This function collects data from Twitter based on hashtags or search terms, and structures the data into a data frame of class dataSource.twitter, ready for creating networks for further analysis. Collect collects public 'tweets' from Twitter using the Twitter API. The function then finds and maps the relationships of entities of interest in the data (e.g. users, terms, hashtags), and structures these relationships into a data frame format suitable for creating unimodal networks (CreateActorNetwork), bimodal networks (CreateBimodalNetwork), and semantic networks (CreateSemanticNetwork).
# The maximum number of tweets for a single call of CollectDataTwitter is 1500. [...]
# A variety of query operators are available through the Twitter API. For example, "love OR hate" returns  any  tweets  containing  either term (or both).  


# Getting trends based on locations ---------------------------------------


# Yahoo! Where On Earth ID = woeid
woeids <- availableTrendLocations()

Edinburgh <- woeids[woeids$name == "Edinburgh", "woeid"]

# What's trending in Edinburgh?
sort( getTrends(Edinburgh, exclude = NULL)[[1]] )

# Vs. worldwide?
the_world <- woeids[woeids$name == "Worldwide", "woeid"]
sort( getTrends(the_world, exclude = NULL)[[1]] )




# Further info ------------------------------------------------------------



# Future directions:
# Maybe Google Analytics website traffic to be merged here as well?

# Useful resources:
# http://www.rdatamining.com/docs/RDataMining-slides-twitter-analysis.pdf?attredirects=0&d=1
# http://mhairihmcneill.com/blog/2016/04/05/wordclouds-in-ggplot.html