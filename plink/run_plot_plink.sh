#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=24:00:00
#SBATCH --mem=30g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=haasx092@umn.edu
#SBATCH -p amdsmall
#SBATCH --account=jkimball
#SBATCH -o plot_plink_pca.out
#SBATCH -e plot_plink_pca.err

cd /scratch.global/haasx092/combined_gbs_data/220821_snp_calling_results

module load R/3.6.0

Rscript plot_plink_pca.R combined_gbs_data_pca.eigenvec combined_gbs_data_pca.eigenval 220824_reneth_gbs_combined_years.pdf 220824_reneth_gbs_combined_years.Rdata
