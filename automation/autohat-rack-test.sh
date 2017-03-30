#!/bin/bash

export application_name=`echo $application_name | tr '[:upper:]' '[:lower:]'`

if [ "$FLASHER" == "true" ]; then
   TESTFILE='flasher.robot'
else
   TESTFILE='raspberrypi3.robot'
fi


/bin/cat <<EOM >start.sh
#!/bin/bash
cd /autohat
robot --exitonerror --exitonfailure ${TESTFILE}
exit 0
EOM

chmod a+x start.sh
docker build -t $application_name .
docker stop ${application_name} || true
docker rm ${application_name} || true
tar -xf ../deploy/resin.img.tar.gz
docker run -d -v `pwd`:/autohat --privileged \
    --env INITSYSTEM=on \
    --env RESINRC_RESIN_URL=${RESINRC_RESIN_URL} \
    --env email=${RESIN_EMAIL} \
    --env password=${RESIN_PASSWORD} \
    --env device_type=${device_type} \
    --env application_name=${application_name} \
    --env image=/autohat/resin.img \
    --env rig_device_id=${rig_device_id} \
    --env rig_sd_card=${rig_sd_card} \
    --privileged \
    --name=${application_name} \
    $AUTOHAT_IMAGE ${application_name} 
    
docker exec -t ${application_name} /autohat/start.sh
docker stop ${application_name} || true
docker rm ${application_name} || true

