#!/bin/bash                                                                     
#SBATCH --account=sta440-f20                                                   
#SBATCH -p common                                                               
#SBATCH -N1                                                                     
#SBATCH -c1                                                                     
#SBATCH --mem=50G                                                               
#SBATCH --mail-type=end                                                         
#SBATCH --mail-user=ajm120@duke.edu                                             

module load R/3.6.0
Rscript whovotes_bayesian_model_code.R
