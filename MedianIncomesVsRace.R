# Install the following packages
#install.packages(c("ggplot2","ggpubr", "tidyverse", "broom")) 
# This should be done one and then delete it

# Load the packages into R
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)

#********** MEDIAN HOUSEHOLD INCOMES (2002-2020) VS. RACE **********


# Step 0: Define your hypothesis
# H0: u1 = u2 = u3 (i.e. all the population means are equal)
# Ha: Not all the population means are equal

# Step 1: Import data into RStudio
income_df <- read.csv("~/Desktop/med_income_stacked.csv")
summary(income_df) 

# Step 2: Data visualization using Boxplot (Note: you can explore dotplots, histogram etc.)
boxplot(Median.Income ~ Race, data=income_df, main="Median Income by Race (2002-2020)",
        xlab="Race", ylab="Median Income")

# Step 3: Perform the ANOVA test
# We can perform on ANOVA in R using the aov() function. This will calculate the test statistic for ANOVA
income_anova <- aov(Median.Income ~ Race, data = income_df) #Runs the ANOVA test
summary(income_anova) # Outputs the ANOVA table

# Step 4: Conclusion
# We can conclude that there are significant differences 
# in median incomes between the four races


# Step 5: Assumptions Test
# The first assumption is to check for the homogeneity of variance (i.e., are the pop. variance the same)
# Graphical analysis to check for variance using the Residuals vs Fitted plot
plot(income_anova, 1)
# Interpretation: Points 65, 43, and 44 are detected as outliers, which can severely affect the normality and variance assumptions

# We can use a test called the Levene's test to check for variance
library(car)
leveneTest(Median.Income ~ Race, data = income_df) # test for variance
# The results show that we do not meet our assumptions
# Our p-value is less than the significance level of 0.05.
# This means that there is evidence to suggest that the variance across methods is statistically significantly different.
# Therefore, we cannot assume the homogeneity of variances in the different treatment groups

# The second assumption is to check for normality (i.e., is our dataset normally distributed). 
# The normal probability plot of residuals (Normal Quantile plot) is used to check for normality. 
# The points on the plot should approximately follow a straight line.
plot(income_anova, 2, col = 2)
# Interpretation: The points on the plot do not follow a straight line, 
# so we cannot assume normality. We will conduct another test to check our normality assumption.

# The Shapiro-Wilk test on the ANOVA residuals is used to confirm normality
# Extract the residuals
income_residuals <- residuals(object = income_anova)
# Run Shapiro-Wilk test
shapiro.test(x = income_residuals)
# Interpretation: W = 0.93216, p = 0.0002625 (< 0.05) which indicates that that normality assumption is violated.
# Note: p-value is less than 0.05 so our normality assumption IS violated.

# ********** Kruskal-Wallis test **********
# The Kruskal-Wallis test is recommended when the assumptions of one-way ANOVA test are not met
kruskal.test(Median.Income ~ Race, data = income_df)

#As the p-value (2.2e-16) is less than the significance level 0.05, we can conclude that there are significant 
#differences between the treatment groups (races).


# ********** Multiple Comparison Tests **********
# The pairwise.t.test function helps us to perform the F
pairwise.t.test(income_df$ Median.Income, income_df$Race, p.adj = "bonf") #"bonf" means bonerroni

# Another method for Multiple Comparison is Tukey's Honest Significant Differences (Tukey's HSD)
TukeyHSD(income_anova, p.adj = "bonf")

#Overall Interpretation: 
# Since all p-values are less than 0.05 (alpha), we can reject the null hypothesis that
# the median income for all race combinations (i.e. Black-Asian, Hispanic-Asian, etc.) are equal.

# In other words, all the median incomes are different for all races.


