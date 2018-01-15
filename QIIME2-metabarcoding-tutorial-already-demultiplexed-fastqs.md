## QIIME 2 workflow for metabarcoding analysis (18S/16S rRNA) with already-demultiplexed fastq files.

Here, we will utilize a pipeline called QIIME (v2) to analyze and visualize microbial diversity using raw DNA sequences in fastq files. In contrast to QIIME 1, QIIME 2 features several new ways of analyzing NGS data and has been modified significantly bioinformatically, but NOT biologically. 

Below is a list of a few terms you should know when utilizing QIIME 2. 

1. **Action** - a generic term for a method or visualizer.
2. **Artifact** - zipped input or output data for QIIME actions. Artifacts have file extension `.qza`. 
3. **Parameter** - an input to an action. For instance, `--p-trim-left` is a parameter that takes in an integer value for any number of bases that the user wishes to trim off from the start of the sequence.
4. **Plugin** - a general term for an external tool that is built around QIIME 2. 
5. **Visualization** - output data from a QIIME visualizer that have file extension `.qzv`. These can be viewed [online](https://view.qiime2.org/).


Please use this pipeline if your **fastq files are already demultiplexed** - meaning each fastq file pairs (R1 and R2) represent sequences from ONE sample type.

Please also keep in mind that QIIME 2 is a work in progress; so some features may not yet be available. But rest assured that QIIME 2 team is working hard and should you have any uber specific questions we cannot answer, please sign-up and post them on the [QIIME 2 forum](https://forum.qiime2.org/). 

[Link to the main QIIME 2 website](https://docs.qiime2.org/2017.12/) (for more tutorials and detailed documentation of the pipeline).

---

## What is QIIME 2?
QIIME 2 is a microbiome analysis pipeline, and it is significantly different from the previous version QIIME 1. Instead of directly using data files such as FASTQ and FASTA files, QIIME 2 utilizes artifacts. See definition above. 

Here is a list of files you must have in order to run the QIIME 2 pipeline.

1. **A mapping file**
	* This is a tab-delimited file containing all the sequencing info. You can create this file in excel but it should be saved as a text version. Below is an example mapping file. The required columns are shown in **bold**. 
	
		![Example mapping file](https://www.dropbox.com/s/fnpjvvx3jor667y/example-mapping-file-2018.png?raw=1)
	
2. **R1 fastq**
	* This file contains reads returned by the sequencer first.  

3. **R2 fastq**
	* This file contains reads returned by the sequencer second.

The forward and reverse read file names for a single sample might look like `L2S357_15_L001_R1_001.fastq.gz` and `L2S357_15_L001_R2_001.fastq.gz`, respectively. The underscore-separated fields in this file name are the sample identifier, the barcode sequence or a barcode identifier, the lane number, the read number, and the set number.


## Activating QIIME 2 and copying over data files

`source activate qiime2-2017.12`

`source tab-qiime`

`mkdir q2-tutorial`

`cd q2-tutorial`

`cp -r /data/share/BITMaB-2018/18S_metabarcoding_Project_FranPanama/* .`


### To view the help menu for any QIIME 2 action, you can run that particular action followed by `--help` as shown below.


**Command:**

```
qiime tools --help

```
**Output:**

```
Usage: qiime tools [OPTIONS] COMMAND [ARGS]...

  Tools for working with QIIME 2 files.

Options:
  --help  Show this message and exit.

Commands:
  export    Export data from a QIIME 2 Artifact or Visualization.
  extract   Extract a QIIME 2 Artifact or Visualization archive.
  import    Import data into a new QIIME 2 Artifact.
  peek      Take a peek at a QIIME 2 Artifact or Visualization.
  validate  Validate data in a QIIME 2 Artifact.
  view      View a QIIME 2 Visualization.
  
```
AND, to get more info on the commands associated with an action, run the action along with the desired command as shown below.

**Command:**

```
qiime tools import --help
```
**Output:**

```
Usage: qiime tools import [OPTIONS]

  Import data to create a new QIIME 2 Artifact. See https://docs.qiime2.org/
  for usage examples and details on the file types and associated semantic
  types that can be imported.

Options:
  --type TEXT                The semantic type of the artifact that will be
                             created upon importing. Use --show-importable-
                             types to see what importable semantic types are
                             available in the current deployment.  [required]
  --input-path PATH          Path to file or directory that should be
                             imported.  [required]
  --output-path PATH         Path where output artifact should be written.
                             [required]
  --source-format TEXT       The format of the data to be imported. If not
                             provided, data must be in the format expected by
                             the semantic type provided via --type.
  --show-importable-types    Show the semantic types that can be supplied to
                             --type to import data into an artifact.
  --show-importable-formats  Show formats that can be supplied to --source-
                             format to import data into an artifact.
  --help                     Show this message and exit. 
```
 	 
## Pipeline Overview

Here is an overview of the general steps of the QIIME pipeline for already demultiplexed reads that we will carry out during the BITMaB workshop (click links to jump to detailed instructions for each step):

#### [Step 0](): Quick command for data that are NOT already demultiplexed 
#### [Step 1](): Importing data, summarize the results, and examing quality of the reads

#### [Step 2](): Quality controlling sequences and building Feature Table and Feature Data

#### [Step 3](): Assigning Taxonomy

#### [Step 4](): Summarizing Feature Table and Feature Data

#### [Step 5](): Generating a phylogenetic tree

#### [Step 6](): Analyzing Alpha and Beta diversities


---

* NOTE: For the purposes of this tutorial, we are running all the analysis in a single directory and using non-descriptive names when assigning output files.

## Step 0 - Quick command for data that are NOT already demultiplexed 

In case your data are NOT demultiplexed, you may use the following commands for separating your read files based on sample names.

```


```

## Step 1 - Importing data, summarize the results, and examing quality of the reads
 
### A. Import data files as Qiime Zipped Artifacts (.qza)

```
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path raw_reads_paired/ \
--source-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path demux-paired-end.qza
```

### B. Summarize and visualize the qza

```
qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux.qzv
```
* Here, you must copy over the `.qzv` output to your computer, and open `demux.qzv` in [www.view.qiime2.org](https://view.qiime2.org/)

## Step 2 - Quality controlling sequences and building Feature Table and Feature Data 

* QIIME 2 has plugins for various quality control methods such as [DADA2](https://benjjneb.github.io/dada2/tutorial.html) and [Deblur](https://github.com/biocore/deblur). The result of both of these methods will be a `FeatureTable[Frequency]` QIIME 2 artifact containing counts (frequencies) of each unique sequence in each sample in the dataset, and a `FeatureData[Sequence]` QIIME 2 artifact, which maps feature identifiers in the FeatureTable to the sequences they represent. We will use DADA2 in this tutorial. The `FeatureTable[Frequency]` and  `FeatureData[Sequence]` are analogous to QIIME 1's Biom table and rep_set fasta file, respectively.

* The `dada2 denoise-paired` requires four parameters: `--p-trim-left-f`, `--p-trim-left-r`, `--p-trunc-len-f`, and `--p-trunc-len-r`. The `--p-trim-left m` trims off the first `m` bases of each sequence, and `--p-trunc-len n` truncates each sequence at position `n`. The `f` and `r` in each parameter stand for forward and reverse read, correspondingly.

* Please consider the question below before you quality trim the sequences.

> ### Based on the plots you see in `demuz.qzv`, what values would you choose for `--p-trim-left-f`, `--p-trim-left-r`, `--p-trunc-len-f`, and `--p-trunc-len-r` in this case? 

```
qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f m1 \
--p-trim-left-r m2 \
--p-trunc-len-f n1 \
--p-trunc-len-r n2 \
--p-n-threads 12 \
--o-representative-sequences rep-seqs.qza \
--o-table table.qza

```


## Step 3 - Assigning Taxonomy

### A. Import reference data files as Qiime Zipped Artifacts (.qza)

```
qiime tools import \
--type FeatureData[Sequence] \
--input-path /usr/local/share/SILVA_databases/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta \
--output-path 99_otus_18S

```

```
qiime tools import \
--type FeatureData[Taxonomy] \
--input-path /usr/local/share/SILVA_databases/SILVA_128_QIIME_release/taxonomy/18S_only/99/consensus_taxonomy_all_levels.txt \
--source-format HeaderlessTSVTaxonomyFormat \
--output-path consensus_taxonomy_all_levels

```

### B. Classify query sequences using Blast

```
qiime feature-classifier classify-consensus-blast \
--i-query rep-seqs.qza \
--i-reference-taxonomy consensus_taxonomy_all_levels.qza \
--i-reference-reads 99_otus_18S.qza \
--o-classification taxonomy \
--p-perc-identity 0.97 \
--p-maxaccepts 1

```
```
mv table.qza unfiltered-table.qza

```

### C. Filter the Feature Table to contain only metazoa OTUs.

```
qiime taxa filter-table \
  --i-table unfiltered-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-include metazoa \
  --o-filtered-table table.qza

```


## Step 4 - Summarizing Feature Table and Feature Data

```
qiime feature-table summarize \
--i-table table.qza \
--o-visualization table.qzv \
--m-sample-metadata-file mapping_file_panama_MAY_2017.tsv

```


```
qiime feature-table tabulate-seqs \
--i-data rep-seqs.qza \
--o-visualization rep-seqs.qzv

```

* Here, you must copy over the `.qzv` outputs to your computer, and open `table.qzv` and `rep-seqs.qzv` in [www.view.qiime2.org](https://view.qiime2.org/)


## Step 5 - Generating a phylogenetic tree

```
qiime alignment mafft --i-sequences rep-seqs.qza --o-alignment aligned-rep-seqs.qza
```
```
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
```
```
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza
```
```
qiime phylogeny midpoint-root --i-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza
```


## Step 6 - Analyzing Alpha and Beta diversities

#### A. Assess alpha rarefaction

```
qiime diversity alpha-rarefaction \
-i-table table.qza \
--i-phylogeny rooted-tree.qza \
--p-min-depth 500 \
--p-max-depth 6018 \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization alpha-rarefaction.qzv
```

* Here, you must copy over the `.qzv` output to your computer, and open it in [www.view.qiime2.org](https://view.qiime2.org/)

> ### View the `table.qzv` QIIME 2 artifact, and in particular the Interactive Sample Detail tab in that visualization. What value would you choose to pass for `--p-sampling-depth` below? How many samples will be excluded from your analysis based on this choice? How many total sequences will you be analyzing in the core-metrics-phylogenetic command? 

#### B. Compute several alpha and beta diversity metrics and plot PCoAs using Emperor

```
qiime diversity core-metrics-phylogenetic \
--i-phylogeny rooted-tree.qza \
--i-table table.qza \
--p-sampling-depth n \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--output-dir core-metrics-results
```

```
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization core-metrics-results/faith-pd-group-significance.qzv
```

```
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/evenness_vector.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization core-metrics-results/evenness-group-significance.qzv
```

* View the `.qzv` outputs in [www.view.qiime2.org](https://view.qiime2.org/) and answer the following questions.

> ### What discrete sample metadata categories are most strongly associated with the differences in microbial community richness? Are these differences statistically significant? 
 

> ### What discrete sample metadata categories are most strongly associated with the differences in microbial community evenness? Are these differences statistically significant?


```
qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization core-metrics-results/faith-pd-correlation.qzv
```

```
qiime diversity alpha-correlation \
--i-alpha-diversity core-metrics-results/evenness_vector.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization core-metrics-results/evenness-correlation.qzv
```

```
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--m-metadata-category Matrix \
--o-visualization core-metrics-results/unweighted-unifrac-Matrix-group-significance.qzv \
--p-pairwise
```

```
qiime emperor plot \
--i-pcoa core-metrics-results/unweighted_unifrac_pcoa_results.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--p-custom-axis Depths \
--o-visualization core-metrics-results/unweighted-unifrac-emperor-Depths.qzv
```

```
qiime emperor plot \
--i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--p-custom-axis Depths \
--o-visualization core-metrics-results/bray-curtisc-emperor-Depths.qzv
```

```
qiime metadata tabulate \
--m-input-file taxonomy.qza \
--o-visualization taxonomy.qzv
```
```
qiime taxa barplot \
--i-table table.qza \
--i-taxonomy taxonomy.qza \
--m-metadata-file mapping_file_panama_MAY_2017.tsv \
--o-visualization taxa-bar-plots.qzv
```

* View the `.qzv` outputs in [www.view.qiime2.org](https://view.qiime2.org/).


---



### Other Options for downstream visualization and community analysis

#### [Phinch](http://phinch.org)
An interactive browser-based data visualization framework (for exploring QIIME outputs) - use your OTU table with taxonomy and mapping file embedded - instructions are here:  [https://github.com/PitchInteractiveInc/Phinch/wiki/Quick-Start](https://github.com/PitchInteractiveInc/Phinch/wiki/Quick-Start) - **NOTE: Phinch only works with BIOM 1.0 files, which are no longer the default output in QIIME 1.9 and higher - see file conversion instructions on the link above.

#### [LEfSE - Linear Discriminate Analasis (LDA) Effectd Size](https://huttenhower.sph.harvard.edu/galaxy/)
Statistical test that looks for enrichment or depletion of OTUs across sample metadata categories (e.g. Prespill vs. Postspill samples). You can run this analysis on the Huttenhower Lab's online Galaxy server (above link) - you will need to convert your OTU table into tab-delimited format and add metadata headings before you can run LEfSE

#### [Phyloseq](https://github.com/joey711/phyloseq/wiki) - An R package for visualizing QIIME outputs
Offers sleeker visualizaitons and more flexibility than the visualizations offered within QIIME. You can produce heatmaps, box plots, and trim down your OTU table to only look at community patterns within certain OTUs or taxonomic groups. Great for generating publication-ready figures, but requires quite a bit of R knowledge and tweaking to get working.
