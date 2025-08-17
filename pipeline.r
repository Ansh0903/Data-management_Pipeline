# Required libraries

install.packages("tidytext")
install.packages("tidyverse")
install.packages("topicmodels")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyr")
install.packages("tibble")
install.packages("tm")
install.packages("wordcloud")
install.packages("conflicted")

library(tidytext)
library(tidyverse)
library(topicmodels)
library(ggplot2)
library(dplyr)
library(tm)
library(wordcloud)
library(pheatmap)
library(SnowballC)
library(poweRlaw)

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

# phase 2 Creating Text Corpus and Document-Term Matrix (DTM)

corpus <- Corpus(VectorSource(data$cleaned_abstract))
dtm <- DocumentTermMatrix(corpus)
dtm <- removeSparseTerms(dtm, 0.99)  # Removal of the sparse terms

# to Validate DTM

if (nrow(as.matrix(dtm)) == 0 || ncol(as.matrix(dtm)) == 0) {
    stop("DTM is empty after removing sparse terms. Adjust the sparse threshold or check the data.")
}

# to Ensure No Empty Rows in DTM

valid_docs <- rowSums(as.matrix(dtm)) > 0
cat("Number of valid documents after filtering:", sum(valid_docs), "\n")
if (sum(valid_docs) == 0) {
    stop("No valid documents remaining after filtering.")
}

# Filtering DTM and Corresponding Data

dtm <- dtm[valid_docs, ]
data <- data[valid_docs, ]


# Phase 3
#  Fit LDA Model

k <- 5  # Number of topics
lda_model <- LDA(dtm, k = k, control = list(seed = 123))

# Ensuring Beta Matrix is a Data Frame with Unique Column Names

beta <- posterior(lda_model)$terms
beta <- as.data.frame(beta)
colnames(beta) <- make.names(colnames(beta), unique = TRUE)
rownames(beta) <- paste0("Topic_", seq_len(nrow(beta)))

# Converting Beta Matrix to Long Format

topic_terms_long <- beta %>%
    rownames_to_column("topic_label") %>%
    pivot_longer(cols = -topic_label, names_to = "term", values_to = "beta")

# Select Top 10 Terms per Topic

top_terms <- topic_terms_long %>%
    group_by(topic_label) %>%
    slice_max(beta, n = 10) %>%
    ungroup() %>%
    mutate(term = reorder_within(term, beta, topic_label))

# Visualize Top Terms per Topic

top_terms_plot <- ggplot(top_terms, aes(beta, term, fill = topic_label)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~ topic_label, scales = "free") +
    scale_y_reordered() +
    labs(title = "Top 10 Terms for Each Topic",
         x = "Probability (Beta)",
         y = "Term") +
    theme_minimal()
# Displaying the Plot

print(top_terms_plot) 



# Generating Word Clouds for Topics

for (t in unique(topic_terms_long$topic_label)) {
  # Filtering terms for the current topic

  topic_words <- topic_terms_long %>% filter(topic_label == t)
  
  # Skip the topic if no terms or all term probabilities are zero

  if (nrow(topic_words) == 0 || all(topic_words$beta == 0)) {
    cat("Skipping", t, "- No terms with nonzero frequencies.\n")
    next
  }
  # Display the word cloud directly in RStudio
  wordcloud(words = topic_words$term, freq = topic_words$beta, 
            max.words = 50, random.order = FALSE)

   # Confirmation message

  cat("Word cloud displayed for", t, "\n")
  
  # Pause to allow viewing each word cloud

  readline(prompt = "Press [Enter] to view the next word cloud...")
}

# Filter the top 100 terms with that have the highest variance

top_terms <- apply(beta, 2, var) %>% sort(decreasing = TRUE) %>% head(100)
filtered_beta <- beta[, names(top_terms)]

# Displaying the heatmap in RStudio Plots Pane

pheatmap(filtered_beta,
         cluster_rows = TRUE,
         cluster_cols = TRUE,
         main = "Heatmap of Top 100 Topic-Term Probabilities",
         fontsize_row = 10,        
         fontsize_col = 8,         
         angle_col = 90,           
         show_rownames = TRUE,
         show_colnames = TRUE,
         color = colorRampPalette(c("blue", "yellow", "red"))(50)) 
          # Divergent color scheme

# phase 4 

# Variance and Standard Deviation of Term Frequencies

term_frequencies <- colSums(as.matrix(dtm))
term_stats <- data.frame(
    Metric = c("Variance", "Standard Deviation"),
    Type = "Term_Frequency",
    Value = c(var(term_frequencies), sd(term_frequencies))
)

# Variance and Standard Deviation of Document Lengths

doc_lengths <- rowSums(as.matrix(dtm))
doc_stats <- data.frame(
    Metric = c("Variance", "Standard Deviation"),
    Type = "Document_Length",
    Value = c(var(doc_lengths), sd(doc_lengths))
)

# Combine and Save Statistics

all_stats <- bind_rows(term_stats, doc_stats)
write.csv(all_stats, "G:/My Drive/pipeline2/output/statistics.csv", row.names = FALSE)






# Prepare data for the boxplot
boxplot_data <- data.frame(
    Metric = rep(c("Term_Frequency", "Document_Length"), 
                 times = c(length(term_frequencies), length(doc_lengths))),
    Value = c(term_frequencies, doc_lengths)
)

# Generate the boxplot
boxplot_plot <- ggplot(boxplot_data, aes(x = Metric, y = Value, fill = Metric)) +
    geom_boxplot(outlier.color = "red", outlier.shape = 16, outlier.size = 2) +
    scale_y_continuous(trans = 'log10') +  # Log scale to handle skewness
    labs(
        title = "Comparison of Term Frequencies and Document Lengths",
        y = "Value (Log Scale)",
        x = "Metric"
    ) +
    theme_minimal(base_size = 12) +
    theme(
        legend.position = "none",
        plot.title = element_text(size = 14, face = "bold")
    )

# Display the boxplot in RStudio
print(boxplot_plot)  # Render the plot in the "Plots" pane







 