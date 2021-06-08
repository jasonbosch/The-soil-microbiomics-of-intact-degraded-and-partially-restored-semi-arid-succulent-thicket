#This is the script which processes the amplicon sequencing data for our paper on the semi-arid succulent thicket (Albany Subtropical Thicket).
#Written by: Jason Bosch
#Last update: 07/06/2021

#Commands were run separetely on a compute cluster for each of the re-sequencing attempts
#Most standard desktops will run out of memory.

#create the directories
mkdir ~/Albany_thicket/results/
mkdir ~/Albany_thicket/results/G174-184705525
mkdir ~/Albany_thicket/results/G174R-189359172
mkdir ~/Albany_thicket/G174-184705525/all_seqs
mkdir ~/Albany_thicket/G174R-189359172/all_seqs

#Create links to data
ln -s ~/Albany_thicket/G174-184705525/FASTQ_Generation_2020-07-26_03_21_36Z-287876589/*/* ~/Albany_thicket/G174-184705525/all_seqs/
ln -s ~/Albany_thicket/G174R-189359172/FASTQ_Generation_2020-08-15_04_47_49Z-297913616/*/* ~/Albany_thicket/G174R-189359172/all_seqs/

##G174-184705525

#Import into single Qiime2 object
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path ~/Albany_thicket/G174-184705525/all_seqs/ --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path ~/Albany_thicket/results/G174-184705525/demux-paired-end.qza

#For simplicity's sake, now can work in the results folder
cd ~/Albany_thicket/results/G174-184705525/

#Created a summary of the multiplexed files to check for quality
qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux.qzv

#Try to keep quality at the lower end of the box >=20 and try different front trimming options to maximise reads
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 8 --p-trim-left-r 8 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F8.295_R8.200.qza --o-representative-sequences rep-seqs_F8.295_R8.200.qza --o-denoising-stats denoising-stats_F8.295_R8.200.qza
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 10 --p-trim-left-r 10 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F10.295_R10.200.qza --o-representative-sequences rep-seqs_F10.295_R10.200.qza --o-denoising-stats denoising-stats_F10.295_R10.200.qza
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 15 --p-trim-left-r 15 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F15.295_R15.200.qza --o-representative-sequences rep-seqs_F15.295_R15.200.qza --o-denoising-stats denoising-stats_F15.295_R15.200.qza

#Made a visualisation of the stats
qiime metadata tabulate --m-input-file denoising-stats_F8.295_R8.200.qza --o-visualization denoising-stats_F8.295_R8.200.qzv
qiime metadata tabulate --m-input-file denoising-stats_F10.295_R10.200.qza --o-visualization denoising-stats_F10.295_R10.200.qzv
qiime metadata tabulate --m-input-file denoising-stats_F15.295_R15.200.qza --o-visualization denoising-stats_F15.295_R15.200.qzv

#The F15.295_R15.200 trimming showed the highest number of usable reads.

#Made a Feature Table summary
qiime feature-table summarize --i-table table_F15.295_R15.200.qza --o-visualization table.qzv --m-sample-metadata-file Albany_metadata.csv

#And feature data summary
qiime feature-table tabulate-seqs --i-data rep-seqs_F15.295_R15.200.qza --o-visualization rep-seqs.qzv

#Created a tree for phylogenetic analysis (optional)
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs_F15.295_R15.200.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza

#Created rarefaction curves to show how well we had covered the diversity
qiime diversity alpha-rarefaction --i-table table_F15.295_R15.200.qza --i-phylogeny rooted-tree.qza --p-max-depth 50000 --m-metadata-file Albany_metadata.csv --o-visualization alpha-rarefaction.qzv

#Had a pre-trained classifier which was then used to classify samples with the Naive Bayes classifier.
qiime feature-classifier classify-sklearn --i-classifier ~/classify/silva-138.1-ssu-nr99-V3_V4-classifier.qza --i-reads rep-seqs_F15.295_R15.200.qza --o-classification taxonomy__F15.295_R15.200_silva_138.1.qza

#To see the classification scores
qiime metadata tabulate --m-input-file taxonomy__F15.295_R15.200_silva_138.1.qza --o-visualization taxonomy__F15.295_R15.200_silva_138.1.qzv

