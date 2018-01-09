## QIIME 2 workflow for metabarcoding analysis (18S/16S rRNA) with already-demultiplexed fastq files.

Here, we will utilize a pipeline called QIIME (v2) to analyze and visualize microbial diversity using raw DNA sequences in fastq files. Please use this pipeline if your fastq files are already demultiplexed - meaning each fastq file pairs (R1 and R2) represent sequences from ONE sample type.

[Link to the main QIIME 2 website](https://docs.qiime2.org/2017.12/) (for more tutorials and detailed documentation of the pipeline).

---
## Directory structure

Before we begin the pipeline, we want to share a directory structure we use in our lab, and we highly recommend you implement the same or a similar directory structure. Using this structure will not only help you stay organized, but will also help you understand and follow our pipeline with ease. 

![Recommended directory structure for QIIME2](https://www.dropbox.com/s/mqk2plz0d56k224/dir-struc-QIIME-small.png?raw=1)

The numbers in some directory names correspond to the order in which these directories are created during our QIIME 2 pipeline. 

## What is QIIME 2?
QIIME 2 is a microbiome analysis pipeline, and it is significantly different from the previous version QIIME 1. Instead of using data files such as FASTA files, QIIME 2 utilizes artifacts. You can think of artifacts as packaged files, and they can be inputs as well as outputs in QIIME 2. Artifacts have the extension `.qza`. 

1. **A mapping file**
	* This is a tab-delimited file containing all the sequencing info and should be in format below. We have shown only the required columns. More info on formatting the mapping file is [here](http://QIIME.org/documentation/file_formats.html). 
	
	![Example mapping file](https://www.dropbox.com/s/j8jg5ogkt2b0l68/example_mapping_file_small.png?raw=1)
	
2. **R1 fastq**
	* This file contains reads returned by the sequencer first.

3. **R2 fastq**
	* This file contains reads returned by the sequencer second.

4. Index file
	* This file contains the indices used for sequencing. This file is only needed if your reads are not demultiplexed.
 
	 
## Pipeline Overview

Here is an overview of the general steps of the QIIME pipeline for already demultiplexed reads that we will carry out during the BITMaB workshop (click links to jump to detailed instructions for each step):

#### [Step 1](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-1---prepare-fastq-files-example-workflow-for-workshop): Prepare fastq files

#### [Step 2](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-2---pick-operational-taxonomic-units-otus): Pick Operational Taxonomic Units

#### [Step 3](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-3---identify-chimeras-and-remove-chimeric-sequences-from-the-otu-table): Identify chimeras and remove chimeric sequences from the OTU table


#### [Step 4](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-4----align-sequences-and-remove-alignment-failures-from-the-otu-table): Align sequences and remove alignment failures from the OTU table

#### [Step 5](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-5---filter-rep-set-fasta-file-to-match-the-otu-ids-in-your-filtered-otu-table): Filter rep set fasta file to match the OTU IDs in your filtered OTU table 

#### [Step 6](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-6---make-new-phylogeny-with-final-set-of-otus-no-chimeras-no-alignment-failures): Construct a phylogenetic tree

#### [Step 7](https://github.com/BikLab/BITMaB-workshop/blob/master/QIIME-metabarcoding-tutorial-already-demultiplexed-fastqs.md#step-7---run-diversity-analysis): Carry out microbial community analyses to assess alpha- and beta-diversity 

---

### To view the help menu for any QIIME script, run:

```
<script-name> -h
```
OR

```
<script-name> --help
```

Web documentation of "help" dialogues are also [available on the QIIME website](http://QIIME.org/scripts/)

---

## Step 1 - Prepare fastq files (example workflow for workshop)

Before running QIIME on your own data, you would need to join, quality filter and trim your raw sequence reads. Typically, this is done using the following commands:

#### 1a. Join the paired end reads

* Create a parameters file called `join-PE-parameters.txt` with the following lines

```
#join_paired_ends.py parameters

join_paired_ends:min_overlap	10 #sets minimum overlap to 10bp
join_paired_ends:perc_max_diff	15 #allows for a 15% error rate in the overlapping area
```

* NOTE: be sure to specify the `--read1_indicator` and `--read2_indicator`. The default is `_R1_` so `S0_L001_R1_001.fastq.gz` and `S0_L001_R2_001.fastq.gz` would be matched up reads. 

```
multiple_join_paired_ends.py \
	-i <input.directory.name> \
	-o <output.directory.name> \
	--read1_indicator <pattern1> \ 
	--read2_indicator <pattern2> \
	-p <QIIME.parameters.file>

```

`-o <output.directory.name>` can be whatever directory name you choose but we recommend using `data-clean/1_joined-fastqs`

#### 1b. Quality filter the joined reads

* Create a parameters file called `split-libraries-parameters.txt` with the following lines

```
#split_libraries_fastq.py parameters

split_libraries_fastq:phred_quality_threshold	19 #minimum quality score of 20
split_libraries_fastq:max_bad_run_length	5 #allows 5 poor quality bases before read truncation
split_libraries_fastq:min_per_read_length_fraction	0.70 #minimum fraction of consecutive high quality base calls to include a read
split_libraries_fastq:barcode_type	not-barcoded 
```


* NOTE: be sure to specify the `--read_indicator`. The default is `_R1_` and more than likely the output from the previous step will have this configuration. 

```
multiple_split_libraries_fastq.py \
	-i <input.directory.name> \
	-o <output.directory.name> \
	--read_indicator <pattern> \
	-p <QIIME.parameters.file>
```

Your quality-filtering parameters specified in the parameters file may change based on your data type and preferences (e.g. if you want stringent vs. relaxed filtering)

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