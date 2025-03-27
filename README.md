# ChimericSeq

This forked branch is under further development to comply with ENSembl GTF format and to report useful results

list of edits: 2025-03-26

* unset bowtie2 version in reqs since version has changed since the original code
* add gif picture to display in GUI (copied from the company website)
* make the config option for Trim5 active,it was ignored in the code
* stop trimming the chromosome names to clip chr away, this was a very nasty one that removed the chromosome names from my annotations
* add some debug reporting in the stdout window to check that GTF loading worked and paired reads are used (was unclear)
* correct the way gene is extracted from GTF data which did not match ensembl GTF for non-cannoniocal genes (lncRNA, ...). Now concatenates the ENS gene_id and the gene name when exists
* ... more to come
 
I did not evaluate (yet) the effect of other settings that might not be passed although present in the config.txt loaded file; The free version of this software is not fully developped and contains a number of place-holders without proper code (the company licenses a more recent version which likely is more polished)

The app still does not run yet properly in my hands and there is no active link on the company website to obtain valid test data.
