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
