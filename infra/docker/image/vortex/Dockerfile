FROM tomcat:dotmatics-1.0

WORKDIR $CATALINA_HOME

ENV DOTMATICS_LICENSE_FILE /symbolic_link/dotmatics.license.txt

HEALTHCHECK --interval=1s --timeout=6s CMD goss -g /goss/healthcheck.yaml validate

COPY docker/image/vortex/docker-entrypoint.bash /docker-entrypoint.bash
COPY docker/image/tomcat/goss/goss-buildtime.yaml /goss/tomcat/goss-buildtime.yaml
COPY docker/image/browser/goss /goss/browser/

CMD ["bash","-x","/docker-entrypoint.bash"]

#see https://medium.com/@aelsabbahy/docker-1-12-kubernetes-simplified-health-checks-and-container-ordering-with-goss-fa8debbe676c