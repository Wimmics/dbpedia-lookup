if [ -z ${DATA_PATH+x} ]; then DATA_PATH='/root/data'; fi
if [ -z ${TDB_PATH+x} ]; then TDB_PATH='/root/tdb'; fi
if [ -z ${INDEX_MODE+x} ]; then INDEX_MODE='BUILD_MEM'; fi
if [ -z ${INDEX_PATH+x} ]; then INDEX_PATH='/root/index'; fi
if [ -z ${CLEAN+x} ]; then CLEAN='true'; fi
if [ -z ${CONFIG_PATH+x} ]; then CONFIG_PATH='/root/app-config.yml'; fi
#if [ -z ${REFRESH_DATA} ]; then REFRESH_DATA='false'; fi
#if [ -z ${APP_NAME} ]; then APP_NAME=''; fi

echo "${DATA_PATH}"

echo "####### FIRST CLEAN INDEX AND TDB"
rm -rf ${TDB_PATH}/*
rm -rf ${INDEX_PATH}/*

###### HERE WE JUST GET THE FILES ALREADY DOWNLOAD IN OWN PIPELINE

#mkdir -p ${DATA_PATH}/tempo_${APP_NAME}
#rm -rf ${DATA_PATH}/tempo_tempo_${APP_NAME}/*
#declare -a LIST_FILES=("labels" "redirects" "short-abstracts" "mappingbased-objects" "instance-type");
## Iterate the string array using for loop
#for val in ${LIST_FILES[@]}; do
#   echo "---------------"
#   echo "$val";
#   echo "---------------"
#   for FILE in $(find ${DATA_PATH} -type f -name "dbpedia_*_$val*");   do
#     cp $FILE ${DATA_PATH}/tempo_tempo_${APP_NAME};
#   done

#done

echo "========================================="
echo "DATA_PATH is set to '$DATA_PATH'"; 
echo "TDB_PATH is set to '$TDB_PATH'"; 
echo "CONFIG_PATH is set to '$CONFIG_PATH'"; 
echo "========================================="

#DATA_PATH2="${DATA_PATH}/tempo_tempo_${APP_NAME}"
cd /root/lookup-application
mvn exec:java -Dexec.mainClass="org.dbpedia.lookup.IndexMain" -Dexec.args="-data $DATA_PATH -tdb $TDB_PATH -config $CONFIG_PATH -clean $CLEAN -mode $INDEX_MODE"


#m -rf ${DATA_PATH2}

echo "========================================="
echo "Copying .war to tomcat webapps directory."
echo "========================================="
cp ./target/lookup-application.war /usr/local/tomcat/webapps/
echo "Done! Starting tomcat..."
echo "========================================="
/usr/local/tomcat/bin/catalina.sh start
echo "Running..."

if [ -d "${DATA_PATH}" ]; then
    inotifywait -m -r -e create -e moved_to "${DATA_PATH}" | while read DIR ACTION FILE;
    do
        echo "File ${FILE} has been added to the data directory"
        mvn exec:java -Dexec.mainClass="org.dbpedia.lookup.IndexMain" -Dexec.args="-data ${DIR}${FILE} -tdb $TDB_PATH -config $CONFIG_PATH -clean $CLEAN -mode $INDEX_MODE"
        /usr/local/tomcat/bin/catalina.sh stop
        /usr/local/tomcat/bin/catalina.sh start
    done
else
    while true
    do
        sleep 60
    done
fi




