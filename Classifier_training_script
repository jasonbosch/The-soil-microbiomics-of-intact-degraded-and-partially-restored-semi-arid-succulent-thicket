#This is the script which was used to train the classifier for our paper on the semi-arid succulent thicket (Albany Subtropical Thicket).
#Written by: Jason Bosch
#Last update: 07/06/2021

#References
#https://github.com/bokulich-lab/RESCRIPt
#https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database-and-other-reference-sequence-data-with-rescript/15494

#Change to working directory
cd ~/classify/

#Download the correct SILVA database files, no species labels
qiime rescript get-silva-data --p-version '138.1' \
    --p-target 'SSURef_NR99' \
    --o-silva-sequences silva-138.1-ssu-nr99-seqs.qza \
    --o-silva-taxonomy silva-138.1-ssu-nr99-tax.qza

#Cull low quality sequences
qiime rescript cull-seqs \
    --i-sequences silva-138.1-ssu-nr99-seqs.qza \
    --o-clean-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza

#Filter by length and taxonomy
qiime rescript filter-seqs-length-by-taxon \
    --i-sequences silva-138.1-ssu-nr99-seqs-cleaned.qza \
    --i-taxonomy silva-138.1-ssu-nr99-tax.qza \
    --p-labels Archaea Bacteria Eukaryota \
    --p-min-lens 900 1200 1400 \
    --o-filtered-seqs silva-138.1-ssu-nr99-seqs-filt.qza \
    --o-discarded-seqs silva-138.1-ssu-nr99-seqs-discard.qza

#dereplicate with lowest common ancestor
qiime rescript dereplicate \
    --i-sequences silva-138.1-ssu-nr99-seqs-filt.qza  \
    --i-taxa silva-138.1-ssu-nr99-tax.qza \
    --p-rank-handles 'silva' \
    --p-mode 'lca' \
    --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-derep-lca.qza \
    --o-dereplicated-taxa silva-138.1-ssu-nr99-tax-derep-lca.qza

#Extract the amplicon specific region for our V3_V4 primers
qiime feature-classifier extract-reads \
    --i-sequences silva-138.1-ssu-nr99-seqs-derep-lca.qza \
    --p-f-primer CCTACGGGNGGCWGCAG  \
    --p-r-primer GACTACHVGGGTATCTAATCC \
    --p-n-jobs 6 \
    --p-read-orientation 'forward' \
    --o-reads silva-138.1-ssu-nr99-seqs-V3_V4.qza

#Dereplicate extracted region, again using lca
qiime rescript dereplicate \
    --i-sequences silva-138.1-ssu-nr99-seqs-V3_V4.qza \
    --i-taxa silva-138.1-ssu-nr99-tax-derep-lca.qza \
    --p-rank-handles 'silva' \
    --p-mode 'lca' \
    --o-dereplicated-sequences silva-138.1-ssu-nr99-seqs-V3_V4-lca.qza \
    --o-dereplicated-taxa  silva-138.1-ssu-nr99-tax-V3_V4-derep-lca.qza

#Train the region specific classifier
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.1-ssu-nr99-seqs-V3_V4-lca.qza \
    --i-reference-taxonomy silva-138.1-ssu-nr99-tax-V3_V4-derep-lca.qza \
    --o-classifier silva-138.1-ssu-nr99-V3_V4-classifier.qza

