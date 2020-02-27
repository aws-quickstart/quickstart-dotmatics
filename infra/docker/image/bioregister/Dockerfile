FROM tomcat:dotmatics-1.0

WORKDIR $CATALINA_HOME

ENV BROWSER_PROP_FILE /config/WEB-INF/browser.properties
ENV BROWSER_LICENSE_FILE /config/WEB-INF/dotmatics.license.txt
ENV BIOREGISTER_GROOVY /config/tmp/bioregister.groovy

COPY docker/image/bioregister/docker-entrypoint.bash /docker-entrypoint.bash
COPY docker/image/tomcat/goss/goss-buildtime.yaml /goss/tomcat/goss-buildtime.yaml
COPY docker/image/bioregister/goss /goss/bioregister/

RUN  goss -g /goss/tomcat/goss-buildtime.yaml validate
HEALTHCHECK --interval=1s --timeout=6s CMD goss -g /goss/bioregister/healthcheck.yaml validate

CMD ["bash","-x","/docker-entrypoint.bash"]