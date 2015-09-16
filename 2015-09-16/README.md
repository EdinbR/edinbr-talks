Talks at this meeting were:


## The plyr package (Nick Kennedy)

One of the more common tasks when processing data is to take a data object, split it up in some way, do something to the component pieces and then join the result back up together. This is often referred to as the ‘split-apply-combine’ paradigm. Base R offers a number of useful functions for doing this, including lapply and sapply. The plyr package extends this and offers a whole family of -ply functions which take vectors, lists, arrays or data.frames as input and operate on them in a consistent manner. This talk aims to give an overview of how to use plyr to make data processing easier, and also introduces some of the additional functionality that plyr offers including easy ways to view progress of a task and to parallelise code where multiple cores are available.

Slides available in [Rmarkdown](Kennedy_plyr-talk.Rmd), [Markdown](Kennedy_plyr-talk.md) and [HTML](https://rawgit.com/NikNakk/edinbr-talks/Kennedy-talk/2015-09-16/Kennedy_plyr-talk.html) formats.

## Analysing text data with R (Mhairi McNeill)

A very quick introduction to the tm package, for doing text mining. I'll cover reading in data, cleaning the data and some basic analysis you can do in R.

Code and data available at [Mhairi's github page](https://github.com/mhairi/tm_tutorial).