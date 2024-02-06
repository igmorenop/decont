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

input_url="$1"
destination_path="$2"
unzip_file="$3"
#filter_word="$4"

# Use wget to download the file

wget -P "$destination_path" "$input_url" "$unzip_file"

#Chequea si el tercer argumento es "yes" para descomprimir el archivo descargado
if [ "$unzip_file" = "yes" ]; then
	file= $(basename "$url")
	gunzip -k "$destination_path"/"$file"*.gz
	seqkit grep -n -p 'small nuclear' -v -r res/contaminants.fasta | seqkit grep -n -p 'snRNA' -v -r res/contaminants.fasta > res/contaminants_filtered.fasta
fi
