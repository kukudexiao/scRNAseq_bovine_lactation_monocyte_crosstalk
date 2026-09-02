## Over-Representation Analysis with ClusterProfiler
#  https://learn.gencore.bio.nyu.edu/rna-seq-analysis/over-representation-analysis/

##### Presetting ######
  rm(list = ls()) # Clean variable
  memory.limit(150000)

##### Load Packages  #####   
    library(clusterProfiler)
    library(enrichplot)
    library(ggupset)
    # Annotations
    organism = "org.Bt.eg.db" ## Genome wide annotation for Cattle 
    library(organism, character.only = TRUE)

##### Prepare Input #####
  ## reading in input from deseq2
  df = read.csv("example_de.txt", header=TRUE)
  
  ## For the universe in clusterProfiler
  # we want the log2 fold change 
  original_gene_list <- df$log2FoldChange
  
  # name the vector
  names(original_gene_list) <- df$X
  
  # omit any NA values 
  gene_list <- na.omit(original_gene_list)
  
  # sort the list in decreasing order (required for clusterProfiler)
  gene_list = sort(gene_list, decreasing = TRUE)
  
  ## Gene list
  # Exctract significant results (padj < 0.05)
  sig_genes_df = subset(df, padj < 0.05)
  
  # From significant results, we want to filter on log2fold change
  genes <- sig_genes_df$log2FoldChange
  
  # Name the vector
  names(genes) <- sig_genes_df$X
  
  # omit NA values
  genes <- na.omit(genes)
  
  # filter on min log2fold change (log2FoldChange > 0.25)
  genes <- names(genes)[abs(genes) > 0.25]

##### Create enrichGO object #####  
  ## Create the object
  go_enrich <- enrichGO(gene = genes,
                        universe = names(gene_list),
                        OrgDb = organism, 
                        keyType = 'ENSEMBL',
                        readable = T,
                        ont = "BP",
                        pvalueCutoff = 0.05, 
                        qvalueCutoff = 0.10)
  
##### Output #####
  ## Upset Plot
  upsetplot(go_enrich)

  ## Barplot
  barplot(go_enrich, 
          drop = TRUE, 
          showCategory = 10, 
          title = "GO Biological Pathways",
          font.size = 8)
  
  ## Dotplot
  dotplot(go_enrich)
  
  ## Encrichment map:
  emapplot(go_enrich)

  ## Enriched GO induced graph:
  goplot(go_enrich, showCategory = 10)
  
  

  