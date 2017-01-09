##will take a long time to run
source('SNP_conversion.R')
library(MatrixEQTL)

useModel = modelLINEAR
SNP_file_name = "SNPsinRNA.txt"
expression_file_name = "RNAinSNPs.txt"
covariates_file_name = character()
output_file_name_cis = "output_cis.txt"
output_file_name_tra = "output_tra.txt"
pvOutputThreshold_cis = 1e-2
pvOutputThreshold_tra = 1e-2
errorCovariance = numeric()
cisDist = 1e6

snps = SlicedData$new();
  snps$fileDelimiter = "\t";      # the TAB character
  snps$fileOmitCharacters = "NA"; # denote missing values;
  snps$fileSkipRows = 1;          # one row of column labels
  snps$fileSkipColumns = 1;       # one column of row labels
  snps$fileSliceSize = 2000;      # read file in pieces of 2,000 rows
  snps$LoadFile( SNP_file_name )

gene = SlicedData$new();
  gene$fileDelimiter = "\t";      # the TAB character
  gene$fileOmitCharacters = "NA"; # denote missing values;
  gene$fileSkipRows = 1;          # one row of column labels
  gene$fileSkipColumns = 1;       # one column of row labels
  gene$fileSliceSize = 2000;      # read file in pieces of 2,000 rows
  gene$LoadFile(expression_file_name);

cvrt = SlicedData$new();
  cvrt$fileDelimiter = "\t";      # the TAB character
  cvrt$fileOmitCharacters = "NA"; # denote missing values;
  cvrt$fileSkipRows = 1;          # one row of column labels
  cvrt$fileSkipColumns = 1;       # one column of row labels
  cvrt$fileSliceSize = 2000;      # read file in pieces of 2,000 rows
  cvrt$LoadFile( covariates_file_name );

me = Matrix_eQTL_main(
  snps = snps, 
  gene = gene, 
  cvrt = cvrt,
  output_file_name = output_file_name_tra,
  pvOutputThreshold = 0, ##allows running in cis-mode only - can run trans-mode too by turning on next line and turning this off
  #pvOutputThreshold.tra = pvOutputThreshold_tra,
  useModel = useModel, 
  errorCovariance = errorCovariance, 
  verbose = TRUE, 
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = pvOutputThreshold_cis,
  snpspos = snpspos, 
  genepos = genepos,
  cisDist = cisDist,
  pvalue.hist = "qqplot",
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)

library(data.table)
cis <- me$cis$eqtls

plot(me, pch = 16, cex = 0.7)

me2 = Matrix_eQTL_main(
  snps = snps, 
  gene = gene, 
  cvrt = cvrt,
  output_file_name = output_file_name_tra,
  pvOutputThreshold = 0, ##allows running in cis-mode only - can run trans-mode too by turning on next line and turning this off
  #pvOutputThreshold.tra = pvOutputThreshold_tra,
  useModel = useModel, 
  errorCovariance = errorCovariance, 
  verbose = TRUE, 
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = pvOutputThreshold_cis,
  snpspos = snpspos, 
  genepos = genepos,
  cisDist = cisDist,
  pvalue.hist = 100,
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE)

plot(me2, col='grey')

library(dplyr)

cis<-filter(cis, FDR<0.001)
siggene<-count(cis, gene)
sigsnps<-count(cis, snps)