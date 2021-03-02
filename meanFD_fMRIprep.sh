#!/bin/bash
echo "subject,session,meanFD" > meanFD.csv
for i in $(find . -name "*confounds_timeseries.tsv"):
	do meanfd=$(FDfpr.r $i); sub=$(cut -d/ -f4 <<<"$i")
	ses=$(cut -d/ -f5 <<<"$i")
	echo "$sub,$ses,$meanfd" >> meanFD.csv
done
