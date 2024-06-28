cp -r $HOME_PATH/app/. /tmp/app
cd /tmp/app
./mvnw quarkus:dev -o -Dquarkus.analytics.disabled=true -Ddebug=false -Dquarkus.http.non-application-root-path=$ROOT_PATH/q -Dquarkus.http.root-path=$ROOT_PATH