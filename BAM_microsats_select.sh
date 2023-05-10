#!/bin/bash
# This script is to extract regions from a bamfile
# the region(s) should be defined in a bed file

#########################
MYBED=allmicrosats.bed
MYBAMFILES=mybamfiles.txt
#########################

for file in $(cat $MYBAMFILES)
 do
 bn=$(echo $file | rev | cut -d "/" -f1 | rev | sed 's/.sorted.RG.dupremoved.filtered.bam//g')
 mypath=$(echo $file | rev | cut -d "/" -f2- | rev)
 echo $bn
 #echo $mypath
 samtools view -bh -L $MYBED ${mypath}/${bn}.sorted.RG.dupremoved.filtered.bam -o ${bn}.all29microsats.bam &
 done

wait
echo "Finished subtracting region(s)."
