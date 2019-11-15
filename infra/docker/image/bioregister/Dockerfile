FROM tomcat:dotmatics

WORKDIR $CATALINA_HOME

ENV BROWSER_PROP_FILE /config/browser.properties
ENV BROWSER_LICENSE_FILE /config/dotmatics.license.txt
ENV BIOREGISTER_WAR_FILE /config/bioregister*.war
ENV BIOREGISTER_GROOVY /config/bioregister.groovy

#TODO replace with GOSS
HEALTHCHECK --interval=60s --timeout=60s --retries=4 CMD curl --fail http://127.0.0.1:8080/bioregister/ || exit 1

COPY docker/image/bioregister/docker-entrypoint.bash /docker-entrypoint.bash

COPY docker/image/bioregister/goss /goss

CMD ["bash","-x","/docker-entrypoint.bash"]

