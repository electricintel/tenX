SV Re-genotyping Methods for 10X Genomics
=========================================

Installing
----------

Download the source code:

`git clone https://github.com/tobiasrausch/tenX.git`

`cd tenX/`

Add the dependencies (Htslib, Boost, and Delly):

`git submodule init`

`git submodule update`

Add the Boost sub-libraries:

`cd src/modular-boost`

`git submodule init`

`git submodule update`

Build the programs:

`cd ../../`

`make all`

                     *The below example is now missing from the 10xgenomics.com website... will not work*
                             *Mr. Rausch, if you would upload the file we would appreciate it.*

Example
-------
                     
Download the NA12878 10X Genomics phased bam file from http://10xgenomics.com/ and the 1000 Genomes structural variant (SV) release from the EBI ftp site:

`wget 'ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/integrated_sv_map/ALL.wgs.integrated_sv_map_v2.20130502.svs.genotypes.vcf.gz'`

Run the haplotype-aware SV re-genotyping of the SV site list:

`./genoDEL -v ALL.wgs.integrated_sv_map_v2.20130502.svs.genotypes.vcf.gz NA12878.10X.bam > del.tsv`

Compare 1000 Genomes phased & imputed genotypes with 10X Genomics derived genotypes:

`python compareGeno.py -t del.tsv`

Estimate phasing accuracy:

`python comparePhasing.py -t del.tsv`
