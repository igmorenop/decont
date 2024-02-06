#Script para hacer limpieza del directorio de ficheros donde se realiza el análisis
cleanup_function() {
	if [ -d "$1" ]; then
		echo "Eliminando el contenido de $1"
		for file in "$1"/*;do
			if [ "$file" != "$1"/urls ]; then
                		rm -r "$file"
			fi
		done
		echo "Archivos eliminados en la directorio $1"
    	else
        	echo "La carpeta $1 está vacía"
    	fi
}

#En el caso de que se indiquen argumentos, el bucle itera por cada argumento y elimina el contenido de cada directorio especificado
if [ "$#" -ge 1 ]; then
	for dir in "$@"; do
		cleanup_function "$dir"
	done

#En el caso de que no se indiquen argumentos, el script eliminará el contenido de todos los directorios
else
#if [ "$#" -eq 0 ]; then
	echo "Eliminando el contenido de todo el directorio de estudio"
	for dir in */; do
		if [ "$dir" != "scripts/" ]; then
			cleanup_function "$dir"
		fi
	done
fi

#rm -r data/*.fastq.gz* log/cutadapt out/merged out/star out/trimmed res/*.fasta* res/contaminants_idx

