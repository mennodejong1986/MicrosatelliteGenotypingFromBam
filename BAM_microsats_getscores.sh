#!/bin/bash
# Script to detect and score microsats in prefiltered bam files.

# It is assumed that bam files have filtered using samtools view command, so that only reads with microsats are retained:
# samtools view -h -L all29microsats.bed mysample.allreads.bam > mysamples.allmicrosats.bam  
# If not, this script will takes ages to run.
# To prefilter the input bam files, use the BAM_selectregion.sh script.

# The bed-file should have the following tab separated columns (without header):
#scaffoldname	# name of scaffold in reference genome on which microsat is located
#startpos 	# e.g. position of forward primer flanking the microsat)
#endpos 	# e.g. position of forward primer flanking the microsat) 
#microsat_name	#
#range_length 	# (endpos-startpos), or NA-value
#repeat_length	# 2 or 4 in case of dinucleotide or tetranucleotide respectively 
#repeatstring	# e.g. AC, or NA-value
#complementary	# e.g. TG in case previous column is listed as AC
#repeatstring2	# repeatstring as present in reads (so either AC or TG), this ninth column will be used as the searchstring



#########################################################################

#MYBAMFILES=mybamfiles.2000microsats.txt	# txt file which lists full path to bam files, one file per line
MYBAMFILES=mybamfiles.2500di.txt

#MYBED=allmt.7or8_tetra.allscaf.bed		# bed-file which lists the microsatellites (see above for more info). If running parallel, this should be: 'mymicrosat.subset.bed'
#MYBED=allmt.19or20_di.allscaf.bed
MYBED=mymicrosat.subset.bed			

MAXLENGTH=40					# maximum repeat length to consider
##########################################################################
# From here onwards do not make change unless you know what you are doing!




nloci=$(wc -l $MYBED | cut -f1 -d ' ')
echo "Number of loci:"
echo $nloci

# generate empty files (with headers) to store results:
sed 's|/|\t|g' $MYBAMFILES | awk '{print $NF}' | cut -f1 -d '.' | tr '\n' '\t' > mymicrosat.scores.all_loci.txt
sed -i 's/^/locus\tlength\t/' mymicrosat.scores.all_loci.txt
sed 's/$/>/' mymicrosat.scores.all_loci.txt | tr '>' '\n' > mytempfile.txt
mv mytempfile.txt mymicrosat.scores.all_loci.txt

# create file to store sequence data:
if [ -f mymicrosat.reads.all_loci.txt ];
 then
 rm mymicrosat.reads.all_loci.txt
 fi
touch mymicrosat.reads.all_loci.txt



## START LOCUS LOOP ##


for locusnr in $(seq 1 $nloci)
do
echo "Locus:"
echo $locusnr

awk -v myline="${locusnr}" 'NR == myline' $MYBED > mymicrosat.bed
locusname=$(cut -f4 mymicrosat.bed)
myrepeat=$(cut -f9 mymicrosat.bed)
repeatlength=$(cut -f6 mymicrosat.bed)

echo $locusname
echo $myrepeat
echo "Repeat length:" 
echo $repeatlength

# Create empty file to store results:
seq 1 $MAXLENGTH > microsat.all.txt





## START SAMPLE LOOP ##



