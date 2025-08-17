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
