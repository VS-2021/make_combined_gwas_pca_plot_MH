# Load required package.
library(data.table)

args = commandArgs(trailingOnly = TRUE)

# Read in eigenvectors to plot PCA
x <- fread(args[1])

# Remove column 2 (redundant)
x[, V2 := NULL]

# Load in sample key
#y <- fread("/scratch.global/haasx092/reneth_gwas/211227_reneth_gwas_sample_key.csv")

y_2021 <- fread("/scratch.global/haasx092/combined_gbs_data/211227_reneth_gwas_sample_key.csv") #2021 key
y_2022 <- fread("/scratch.global/haasx092/combined_gbs_data/220727_reneth_analysis_sample_key.csv") # 2022 key

# add a column for year
y_2021[, year := 2021]
y_2022[, year := 2022]

# modify column with sample name to include year appeneded at the end
y_2021[, sample_number := paste0(sample_number, "_", year, ".bam")]
y_2022[, sample_number := paste0(sample_number, "_", year, ".bam")]

# Make a column called identity that keeps only the most important part of the sample names (cultivars). 
# Note that it truncates FY-C20 to FY because for most other samples it was easiest to use the hyphen to serve as the delineator
y_2021[, identity := sub("-.*$", "", sample_name)]

y_2022[sample_name %like% "K2", identity := "K2"]
# first select all sampleIDs that are not K2 (because including K2 will turn it grey since it was already in the "identity" column)
sampleIDs <- unique(y_2022[!(grep("K2",sample_name)),]$sample_number)

for(i in sampleIDs){
     y_2022[sample_number == i, identity := strsplit(sample_name, "-")[[1]][2]]
}

#y_2022[sample_name == "K2", identity := "K2"]

# merge separate sample keys into one
y <- rbindlist(list(y_2021, y_2022))

# set column names
setnames(x, c("sample_ID", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10",
		"PC11", "PC12", "PC13", "PC14", "PC15", "PC16", "PC17", "PC18", "PC19", "PC20"))

setnames(y, c("sample_ID", "sample_name","year", "identity"))

# Shorten sample name (change from directory path format) so that it can be merged with data table y
x[, sample_ID := sub("/.+$", "", sample_ID)]

# Read in eigenvalues (to determine % variation explained by each PC)
v <- fread(args[2])


# Calculate percent variation (note: I didn't bother renaming the columns to something informative since there is only one)
percentVar = c(PC1=v[1, V1] / sum(v$V1), PC2=v[2, V1] / sum(v$V1), PC3=v[3, V1] / sum(v$V1), PC4=v[4, V1] / sum(v$V1), PC5=v[5, V1] / sum(v$V1), PC6=v[6, V1] / sum(v$V1), PC7=v[7, V1] / sum(v$V1), PC8=v[8, V1] / sum(v$V1))

# Merge data tables
x[y, on="sample_ID"] -> z

z[, col := "grey"] # set the default color to grey because there are too many to do it manually in a practical way
# I left the option to color non-GWAS samples grey even though this analysis shouldn't have any non-GWAS samples just to serve as an example of what to do as a default
# I did, however, remove the grey/"other" option from the legend of the plot that we make at the end.

# Set colors based on the major cultivars in the plot
# Colors selected from: https://digitalsynopsis.com/design/beautiful-color-palettes-combinations-schemes. (#23  Metro UI Colors)
z[identity == "Barron" | identity == "barron", col := rgb(209/255, 17/255, 65/255)] # There are instances of Barron samples being referenced with a lowercase "B"
z[identity == "FY" | identity == "FYC20", col := rgb(0/255, 177/255, 89/255)] # This is FY-C20. The C20 part was dropped from the column as described above, so it needs to be referenced in this manner
z[identity == "IC12" | identity == "ItascaC12", col := rgb(0/255, 174/255, 219/255)]
z[identity == "IC20" | identity == "1C20" | identity == "ItascaC20", col := rgb(243/255, 119/255, 53/255)] # There are instances of Itasca-C20 being referenced with a "1" instead of an "I"
z[identity == "K2", col := rgb(255/255, 196/255, 37/255)]

# Add plotting symbol/character by year
z[year == 2021, pch := 16]
z[year == 2022, pch := 17]

# Make the plot
plot_pcs <- function(arg1, arg2, arg3, arg4, arg5, arg6, pch, col){
par(mar = c(4, 4, 2, 16))
plot(arg1, arg2, xlab = paste0(arg3, round(percentVar[arg4]*100), "%"),
                     ylab = paste0(arg5, round(percentVar[arg6]*100), "%"),
                     main = "Reneth's combined GWAS populations",
                     pch = pch,
                     col = col,
                     cex = 1.5,
                     yaxt = 'n')
axis(2, las = 1)

par(oma = c(0, 0, 0, 0))
legend("topright", inset = c(-0.2,0.3), xpd = TRUE,
		legend=c("Barron-2021", "FY-C20-2021", "Itasca-C12-2021", "Itasca-C20-2021", 
			"K2-2021", "Barron-2022", "FY-C20-2022", "Itasca-C12-2022", "Itasca-C20-2022", "K2-2022"),
		pch=c(16, 16, 16, 16, 16, 17, 17, 17, 17, 17),
		col=c(rgb(209/255, 17/255, 65/255), rgb(0/255, 177/255, 89/255), rgb(0/255, 174/255, 219/255), rgb(243/255, 119/255, 53/255), rgb(255/255, 196/255, 37/255), rgb(209/255, 17/255, 65/255), rgb(0/255, 177/255, 89/255), rgb(0/255, 174/255, 219/255), rgb(243/255, 119/255, 53/255),  rgb(255/255, 196/255, 37/255)),
		ncol=1,
		cex=1.2)
}

pdf(args[3], height=12, width=16)
z[, plot_pcs(PC1, PC2, "PC1: ", 1, "PC2: ", 2, pch, col)]
z[, plot_pcs(PC2, PC3, "PC2: ", 2, "PC3: ", 3, pch, col)]
z[, plot_pcs(PC3, PC4, "PC3: ", 3, "PC4: ", 4, pch, col)]
z[, plot_pcs(PC4, PC5, "PC4: ", 4, "PC5: ", 5, pch, col)]
z[, plot_pcs(PC5, PC6, "PC5: ", 5, "PC6: ", 6, pch, col)]
z[, plot_pcs(PC5, PC6, "PC6: ", 6, "PC7: ", 7, pch, col)]
z[, plot_pcs(PC5, PC6, "PC7: ", 7, "PC8: ", 8, pch, col)]
dev.off()

# Save data
save(v, x, y_2021, y_2022, y, z, percentVar, file=args[4])
