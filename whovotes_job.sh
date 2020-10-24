#!/bin/bash                                                                     
#SBATCH --account=sta440-f20                                                    
#SBATCH -p common                                                               
#SBATCH -N1                                                                     
#SBATCH -c1                                                                     
#SBATCH --mem=10G                                                               

module load RStan/2.19.2
Rscript working_model.R