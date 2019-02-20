############################################################################################################
# This script compares the relationship between neutral diversity (4-fold degenerate pi) and recombination rate
# in the full set of loci vs the set of loci with no hard sweeps:
#   Step 1.) Plot the data and perform linear regressions for each chromosome.
#   Step 2.) Perform analysis of covariance (ANCOVA) to assess differences in the slope and y-intercepts of the 
#          regression lines of local recombination rate and neutral diversity between the sets of loci.
############################################################################################################

library(ggplot2)
library(gridExtra)
#Provide data separately for autosomal and x chromosome analyses:
chr2 <- read.table("/Users/Katharine Korunes/Google Drive/Project_BackgroundSelection/FourfoldPi_and_RecombRates/plot_all_vs_nosweep_chr2.txt", header=TRUE)
chrXR <- read.table("/Users/Katharine Korunes/Google Drive/Project_BackgroundSelection/FourfoldPi_and_RecombRates/plot_all_vs_nosweep_chrXR.txt", header=TRUE)

# Plot the data:
pltchr2 <- ggplot(data=chr2, aes(x=REC_RATE, y=AVG_PI)) + geom_point(na.rm = TRUE) + geom_smooth(aes(color=Set), method=lm)+
  geom_point(aes(color=Set), size = 2)+
  scale_y_continuous(expand = c(0, 0), limits = c(0, 0.12))+
  scale_x_continuous(expand = c(0, 0), limits = c(0, 18), breaks = seq(0, 18, by = 2))+
  coord_fixed(ratio=100)+
  theme_classic()+
  scale_color_manual(values = c("grey","steelblue4"))+
  labs(title="Chromosome 2")+
  labs(x="", y="")
pltchrXR <- ggplot(data=chrXR, aes(x=REC_RATE, y=AVG_PI)) + geom_point(na.rm = TRUE) + geom_smooth(aes(color=Set), method=lm)+
  geom_point(aes(color=Set), size = 2)+
  scale_y_continuous(expand = c(0, 0), limits = c(0, 0.12))+
  scale_x_continuous(expand = c(0, 0), limits = c(0, 14), breaks = seq(0, 14, by = 2))+
  coord_fixed(ratio=100)+
  theme_classic()+
  scale_color_manual(values = c("grey","steelblue4"))+
  labs(title="Chromosome XR")+
  labs(x="", y="")
grid.arrange(pltchr2, pltchrXR, nrow = 2, bottom="Recombination Rate (cM/mB)", left="Average 4-fold degenerate pi per gene span")

#Perform Ancova:
#chromosome 2:
score1 <- lm(AVG_PI~REC_RATE*Set, data=chr2) #pi=dependent var. Set=factor. rec=covariate.
summary(score1) #shows sig effect of rec rate and set, but no sig interaction (suggests slopes are similar for the sets)
score2 <- lm(AVG_PI~REC_RATE+Set, data=chr2) #shows set has a sig effect on dependent variable
summary(score2) #shows sig effect of set (suggests intercepts differ for the sets)
anova(score1, score2) #F=0.11,p=0.7 compares the models to show that removing the interaction does not significantly affect fit of the model
#the regression slope is similar for both sets of data. But overall variation in the no sweeps set is higher (higher y)

#chromosome XR
score1xr <- lm(AVG_PI~REC_RATE*Set, data=chrXR) #pi=dependent var. Set=factor. rec=covariate.
summary(score1xr) #shows sig effect of rec rate and set, but no sig interaction (suggests slopes are similar for the sets)
score2xr <- lm(AVG_PI~REC_RATE+Set, data=chrXR) #shows set has a sig effect on dependent variable
summary(score2xr) #shows sig effect of set (suggests intercepts differ for the sets)
anova(score1xr, score2xr) #F=0.23,p=0.63 compares the models to show that removing the interaction does not significantly affect fit of the model
#the regression slope is similar for both sets of data. But overall variation in the no sweeps set is higher (higher y)
