# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output

#output_url=$1
#destination_path=$2
#unzip_file=$3

if [$# -eq 1]
then 
	wget $1

elif [$# -eq 2]
then
	wget $1 $2

elif [$# -eq 3]
then
	if [$3 -eq 'yes']
	then
		wget $1 $2 > download_file
		gunzip -r download_file
	else
		echo "wrong argument"
	fi
#else
#	echo "Usage: $0 <file> <directory> <'yes' to unzip>"
fi