#for myfile in ABC10.misatD0018.bam ABC11.misatD0018.bam ABC12.misatD0018.bam
for myfile in $(cat $MYBAMFILES)
do
 #echo $myfile

 if [ -f mymicrosat.counts.txt ];
 then
 rm mymicrosat.counts.txt
 fi

 if [ -f microsat.ind.txt ]; 
 then
 rm microsat.ind.txt
 fi
 touch microsat.ind.txt
 
 if [ -f myreads.txt ];
 then
 rm myreads.txt
 fi

 if [ -f myreads2.txt ];
 then
 rm myreads2.txt
 fi

 # select reads:   
 samtools view -L mymicrosat.bed ${myfile} | cut -f10 > myreads.txt 
 # detect microsatellite (scroll down for an explanation):
 if [[ $repeatlength == 2 ]] 
 then
  #echo "Dinucleotide repeat"
  sed "s/$myrepeat/__/g" myreads.txt | sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' |  sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' | sed 's/[A,C,T,G,K]__[A,C,T,G,K]/KKKK/g' | sed 's/[A,C,T,G,K]__[A,C,T,G,K]/KKKK/g' | sed 's/\t__[A,C,T,G,K]/\tKKK/g' | sed 's/^/</' | sed 's/$/>/' | sed 's/<[A,C,G,T,K]_/<__/g' | sed 's/_[A,C,G,T,K]>/__>/g' | grep -v '<_' | grep -v '_>' | sed 's/<//g' | sed 's/>//g' > myreads2.txt
  # score length:
  grep -o -n '__' myreads2.txt | cut -d : -f 1 | uniq -c | sed 's/^ *//' | cut -f1 -d ' ' > mymicrosat.counts.txt
 fi
 if [[ $repeatlength == 4 ]]
  then
  #echo "Tetranucleotide repeat"
  sed "s/$myrepeat/____/g" myreads.txt | sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' | sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' | sed 's/\t____[A,C,T,G,K]/\tKKKKK/g' | sed 's/^/</' | sed 's/$/>/' | sed 's/<[A,C,G,T,K]_/<__/g' | sed 's/_[A,C,G,T,K]>/__>/g' | sed 's/<[A,C,G,T,K][A,C,G,T,K]_/<___/g' | sed 's/_[A,C,G,T,K][A,C,G,T,K]>/___>/g' | sed 's/<[A,C,G,T,K][A,C,G,T,K][A,C,G,T,K]_/<____/g' | sed 's/_[A,C,G,T,K][A,C,G,T,K][A,C,G,T,K]>/____>/g' | grep -v '<_' |  grep -v '_>' | sed 's/<//g' | sed 's/>//g' > myreads2.txt
  # score length:
  grep -o -n '____' myreads2.txt | cut -d : -f 1 | uniq -c | sed 's/^ *//' | cut -f1 -d ' ' > mymicrosat.counts.txt 
 fi
 
 # generate count table:
 for k in $(seq 1 $MAXLENGTH)
  do
  #echo $k
  grep -w "$k" mymicrosat.counts.txt | wc -l >> microsat.ind.txt
  done

 paste microsat.all.txt microsat.ind.txt > microsat.all.tmp.txt
 mv microsat.all.tmp.txt microsat.all.txt
 
 # save data:
 # in case myfile contains the full path, get rid of the path:
 # in addition, get ride of file extension:
 bn=$(echo $myfile | rev | cut -d "/" -f1 | rev | cut -f1 -d ' ')

 echo ">"${locusname}"_"${bn}"_raw" >> mymicrosat.reads.all_loci.txt
 cat myreads.txt >> mymicrosat.reads.all_loci.txt
 echo ">"${locusname}"_"${bn}"_corrected" >> mymicrosat.reads.all_loci.txt
 cat myreads2.txt >> mymicrosat.reads.all_loci.txt
 
done
## END SAMPLE LOOP ##
#echo "Locus-specific results are stored in file 'microsat.all.txt'."
sed -i "s/^/${locusname}\t/" microsat.all.txt
cat microsat.all.txt >> mymicrosat.scores.all_loci.txt

done
## END LOCUS LOOP ##
echo "Analysis completed. Results are stored in the file 'mymicrosat.scores.all_loci.txt'."
echo "All (processed) raw reads are stored in the file 'mymicrosat.reads.all_loci.txt'." 


#### EXPLANATION ####

# Explanation of long command which detects microsatellites:
# STEP 1. Mask all single and double occurences of the search string:
# (commands are double in case of overlapping cases):
# sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' | sed 's/[A,C,T,G,K]____[A,C,T,G,K]/KKKKKK/g' | sed 's/[A,C,T,G,K]__[A,C,T,G,K]/KKKK/g' | sed 's/\t__[A,C,T,G,K]/\tKKK/g' 
# STEP 2. Add < and > to start and beginning of line:
# sed 's/^/</' | sed 's/$/>/' 
# STEP 3. Remove lines with repeats which are interrupted by start or end of line:
# (this includes cases like A_ at the start of line and _T at end of line, because here the repeat is likely interrupted as well)
# sed 's/<[A,C,G,T,K]_/<__/g' | sed 's/_[A,C,G,T,K]>/__>/g' | grep -v '<_' | grep -v '_>'
# STEP 4. Remove < and > to start and beginning of line: 
# sed 's/<//g' | sed 's/>//g'
