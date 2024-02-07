# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

#Create the arguments

directory="$1"
output_directory="$2"
sid="$3"

if [ ! -d 'out/merged' ]
then
	mkdir -p out/merged
fi

if [ ! -f out/merged/"$sid"_merged.fastq.gz ]
then
	cat "$directory"/"$sid"-12.5dpp.1.1*.fastq.gz "$directory"/"$sid"-12.5dpp.1.2*.fastq.gz > "$output_directory"/"$sid".merged.fastq.gz
else
	echo "$sid" "ya se encuentra unido"
fi
