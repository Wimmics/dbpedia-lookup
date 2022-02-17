DATA_PATH="/appli/databus-data/lastUpdate/"
declare -a LIST_FILES=("labels" "redirects" "short-abstracts" "mappingbased-objects" "instance-type");
mkdir -p ${DATA_PATH}/tempo
# Iterate the string array using for loop
for val in ${LIST_FILES[@]}; do
   echo "---------------"
   echo "$val";
   echo "---------------"
   for FILE in $(find ${DATA_PATH} -type f -name "dbpedia_*_$val*");   do
     cp $FILE ${DATA_PATH}/tempo;
   done

done