#Put all the stuff we want to export for use in a separate folder and export to there
mkdir export
qiime tools export --input-path taxonomy__F15.295_R15.200_silva_138.1.qza --output-path export
qiime tools export --input-path rooted-tree.qza --output-path export
qiime tools export --input-path table_F15.295_R15.200.qza --output-path export
biom convert -i export/feature-table.biom -o export/OTU.tsv --to-tsv
sed -i s/"#OTU"/"OTU"/ export/OTU.tsv
cp Albany_metadata.csv export/

##G174R-189359172

#Import into single Qiime2 object
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path ~/Albany_thicket/G174R-189359172/all_seqs/ --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path ~/Albany_thicket/results/G174R-189359172/demux-paired-end.qza

#For simplicity's sake, now can work in the results folder
cd ~/Albany_thicket/results/G174R-189359172

#Created a summary of the multiplexed files to check for quality
qiime demux summarize --i-data demux-paired-end.qza --o-visualization demux.qzv

#Try to keep quality at the lower end of the box >=20 and try different front trimming options to maximise reads
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 8 --p-trim-left-r 8 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F8.295_R8.200.qza --o-representative-sequences rep-seqs_F8.295_R8.200.qza --o-denoising-stats denoising-stats_F8.295_R8.200.qza
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 10 --p-trim-left-r 10 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F10.295_R10.200.qza --o-representative-sequences rep-seqs_F10.295_R10.200.qza --o-denoising-stats denoising-stats_F10.295_R10.200.qza
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-paired-end.qza --p-trim-left-f 15 --p-trim-left-r 15 --p-trunc-len-f 295 --p-trunc-len-r 200 --o-table table_F15.295_R15.200.qza --o-representative-sequences rep-seqs_F15.295_R15.200.qza --o-denoising-stats denoising-stats_F15.295_R15.200.qza

#Made a visualisation of the stats
qiime metadata tabulate --m-input-file denoising-stats_F8.295_R8.200.qza --o-visualization denoising-stats_F8.295_R8.200.qzv
qiime metadata tabulate --m-input-file denoising-stats_F10.295_R10.200.qza --o-visualization denoising-stats_F10.295_R10.200.qzv
qiime metadata tabulate --m-input-file denoising-stats_F15.295_R15.200.qza --o-visualization denoising-stats_F15.295_R15.200.qzv

#The F15.295_R15.200 trimming showed the highest number of usable reads.

#And feature data summary
qiime feature-table tabulate-seqs --i-data rep-seqs_F15.295_R15.200.qza --o-visualization rep-seqs.qzv

#Created a tree for phylogenetic analysis (optional)
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs_F15.295_R15.200.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza

#Created rarefaction curves to show how well we had got all the diversity
qiime diversity alpha-rarefaction --i-table table_F15.295_R15.200.qza --i-phylogeny rooted-tree.qza --p-max-depth 30000 --m-metadata-file Albany_metadata.csv --o-visualization alpha-rarefaction.qzv

#Had a pre-trained classifier which was then used to classify samples with the Naive Bayes classifier.
qiime feature-classifier classify-sklearn --i-classifier ~/classify/silva-138.1-ssu-nr99-V3_V4-classifier.qza --i-reads rep-seqs_F15.295_R15.200.qza --o-classification taxonomy__F15.295_R15.200_silva_138.1.qza

#To see the classification scores
qiime metadata tabulate --m-input-file taxonomy__F15.295_R15.200_silva_138.1.qza --o-visualization taxonomy__F15.295_R15.200_silva_138.1.qzv

#Put all the stuff we want to export for use in a separate folder and export to there
mkdir export
qiime tools export --input-path taxonomy__F15.295_R15.200_silva_138.1.qza --output-path export
qiime tools export --input-path rooted-tree.qza --output-path export
qiime tools export --input-path table_F15.295_R15.200.qza --output-path export
biom convert -i export/feature-table.biom -o export/OTU.tsv --to-tsv
sed -i s/"#OTU"/"OTU"/ export/OTU.tsv
cp Albany_metadata.csv export/

#Everything can then be copied off the compute cluster for analysis.

