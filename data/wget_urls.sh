while IFS= read -r url; do
  # Use wget to download the file
  wget "$url" -p /home/vant/decont/data
done < "urls"
