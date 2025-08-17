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

