library(edgeR)
library(DESeq2)
data = read.csv("gene_count_matrix.csv", header=T, row.names=1, com='') #输入文件
col_ordering = c(1,2,3,4,5,6) #文件中有几个组，2_v_2相当于四个
rnaseqMatrix = data[,col_ordering]
rnaseqMatrix = round(rnaseqMatrix)
rnaseqMatrix = rnaseqMatrix[rowSums(cpm(rnaseqMatrix) > 1) >= 2,] #清除每行中CPM值>1的个数小于2 的行
conditions = data.frame(conditions=factor(c(rep("s", 3), rep("c", 3)))) #处理组和对照组各有多少组，s是处理，c是对照
rownames(conditions) = colnames(rnaseqMatrix)
ddsFullCountTable <- DESeqDataSetFromMatrix(
  countData = rnaseqMatrix,
  colData = conditions,
  design = ~ conditions)

dds = DESeq(ddsFullCountTable)
normalized_counts <- counts(dds, normalized = TRUE)
contrast=c("conditions","s","c")
res = results(dds, contrast)
baseMeanA <- rowMeans(counts(dds, normalized=TRUE)[,colData(dds)$conditions == "s"])
baseMeanB <- rowMeans(counts(dds, normalized=TRUE)[,colData(dds)$conditions == "c"])
res = cbind(baseMeanA, baseMeanB, as.data.frame(res))
res = cbind(sampleA="s", sampleB="c", as.data.frame(res))
res$padj[is.na(res$padj)]  <- 1
res = as.data.frame(res[order(res$pvalue),])
write.table(res, file='deseq_gene_count_matrix.txt', sep='\t', quote=FALSE) #输出结果

