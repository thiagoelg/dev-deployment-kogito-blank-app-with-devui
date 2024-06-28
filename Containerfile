FROM --platform=linux/amd64 quay.io/bamoe/canvas-dev-deployment-base:9.1.0-ibm-0001

ARG BAMOE_MAVEN_REPO_URL

USER root

ENV HOME_PATH=/opt/bamoe

ENV ROOT_PATH=""
ENV DEV_DEPLOYMENT__UPLOAD_SERVICE_EXTRACT_TO_DIR=$HOME_PATH/app/src/main/resources
ENV DEV_DEPLOYMENT__UPLOAD_SERVICE_PORT=8080

RUN microdnf --disableplugin=subscription-manager install -y shadow-utils \
  && microdnf --disableplugin=subscription-manager clean all \
  && groupadd -r -g $USER_ID bamoe \
  && useradd -r -u $USER_ID -g bamoe -m -d $HOME_PATH -s /bin/bash bamoe

COPY --chown=$USER_ID:$USER_ID kogito-blank-app $HOME_PATH/app/
COPY --chown=$USER_ID:$USER_ID init.sh $HOME_PATH/app/

RUN sed -i -e "s|http://localhost:9000|http://${BAMOE_MAVEN_REPO_URL}|" $HOME_PATH/app/settings.xml \
  && sed -i -e "s|<localRepository/>|<localRepository>/tmp/kogito/.m2/repository</localRepository>|" $HOME_PATH/app/settings.xml \
  && sed -i -e "s|quarkus.http.host=localhost|quarkus.http.host=0.0.0.0|" $HOME_PATH/app/src/main/resources/application.properties \
  && chgrp -R 0 $HOME_PATH && chmod -R g=u $HOME_PATH && chmod +x $HOME_PATH/app/init.sh

WORKDIR $HOME_PATH/app

# Pre-populate local Maven repository for faster startup
RUN ./mvnw clean package -Dmaven.test.skip -Dquarkus.http.non-application-root-path=${ROOT_PATH}/q -Dquarkus.http.root-path=${ROOT_PATH} \
 && chgrp -R 0 /tmp/kogito && chmod -R g=u /tmp/kogito && chgrp -R 0 /.m2 && chmod -R g=u /.m2

USER $USER_ID

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c"]

CMD ["dev-deployment-upload-service && ./init.sh"]
