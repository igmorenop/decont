#Download all the files specified in data/filenames

if [ ! -f data/*.fastq.gz* ]
then
	for url in $(cat data/urls) #TODO
	do
    		echo -e "\e[1;35mDescargando ficheros fastq...\e[0m"
    		bash scripts/download2.sh $url data
		curl -s $url | md5sum | cut -d" " -f1 | sort | uniq  >> data/control.md5
	done
else
	echo -e "\e[1;35mLos ficheros ya se encuentran descargados\e[0m"
fi

#Comprobación de los ficheros mediante md5
if [ ! -f "data/cases.md5" ]; then
	echo -e "\e[1;35mFicheros fastq descargados, se procederá a su comprobación\e[0m"
	echo -e "\e[1;35m...\e[0m"
	for file in $(ls data/*.fastq.gz*); do
		md5sum $file | cut -d" " -f1 | sort | uniq  >> data/cases.md5
	done
	md5_cases="data/cases.md5"
	md5_control="data/control.md5"
	comprobacion=$(diff "$md5_cases" "$md5_control")
	if [ "$comprobacion" = "" ];then
		echo -e "\e[1;35mLos ficheros se han descargado correctamente\e[0m"
	else
		echo -e "\e[1;35mHa habido un error en la descarga\e[0m"
	fi
else
	echo -e "\e[1;35mFicheros descargados previamente, no se procederá a su comprobación\e[0m"
fi

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
if [ ! -f "res/contaminants_filtered.fasta" ]
then
	echo -e "\e[1;35mDescargando fichero con genoma de referencia, descomprimiendo y depurando archivo...\e[0m"
	bash scripts/download2.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes #TODO
	echo -e "\e[1;35mGenoma de referencia descargado y depurado\e[0m"
else
	echo -e "\e[1;35mEl genoma de referencia ya se encuentra descargado, descomprimido y depurado\e[0m"
fi

# Index the contaminants file
# Chequea si el directorio para indexar el archivo existe o no
if [ ! -d "res/contaminants_idx" ]
then
	mkdir -p res/contaminants_idx
fi

#Ejecuta el script "index" para indexar el fichero contaminants, previamente filtrado de small nuclear RNA
if [ ! -f "res/contaminants_idx/genomeParameters.txt" ]
then
	echo -e "\e[1;35mIndexando el genoma de referencia...\e[0m"
	bash scripts/index.sh res/contaminants_filtered.fasta res/contaminants_idx
	echo -e "\e[1;35mGenoma de referencia indexado\e[0m"
else
	echo -e "\e[1;35mEl genoma de referencia ya se encuentra indexado\e[0m"
fi

# (linea 20) Merge the samples into a single file
#Realiza el bucle para unir los RNA en un archivo
for sid in $(ls data | grep 'fastq'| cut -d"-" -f1 | sort | uniq) #he cambiado _ por - en el -d (test)
do
    	bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
# Chequea si el directorio para los ficheros "trimmed" se encuentra creado, y si no existe, lo crea
if [ ! -d "out/trimmed" ]
then
	mkdir -p out/trimmed
fi

#Chequea si el directorio para el fichero .log creado por cutadapt se encuentra creado, y si no existe, lo crea
if [ ! -d "log/cutadapt" ]
then
	mkdir -p log/cutadapt
fi

#Realiza el bucle para quitar los adaptadores a partir de los ficheros unidos, crea el fichero "trimmed", y envía el log a la carpeta creada previamente
for sid in $(ls out/merged | cut -d"." -f1 | sort | uniq )
do
		if [ ! -f "out/trimmed/"$sid".trimmed.fastq.gz" ]
		then
			echo -e "\e[1;35mQuitando adaptadores de "$sid"\e[0m"
			cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
			-o out/trimmed/"$sid".trimmed.fastq.gz out/merged/"$sid".merged.fastq.gz > log/cutadapt/"$sid".log
			#Indexar la información en Report.log
			echo "Information from cutadapt in" "$sid" >> log/Report.log
			sed -n '8{p};16{p}' log/cutadapt/"$sid".log >> log/Report.log
			echo -e "\e[1;35mAdaptadores quitados\e[0m"

		else
			echo -e "\e[1;35mLos adaptadores en" "$sid" "ya se encontraban retirados\e[0m"
		fi
done
# TODO: run STAR for all trimmed files
#Crea el bucle para ejecutar STAR con los archivos "trimmed" y compararlos con el genoma indexado previamente
for fname in out/trimmed/*.fastq.gz
do
	# you will need to obtain the sample ID from the filename
	sid=$(basename "$fname" .trimmed.fastq.gz) #TODO
	# Chequea si la carpeta existe, y si no, la crea
	if [ ! -d "out/star/$sid" ]
	then
		mkdir -p out/star/$sid
	fi
	#Chequea si los ficheros del alineamiento se han creado previamente
	archivo_sam="out/star/$sid/Aligned.out.sam"
	if [ ! -e "$archivo_sam" ]
	then
		echo -e "\e[1;35mAlineando con genoma de referencia...\e[0m"
		STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn "$fname" --readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sid"/
		echo -e "\e[1;35mAlineamiento completado\e[0m"
		#Indexar la información en Report.log
		echo "Information from STAR in" "$sid" >> log/Report.log
		sed -n '9,10{p}' out/star/"$sid"/Log.final.out >> log/Report.log
		sed -n '24,27{p}' out/star/"$sid"/Log.final.out >> log/Report.log
	else
		echo -e "\e[1;35mAlineamiento con "$sid" realizado previamente\e[0m"
	fi
done
# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
