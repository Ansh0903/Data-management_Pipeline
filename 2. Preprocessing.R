# phase 1 Loading the Dataset

data <- read.csv("data/apprenticeship_abstracts.csv")

#  Removing Empty Abstracts

data <- data[!is.na(data$Abstract) & data$Abstract != "", ]

#  De-duplicate Entries

data <- data %>% distinct(Abstract, .keep_all = TRUE)

#  Defining Custom Stop Words

custom_stop_words <- c("apprenticeship", "study", "research", "analysis", "project", 
                       "training", "education", "students", "learning", "skills")

#  Defining Whitelist for Critical Terms to Preserve

whitelist <- c("education", "indigenous-centric", "apprenticeship")

# Preprocessing text

data$cleaned_abstract <- tolower(data$Abstract)  # Converts to lowercase
data$cleaned_abstract <- gsub("[^a-z\\s]", "", data$cleaned_abstract, perl = TRUE)  # Removing punctuation
data$cleaned_abstract <- gsub("\\s+", " ", data$cleaned_abstract, perl = TRUE)  # Removing extra spaces
data$cleaned_abstract <- trimws(data$cleaned_abstract)  # Triming whitespace

# Removing  stop words

data$cleaned_abstract <- removeWords(data$cleaned_abstract, c(stopwords("en"), custom_stop_words))

# stemming

data$cleaned_abstract <- wordStem(data$cleaned_abstract, language = "en")



# Inspect Preprocessed Data

cat("Sample Cleaned Abstracts:\n", sample(data$cleaned_abstract, 3), "\n")  # Randomly sample 3 abstracts

# Tokenization and Word Frequency

word_counts <- data %>%
  unnest_tokens(word, cleaned_abstract) %>%
  count(word, sort = TRUE)

print(head(word_counts, 20))  # Top 20 frequent words

# Summarize the Dataset

unique_docs <- nrow(data)
avg_doc_length <- mean(nchar(data$cleaned_abstract))
unique_tokens <- length(unique(unlist(strsplit(paste(data$cleaned_abstract, collapse = " "), " "))))

cat("Summary of Preprocessed Data:\n")
cat("Unique Documents:", unique_docs, "\n")
cat("Average Document Length (in characters):", avg_doc_length, "\n")
cat("Total Unique Tokens:", unique_tokens, "\n")
