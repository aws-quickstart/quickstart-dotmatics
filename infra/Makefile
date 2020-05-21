# @author Laurent Krishnathas
# @year 2018
# WARNING: Used in CI and production, please do not modify without DevOps authorization
#

GRADLE=./gradlew
ifeq ($(OS),Windows_NT)
	GRADLE=./gradlew.bat
endif

BUILD_DIR=target

clean:
	rm -rf $(BUILD_DIR)
#****************************************************************************************************#

ENV=development
BRO_STACK_NAME=browser-$(ENV)
SERVICE=SERVICE_not_defined

IMAGE_TAG=dotmatics-1.0


TOMCAT_TAR_FILE=$(shell ls docker/image/tomcat/apache*.tar.gz)

build_tomcat_images:
	echo TOMCAT_TAR_FILE=$(TOMCAT_TAR_FILE)
	docker build --tag=tomcat:$(IMAGE_TAG) --build-arg TOMCAT_TAR_FILE=$(TOMCAT_TAR_FILE) --rm=false -f docker/image/tomcat/Dockerfile .

build_docker_images: build_tomcat_images
	docker build --tag=browser:$(IMAGE_TAG)     --rm=false -f docker/image/browser/Dockerfile .
	docker build --tag=bioregister:$(IMAGE_TAG) --rm=false -f docker/image/bioregister/Dockerfile .
	docker build --tag=vortex:$(IMAGE_TAG)      --rm=false -f docker/image/vortex/Dockerfile .

dgoss_run: build_docker_images
	GOSS_FILES_PATH=docker/image/browser/goss GOSS_SLEEP=15 dgoss run browser:latest

dgoss_edit: build_docker_images
	GOSS_FILES_PATH=docker/image/browser/goss dgoss edit browser:latest

stack_create_network:
	docker network create -d overlay --attachable bro_ft_end || true
	docker network create -d overlay --attachable bro_bk_end || true

stack_rm_network:
	docker network rm bro_ft_end
	docker network rm bro_bk_end

create_volume_dir:
	mkdir -p $$PWD/target/docker/volume/$(ENV)

stack_deploy_browser: build_docker_images stack_create_network docker_cleanup create_volume_dir
	 ENV=$(ENV) BRO_STACK_NAME=$(BRO_STACK_NAME) ./makefile.sh stack_deploy_browser

stack_rm:  stack_rm_browser

stack_rm_browser:
	docker stack rm $(BRO_STACK_NAME)


scale_down_bioregister:
	ls -ls /efs/data/
	docker service scale browser-$(ENV)_bioregister=0

scale_down_vortex:
	ls -ls /efs/data/
	docker service scale browser-$(ENV)_vortex=0



docker_cleanup:
	docker volume prune -f  || true

