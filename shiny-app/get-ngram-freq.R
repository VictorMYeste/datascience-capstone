# title: "Data Science Capstone"
# author: "Victor Yeste"
# date: "10/19/2021"

library(tm)
library(dplyr)
library(stringi)
library(stringr)
library(quanteda)
library(data.table)

# Load training data

con <- file("../en_US/en_US.twitter.txt", open = "r")
twitter <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
con <- file("../en_US/en_US.news.txt", open = "r")
news <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
con <- file("../en_US/en_US.blogs.txt", open = "r")
blogs <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)

# Show number of lines per file

length(twitter)
length(news)
length(blogs)

# Get data samples

set.seed(11011)
sampleSize <- 0.2

twitter.sample <- sample(twitter, length(twitter) * sampleSize, replace = FALSE)
news.sample <- sample(news, length(news) * sampleSize, replace = FALSE)
blogs.sample <- sample(blogs, length(blogs) * sampleSize, replace = FALSE)

# Remove non-EN characters

twitter.sample <- iconv(twitter.sample, "latin1", "ASCII", sub = "")
news.sample <- iconv(news.sample, "latin1", "ASCII", sub = "")
blogs.sample <- iconv(blogs.sample, "latin1", "ASCII", sub = "")

# Remove outliers

twitter.1quant <- quantile(nchar(twitter.sample), 0.25)
twitter.3quant <- quantile(nchar(twitter.sample), 0.75)
twitter.sample <- twitter.sample[nchar(twitter.sample) > twitter.1quant
               & nchar(twitter.sample) < twitter.3quant]
news.1quant <- quantile(nchar(news.sample), 0.25)
news.3quant <- quantile(nchar(news.sample), 0.75)
news.sample <- news.sample[nchar(news.sample) > news.1quant
               & nchar(news.sample) < news.3quant]
blogs.1quant <- quantile(nchar(blogs.sample), 0.25)
blogs.3quant <- quantile(nchar(blogs.sample), 0.75)
blogs.sample <- blogs.sample[nchar(blogs.sample) > blogs.1quant
               & nchar(blogs.sample) < blogs.3quant]

# Combine data

sampleData <- c(twitter.sample, news.sample, blogs.sample)

# Clean data

sampleData <- tolower(sampleData)
sampleData <- gsub("\\S+[@]\\S+", "", sampleData, ignore.case = FALSE, perl = TRUE)
sampleData <- gsub("@[^\\s]+", "", sampleData, ignore.case = FALSE, perl = TRUE)
sampleData <- gsub("#[^\\s]+", "", sampleData, ignore.case = FALSE, perl = TRUE)
sampleData <- gsub("^\\s+|\\s+$", "", sampleData)
sampleData <- stripWhitespace(sampleData)

# Remove bad words

con <- file("data/bad-words.txt", open = "r")
badWords <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
badWords <- iconv(badWords, "latin1", "ASCII", sub = "")
close(con)
sampleData <- removeWords(sampleData, badWords)

# Write sample data

con <- file("data/en_US.sample.txt", open = "w")
writeLines(sampleData, con)
close(con)

# Create corpus and tokens

myCorpus <- corpus(sampleData)

myTokens <- tokens(
    myCorpus,
    remove_numbers = TRUE,
    remove_punct = TRUE,
    remove_symbols = TRUE,
    remove_url = TRUE,
    include_docvars = TRUE
)

# Create n-gram frequencies

get3TopNGrams <- function(corpusDFM) {
    noDuplicated <- !duplicated(corpusDFM$token)
    corpusDFM.dup.1 <- corpusDFM[!noDuplicated,]
    ngram.1 <- corpusDFM[noDuplicated,]
    noDuplicated <- !duplicated(corpusDFM.dup.1$token)
    corpusDFM.dup.2 <- corpusDFM.dup.1[!noDuplicated,]
    ngram.2 <- corpusDFM.dup.1[noDuplicated,]
    noDuplicated <- !duplicated(corpusDFM.dup.2$token)
    ngram.3 <- corpusDFM.dup.2[noDuplicated,]
    return(rbind(ngram.1, ngram.2, ngram.3))
}

getFrequencies <- function(myTokens, n = 1) {
    myTokens.ngrams <- tokens_ngrams(myTokens, n)
    corpusDFM <- dfm(myTokens.ngrams)
    corpusDFM <- colSums(corpusDFM)
    total <- sum(corpusDFM)
    corpusDFM <- data.frame(names(corpusDFM),
                         corpusDFM,
                         row.names = NULL,
                         check.rows = FALSE,
                         check.names = FALSE,
                         stringsAsFactors = FALSE
    )
    colnames(corpusDFM) <- c("token", "n")
    corpusDFM <- mutate(corpusDFM, token = gsub("_", " ", token))
    corpusDFM <- mutate(corpusDFM, percent = corpusDFM$n / total)
    if (n > 1) {
        corpusDFM$outcome <- word(corpusDFM$token, -1)
        corpusDFM$token <- word(corpusDFM$token, 1, n - 1, fixed(" "))
    }
    setorder(corpusDFM, -n)
    corpusDFM <- get3TopNGrams(corpusDFM)
    return(corpusDFM)
}

# n-grams: 1

firstWords <- sapply(myTokens, function(x) x[1])
ngrams.1 <- getFrequencies(tokens(firstWords), 1)
saveRDS(ngrams.1, "data/ngrams.1.RData")

# n-grams: 2

ngrams.2 <- getFrequencies(myTokens, 2)
saveRDS(ngrams.2, "data/ngrams.2.RData")

# n-grams: 3

ngrams.3 <- getFrequencies(myTokens, 3)
saveRDS(ngrams.3, "data/ngrams.3.RData")

# n-grams: 4

ngrams.4 <- getFrequencies(myTokens, 4)
saveRDS(ngrams.4, "data/ngrams.4.RData")