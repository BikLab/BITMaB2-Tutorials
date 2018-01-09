## QIIME 2 workflow for metabarcoding analysis (18S/16S rRNA) with already-demultiplexed fastq files.

Here, we will utilize a pipeline called QIIME (v2) to analyze and visualize microbial diversity using raw DNA sequences in fastq files. Please use this pipeline if your fastq files are already demultiplexed - meaning each fastq file pairs (R1 and R2) represent sequences from ONE sample type.

[Link to the main QIIME 2 website](https://docs.qiime2.org/2017.12/) (for more tutorials and detailed documentation of the pipeline).

---

## What is QIIME 2?
QIIME 2 is a microbiome analysis pipeline, and it is significantly different from the previous version QIIME 1. Instead of using data files such as FASTA files, QIIME 2 utilizes artifacts. You can think of artifacts as zipped files, and they can be inputs as well as outputs in QIIME 2. Artifacts have the extension `.qza`. 

Below is a list of files you must have in order to run the QIIME 2 pipeline.

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


### To view the help menu for any QIIME 2 method, you can run that particular method followed by `--help` as shown below.


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
AND, to get more info on the commands associated with a method, run the method along with the desired command as shown below.

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

#### [Step 1](): Importing data, summarize the results, and examing quality of the reads

#### [Step 2](): Quality controlling sequences and building Feature Table and Feature Data

#### [Step 3](): Assigning Taxonomy

#### [Step 3](): Building Feature table (aka OTU table)

#### [Step 4](): Summarizing Feature Table and Feature Data

#### [Step 5](): Generating a phylogenetic tree
#### [Step 6](): Analyzing Alpha and Beta diversities

#### [Step 7](): Assigning Taxonomy

---

* NOTE: For the purposes of this tutorial, we are running all the analysis in a single directory and using non-descriptive names when assigning output files. However, we highly recommend that you use a directory structure that allows you to keep your files organized and name your files and directories as descriptively as possible. We have shared our own directory structure and naming conventions at the end of this tutorial.

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





#### 1c. Truncate the reverse primer

* NOTE: you must have the reverse primer sequences listed in your mapping file for this step.

```
truncate_reverse_primer.py -f seqs.fna \
	-m <QIIME.mapping.file> \
	-o <output.directory.name>
```

This last step removes the flanking primer sequences from your reads (the primer you used to generate your amplicons in the lab). These primer sequences are contained in your QIIME mapping file.

---

## Step 2 - Pick Operational Taxonomic Units (OTUs)


"Picking" Operational Taxonomic Units (abbreviated as **OTUs**) is a standard method for clustering raw Illumina reads into clusters of sequences. In theory each OTU is the molecular equivalent of a morphological "species" (but in practice the OTU picking approach is arbitrary and not a perfect equivalent - often you will recover many more OTUs than known biological species).

QIIME offers several options for picking OTUs - the two most common are `reference-based OTU picking` and `open-reference OTU picking`

> ### Why would choose use one type of OTU picking over the other?

In this workshop we will be using open-reference OTU picking - [described here in this QIIME tutorial](http://QIIME.org/tutorials/open_reference_illumina_processing.html). The method is also peer-reviewed and published in [Rideout et. al 2014, PeerJ](https://peerj.com/articles/545/) (open access publication)

We will start by picking OTUs using our fasta file that contains quality-filtered Illumina reads from each sample. 

#### 2a. Picking OTUs using the open reference strategy

We pick OTUs using `workflow scripts` in QIIME. These wrap many scripts under one umbrella command - so to modify some parameters, we need to use a parameter file. Create a parameters file called `18S_openref99_rdp_silva119.txt` with the following lines

```
#Parameters for 99pct open reference OTU picking with rdp taxonomy assignment


# OTU picker parameters
pick_otus:similarity	0.99
pick_otus:enable_rev_strand_match	True

# Taxonomy assignment parameters
assign_taxonomy:reference_seqs_fp	/home/gomre/taruna/GOM-Illumina/ref_dbs/Silva119_release/rep_set_eukaryotes/99/Silva_119_rep_set99_18S.fna
assign_taxonomy:id_to_taxonomy_fp	/home/gomre/taruna/GOM-Illumina/ref_dbs/Silva119_release/consensus_majority_taxonomy/consensus_taxonomy_eukaryotes/99/taxonomy_99_7_levels_consensus.txt
assign_taxonomy:assignment_method	rdp
assign_taxonomy:confidence	0.7
assign_taxonomy:rdp_max_memory	60000

```

> ### Examine the QIIME parameter file above. What do you see? What parameters are we modifying?



We'll start by running the following command:

```
pick_open_reference_otus.py \
	-i <input.fasta> \
	-r <database.reference.seqs> \
	-o <output.directory.name> \
	-p <QIIME.parameters.file> \
	-s 0.10 \
	--prefilter_percent_id 0.0 \
	--suppress_align_and_tree
```

The `<input.fasta>` is the output file from Step 1c. 

Again, choose any name for your output directory - it's usually a good idea to make this descriptive so you can remember what type of analysis you did, and when you ran it. Something like: `-o analysis-results/uclust-99pct-18Seuk-11Jan17/1_otu-pick`

> ### Once the OTU picking script is finished, what files do you see in your output directory? 

> ### Peek into the OTU picking logfile. How many different commands were run using this workflow script?

 
#### 2b. Assign taxonomy

```
export RDP_JAR_PATH=/usr/local/lib/rdp_classifier_2.2/rdp_classifier-2.2.jar

```

```
assign_taxonomy.py \
	-i <rep-set-OTUs.fna> \
	-r Silva_119_rep_set99_18S.fna \
	-t taxonomy_99_7_levels_consensus.txt \
	-o <output.directory.name> \
	-m rdp 
```

If you get an error message when trying to assign taxonomy (e.g. when using a large dataset), try increasing the RDP max memory, for example `--rdp_max_memory 80000`

---

## Step 3 - Identify chimeras and remove chimeric sequences from the OTU table

#### 3a. Identify chimeras
```
identify_chimeric_seqs.py \
	-i <rep-set-OTUs.fna> \
	-m usearch61 \
	-o <output.directory.name> \
	-r Silva_119_rep_set99_18S.fna
```
We recommend using `-m ChimeraSlayer` but it is available on your server.
 
#### 3b. Remove any sequences flagged as chimeras from the BIOM table

```
filter_otus_from_otu_table.py \
	-i <OTU-table-input.biom> \
	-o <OTU-table-output.biom> \
	-e <chimeras.txt>
```

---

## Step 4 -  Align sequences and remove alignment failures from the OTU table

#### 4a. Align rep_set.fna against a pre-aligned reference database. In our case, we are using the Silva119 database. 

```
align_seqs.py \
	-i <rep-set-OTUs.fna> \
	-o <output.directory.name> \
	-t Silva_119_rep_set99_aligned_18S_only.fna \
	--alignment_method pynast \
	--pairwise_alignment_method uclust \
	--min_percent_id 70.0
```

#### 4b. Remove gaps from the aligned rep sets which is important for constructing a phylogeny. If using the Greengenes database, this step is highly recommended. 

```
filter_alignment.py \
	-i <aligned-rep-set-OTUs.fna> \
	-o <output.directory.name> \
	--suppress_lane_mask_filter
```

#### 4c. Add metadata to the BIOM table. This will be helpful for viewing the diversity results.

```
biom add-metadata \
	-i <table.biom> \
	-o <OTU-table.txt> \
	-m <mapping.file.txt>
```

#### 4d. Summarize the BIOM table to assess the number of sequences/OTUs per sample and store the output in a text file. 

```
biom summarize-table \
	-i <table.biom> \
	-o <OTU-table-summary.txt>
```


---

## Step 5 - Filter rep set fasta file to match the OTU IDs in your filtered OTU table 

```
filter_fasta.py \
	-f <rep-set-aligned-filtered.fna> \
	-o <output.fna> \
	-b <table.biom>
```

---

## Step 6 - Make new phylogeny with final set of OTUS (no chimeras, no alignment failures)
```
make_phylogeny.py \
	-i <rep-set-aligned-filtered.fna> \
	-o <output.tre> \
	--tree_method fasttree
```

---

## Step 7 - Run diversity analysis


### Run Core Diversity Analysis workflow script

```
core_diversity_analyses.py \
	-i <OTU-table.biom> \
	-o <core-div> \
	-m <QIIME.mapping.file> \
	-e NUMBER \
	-t <phylogeny.tre> \
	-c Habitat
```

`-e NUMBER` needs to be completed based on the results of `biom-summarize-table` command - this flag indicates the sequencing depth you will use for even-subsampling and maximum rarefaction depth (e.g. the number of reads you will randomly select from each sample). If a sample contains less reads than the value specified for `-e NUMBER`, then the diversity workflow script will NOT include this sample in your analysis. For example, if `-e 5000` then a sample containing only 1000 reads will not be used to carry out diversity analyses (and you will not see this sample name in your output).

The above `core_diversity_analyses.py` workflow runs a large number of different types of analyses within one script (alpha-diversity, beta-diversity, category analysis, etc.). You can also run individual analyses if you prefer.

---

### Other Options for downstream visualization and community analysis

#### [Phinch](http://phinch.org)
An interactive browser-based data visualization framework (for exploring QIIME outputs) - use your OTU table with taxonomy and mapping file embedded - instructions are here:  [https://github.com/PitchInteractiveInc/Phinch/wiki/Quick-Start](https://github.com/PitchInteractiveInc/Phinch/wiki/Quick-Start) - **NOTE: Phinch only works with BIOM 1.0 files, which are no longer the default output in QIIME 1.9 and higher - see file conversion instructions on the link above.

#### [LEfSE - Linear Discriminate Analasis (LDA) Effectd Size](https://huttenhower.sph.harvard.edu/galaxy/)
Statistical test that looks for enrichment or depletion of OTUs across sample metadata categories (e.g. Prespill vs. Postspill samples). You can run this analysis on the Huttenhower Lab's online Galaxy server (above link) - you will need to convert your OTU table into tab-delimited format and add metadata headings before you can run LEfSE

#### [Phyloseq](https://github.com/joey711/phyloseq/wiki) - An R package for visualizing QIIME outputs
Offers sleeker visualizaitons and more flexibility than the visualizations offered within QIIME. You can produce heatmaps, box plots, and trim down your OTU table to only look at community patterns within certain OTUs or taxonomic groups. Great for generating publication-ready figures, but requires quite a bit of R knowledge and tweaking to get working.

#### Other Useful QIIME scripts for Diversity analysis


`alpha_diversity.py` - gives you bar charts showing relative abundance of taxa across samples

`beta_diversity_through_plots.py` - primary script for Principle Coordinate Analysis, can be run using a phylogenetic tree (weighted/unweighted Unifrac PCoAs) or carried out using non-phylogenetic metrics (Bray-Curtis, Jaccard, Canberra diversity metrics)

* **Canberra** - doesn’t expect differences in the most abundant OTUs  - squashes relevance down to the same weight; rare species will help to explain differences.
* **Bray-Curtis** - Only cares about the most abundant species.
* **Jaccard** - simplest shared OTU index.


 
Example script for individual beta diversity analysis :

```
beta_diversity_through_plots.py \
	-i <table.biom> \
	-m <mapping.file.txt> \
	-o <output.directory.name> \
	-t <input.tre> \
	-e <count.per.sample>
```
Example scripts for individual alpha diversity analysis:

```
alpha_diversity.py \
	-i  <table.biom> \
	-o <output.txt> \
	-t <input.tre> 
```
```
alpha_rarefaction.py \
	-i  <table.biom> \
	-m <mapping.file.txt> \
	-o <output.directory.name> \
	-t <input.tre> \
	-e <count.per.sample>
```




## Directory structure

Before we begin the pipeline, we want to share a directory structure we use in our lab, and we highly recommend you implement the same or a similar directory structure. Using this structure will not only help you stay organized, but will also help you understand and follow our pipeline with ease. 

![Recommended directory structure for QIIME2](https://www.dropbox.com/s/mqk2plz0d56k224/dir-struc-QIIME-small.png?raw=1)

The numbers in some directory names correspond to the order in which these directories are created during our QIIME 2 pipeline. 