#!/bin/bash
# Make sure sed is Gnu sed

CMD=`basename $0`

if [ $# -eq 0 ]
then
	echo "Usage: $CMD <files in order>"
	exit 1
fi

cnt=0
for f in "$@"
do
	
	F[$cnt]=$(echo $f | sed 's/\.md$//')
	#cp -p $f $P/$f
	#rm -f $f.n

	let cnt=$cnt+1
done
let tot=$cnt-1

i=0
for f in "$@"
do
	let p=$i-1
	let n=$i+1

	if ! head -1 $f | grep -q ^--- 
	then
		# create header
		# The default ttitle is traken from the file name, removing all - or _ and preceeding digits...
		T=$(echo ${F[$i]} | sed "s/^[0-9]*-//" | sed "s/[-_]/ /g" | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')
		[ $i -eq 0 ]                && P=start &&    N=${F[$n]} 
		[ $i -gt 0 -a $i -lt $tot ] && P=${F[$p]} && N=${F[$n]} 
		[ $i -eq $tot ]             && P=${F[$p]} && N=finish

		#echo i=$i P=$P N=$N

		( echo -e "---\nTitle: $T\nPrevPage: $P\nNextPage: $N\n---\n"; cat $f) > .tmp
		echo $f
		mv .tmp $f

		let i=$i+1
		continue
	fi
	
	if [ $i -gt 0 ]
	then
		awk -i inplace "NR==2,/^---/{sub(/^PrevPage:.*/, \"PrevPage: ${F[$p]}\")} 1" $f
	fi
	if [ $i -lt $tot ] 
	then
		awk -i inplace "NR==2,/^---/{sub(/^NextPage:.*/, \"NextPage: ${F[$n]}\")} 1" $f
	fi

	let i=$i+1
done

