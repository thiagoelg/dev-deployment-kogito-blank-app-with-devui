FROM --platform=linux/amd64 quay.io/bamoe/canvas-dev-deployment-base:9.1.0-ibm-0001

ARG BAMOE_MAVEN_REPO_URL

USER root

ENV ROOT_PATH=""
ENV DEV_DEPLOYMENT__UPLOAD_SERVICE_EXTRACT_TO_DIR=$HOME_PATH/app/src/main/resources
ENV DEV_DEPLOYMENT__UPLOAD_SERVICE_PORT=8080

COPY --chown=$USER_ID:$USER_ID kogito-blank-app $HOME_PATH/app/

RUN sed -i -e "s|http://localhost:9000|http://${BAMOE_MAVEN_REPO_URL}|" $HOME_PATH/app/settings.xml

# Pre-populate local Maven repository for faster startup
RUN ./mvnw clean package -Dmaven.test.skip -Dmaven.repo.local=/tmp/kogito/.m2/repository -Dquarkus.http.non-application-root-path=${ROOT_PATH}/q -Dquarkus.http.root-path=${ROOT_PATH} \
  && chgrp -R 0 $HOME_PATH/app && chmod -R g=u $HOME_PATH/app && chgrp -R 0 /tmp/kogito && chmod -R g=u /tmp/kogito && chgrp -R 0 /.m2 && chmod -R g=u /.m2

USER $USER_ID

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c"]

CMD ["dev-deployment-upload-service && cp -r $HOME_PATH/app/. /tmp/app && cd /tmp/app && ./mvnw quarkus:dev -o -Dquarkus.analytics.disabled=true -Ddebug=false -Dmaven.repo.local=/tmp/kogito/.m2/repository -Dquarkus.http.non-application-root-path=${ROOT_PATH}/q -Dquarkus.http.root-path=${ROOT_PATH}"]
