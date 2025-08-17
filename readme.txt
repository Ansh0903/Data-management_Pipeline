README for dmap_Pipeline Project
Project Overview

The aim of the project is to process raw ,unstructured data, preprocess the data through various making it ready for topic modelling with LATENT DIRICHLET ALLOCATION(LDA). Which consistent of various drscriptive statistics, visulisation and output files ofr the further analysis. the whole pipleine is developed with R. It can handle the dataset that is related research abstracts. This is create using apprentiship_abstracts csv file and and can work smoothly with other similar dataset like "genAI"


File Structure
dpmas_pipeline.Rproj: This the RStudio project file made for managing the workspace.
pipeline.R: This main is script that contains the complete pipeline code start to end.
/data: This directory contains input datasets, apprenticeship_abstracts.csv and genAI.csv file
/output: This is the directory where output files like top_term_plot, heatmap_plot, word_cloud etc. are saved.
top_terms.csv: Contains the top terms for each topic.
statistics.csv: Contains variance and standard deviation metrics for the term frequencies and document lengths in the csv file.
boxplot_comparison.png: Box plot it is the comparision between term frequencies and document lengths.
wordcloud_Topic_(1,2,3,4,5).png: Word cloud for each topic.
/readme: Contains this README file readme.md.
Requirements
R (Version >= 4.0)
Required R packages:

tidytext, tidyverse, topicmodels, ggplot2, dplyr, tm, wordcloud, pheatmap, SnowballC, poweRlaw
How to Run the Pipeline
Set Up the Environment:

Installing all the required R packages listed above.
Open the RStudio project file: dmap_pipeline.Rproj.
Input Dataset:

 apprenticeship_abstracts.csv and genAI_abstracts.csv in the /data directory.
Run the Pipeline:

Open pipeline.R in RStudio.
Run the script line by line or as a batch.
Output Files:

Results and visualizations will be saved in the /output directory.
Check the following outputs:
CSV Files: top_terms.csv, statistics.csv, clean_abstract,topic.csv
Visualizations: Heatmap, word clouds, top_term_plot and box plot can be seen in the plot plane of Rstudio and in the /output directory.
Pipeline Features
Custom Stop Words:

A custom list of stop words is also defined and used to clean the text.
Whitelisted terms ensure that the critical words remain in the data.
Text Preprocessing:

Converting text to lowercase.
Removal of punctuation and extra whitespace.
Removal of stop words and applies stemming.
Topic Modeling:

Using LDA to identify patterns and topics within the text.
Outputs top terms for each topic and visualizations.
Descriptive Statistics:

Calculating variance and standard deviation for term frequencies and document lengths.
These metrics are visualised using a box plot.
Visualization:

Generates word clouds for each topic.
Creates a heatmap for topic-term probabilities.
Notes
The number topics(k=5) is adjustable in the LDA model as per the dataset requirements.