#! /bin/bash
source activate qiime2-2017.12
source tab-qiime
mkdir q2-tutorial
cd q2-tutorial
cp -r /data/share/BITMaB-2018/18S_metabarcoding_Project_FranPanama/* .

# column -t mapping_file_panama_MAY_2017.tsv | less -S
# ls -lh raw_reads_paired

qiime tools import   --type 'SampleData[PairedEndSequencesWithQuality]'   --input-path raw_reads_paired/   --source-format CasavaOneEightSingleLanePerSampleDirFmt   --output-path demux-paired-end.qza
qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux.qzv
# pwd
# scp ron.sr.unh.edu:~/q2-tutorial/*.qzv .   ## on your own computer!!  Don't forget your username, uname@ron...
## in your browser view.qiime2.org and open demux.qzv

qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 6 --p-trim-left-r 6 --p-trunc-len-f 151 --p-trunc-len-r 150 --p-n-threads 36 --o-representative-sequences rep-seqs --o-table table  ##  ~5 min to run solo

qiime tools import --type FeatureData[Sequence] --input-path /usr/local/share/SILVA_databases/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta --output-path 99_otus_18S
qiime tools import --type FeatureData[Taxonomy] --input-path /usr/local/share/SILVA_databases/SILVA_128_QIIME_release/taxonomy/18S_only/99/consensus_taxonomy_all_levels.txt --source-format HeaderlessTSVTaxonomyFormat --output-path concencus_taxonomy_all_levels
qiime feature-classifier classify-consensus-blast --i-query rep-seqs.qza --i-reference-taxonomy concencus_taxonomy_all_levels.qza --i-reference-reads 99_otus_18S.qza --o-classification taxonomy --p-perc-identity 0.97 --p-maxaccepts 1

mv table.qza unfiltered-table.qza
qiime taxa filter-table \
  --i-table unfiltered-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-include metazoa \
  --o-filtered-table table.qza

qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file mapping_file_panama_MAY_2017.tsv
qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv
# scp ron.sr.unh.edu:~/q2-tutorial/*.qzv .   ## on your own computer!!  Don't forget your username, uname@ron...                                                                  
## in your browser view.qiime2.org and open table.qzv and rep-seqs.qzv 

qiime alignment mafft --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza
qiime phylogeny midpoint-root --i-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza

qiime diversity alpha-rarefaction --i-table table.qza --i-phylogeny rooted-tree.qza --p-min-depth 500 --p-max-depth 6018 --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization alpha-rarefaction.qzv


qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table table.qza --p-sampling-depth 2999 --m-metadata-file mapping_file_panama_MAY_2017.tsv --output-dir core-metrics-results

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization core-metrics-results/faith-pd-group-significance.qzv
qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization core-metrics-results/faith-pd-correlation.qzv
qiime diversity alpha-correlation --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization core-metrics-results/evenness-correlation.qzv

qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --m-metadata-category Matrix --o-visualization core-metrics-results/unweighted-unifrac-Matrix-group-significance.qzv --p-pairwise

qiime emperor plot --i-pcoa core-metrics-results/unweighted_unifrac_pcoa_results.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --p-custom-axis Depths --o-visualization core-metrics-results/unweighted-unifrac-emperor-Depths.qzv
qiime emperor plot --i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --p-custom-axis Depths --o-visualization core-metrics-results/bray-curtisc-emperor-Depths.qzv


qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy
qiime taxa barplot --i-table table.qza --i-taxonomy taxonomy.qza --m-metadata-file mapping_file_panama_MAY_2017.tsv --o-visualization taxa-bar-plots
