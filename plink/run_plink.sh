#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --time=24:00:00
#SBATCH --mem=30g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=haasx092@umn.edu
#SBATCH -p amdsmall
#SBATCH --account=jkimball
#SBATCH -o run_plink.out
#SBATCH -e run_plink.err

cd /scratch.global/haasx092/combined_gbs_data/220821_snp_calling_results

module load plink

plink --vcf merged_vcf_files.vcf --mind 0.99 --double-id --allow-extra-chr --recode --out combined_gbs_data

# PCA calculation
plink --pca --file combined_gbs_data --allow-extra-chr -out combined_gbs_data_pca
