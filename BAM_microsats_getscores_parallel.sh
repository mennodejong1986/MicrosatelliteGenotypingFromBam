#!/bin/bash
# Script to run BAM_microsats_getscores.sh parallel.
# To run, type (as an example): 
# ./BAM_microsats_getscores_parallel.sh 2 4 3
# The first number defines the number of sets (i.e. the number of parallel executions)
# The second number defines the number of microsats per set.
# The third number defines the starting set number. The example above will start with subset3, microsatellite 9 (as listed in bed file).
# Make sure that any number specified does not exceed total number of microsats in the bed file, otherwise you will run into errors.
# For example, if you have 2704 microsats, you could run '27 100 1', and then only 4 microsats will not be analysed.  

# To analyse the remaining 4 microsats, follow these steps:
# - run command: tail -4 mybed.txt > mymicrosat.subset.bed
# - create a new subdirectory
# - copy into this directory three files: 'microsat.subset.bed', 'BAM_microsats_getscores.sh' and the txt-file listing the input bam-files
# - navigate into subdirectory and run command: ./BAM_microsats_getscores.sh

#############

NSETS=$1
NGENESPERSET=$2
STARTSETNR=$3

MYBAMFILES=mybamfiles.2500di.txt			# Should be the same as specified in 'BAM_microsats_getscores.sh', and should give the full path
MYBED=allmt.19or20_di.allscaf.bed			# VERY IMPORTANT: Here you specify input bed file, but in 'BAM_microsats_getscores.sh' you should specify 'mymicrosat.subset.bed' !!!

#############


ENDSETNR=$(( $STARTSETNR + $NSETS - 1))

echo "subset" > prefix.txt
seq $STARTSETNR $ENDSETNR > mymicrosets.txt

mywd=$(pwd)

for mynumber in $(cat mymicrosets.txt)
do
echo $mynumber > mynumber.txt
paste -d '' prefix.txt mynumber.txt > myset.txt
set=$(cat myset.txt)

# create subset bed file:
myend=$(( $mynumber * $NGENESPERSET))
mystart=$(( $myend - $NGENESPERSET + 1 ))
#echo $mystart
#echo $myend
awk -v startline="${mystart}" -v endline="${myend}" 'NR >= startline && NR <= endline' $MYBED > mymicrosat.subset.bed

# create new directory:
subsetdir=$(echo ${mywd}"/"${set})
#echo ${subsetdir}

mkdir ${subsetdir}
cp BAM_microsats_getscores.sh ${subsetdir}
cp $MYBAMFILES ${subsetdir}
cp mymicrosat.subset.bed ${subsetdir}

# start analysis:
cd ${subsetdir} 
./BAM_microsats_getscores.sh &
cd ${mywd}

done
echo "All runs started..."

rm prefix.txt mymicrosets.txt mynumber.txt myset.txt mymicrosat.subset.bed

# Afterwards, results can be combined with the commands:
# cat subset*/mymicrosat.scores.all_loci.txt | grep -v 'length' > tempdata.txt
# head -1 subset1/mymicrosat.scores.all_loci.txt > tempheader.txt
# cat tempheader.txt tempdata.txt > my2500di.microsat.scores.all.txt


