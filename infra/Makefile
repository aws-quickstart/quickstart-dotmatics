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

TOMCAT_TAG=dotmatics
TOMCAT_TAR_FILE=$(shell ls docker/image/tomcat/apache*.tar.gz)

BIOREGISTER_WAR=$(shell ls /efs/config/browser/bioregister-*.war)
BIOREGISTER_GROOVY=/efs/config/browser/bioregister.groovy


build_tomcat_images:
	echo TOMCAT_TAR_FILE=$(TOMCAT_TAR_FILE)
	docker build --tag=tomcat:$(TOMCAT_TAG) --build-arg TOMCAT_TAR_FILE=$(TOMCAT_TAR_FILE) --rm=false -f docker/image/tomcat/Dockerfile .

build_docker_images: build_tomcat_images
	docker build --tag=browser:latest     --rm=false -f docker/image/browser/Dockerfile .
	docker build --tag=bioregister:latest --rm=false -f docker/image/bioregister/Dockerfile .

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
	$(eval MEM_80_PCT=$(shell grep MemTotal /proc/meminfo | awk '{print $$2 / 1024*80/100"m"}'  ))
	$(eval MEM_40_PCT=$(shell grep MemTotal /proc/meminfo | awk '{print $$2 / 1024*40/100"m"}'  ))
	$(eval MEM_10_PCT=$(shell grep MemTotal /proc/meminfo | awk '{print $$2 / 1024*10/100"m"}'  ))

	echo $(MEM_80_PCT) >  $$PWD/target/mem80pct
	echo $(MEM_40_PCT) >  $$PWD/target/mem40pct
	echo $(MEM_10_PCT) >  $$PWD/target/mem10pct

	ls -ls /efs/config/browser/
ifeq (,$(wildcard $(BIOREGISTER_GROOVY)))
	$(warning [WARN] $(BIOREGISTER_GROOVY) doesn't exist. It won't deploy bioregister. )
	BROWSER_LIMIT_MEM=$(MEM_80_PCT)  BIOREGISTER_LIMIT_MEM=$(MEM_10_PCT)  TRAEFIK_LIMIT_MEM=$(MEM_10_PCT)	STACK_NAME=$(BRO_STACK_NAME) ENV=$(ENV) docker stack deploy --with-registry-auth  -c docker/stack/browser/browser.yml -c docker/stack/browser/browser-$(ENV).yml $(BRO_STACK_NAME)
	make scale_down_bioregister ENV=$(ENV)

else ifeq (,$(wildcard $(BIOREGISTER_WAR)))
	$(warning [WARN] $(BIOREGISTER_WAR) doesn't exist. It won't deploy bioregister. )
	BROWSER_LIMIT_MEM=$(MEM_80_PCT)  BIOREGISTER_LIMIT_MEM=$(MEM_10_PCT)  TRAEFIK_LIMIT_MEM=$(MEM_10_PCT)	STACK_NAME=$(BRO_STACK_NAME) ENV=$(ENV) docker stack deploy --with-registry-auth  -c docker/stack/browser/browser.yml -c docker/stack/browser/browser-$(ENV).yml $(BRO_STACK_NAME)
	make scale_down_bioregister ENV=$(ENV)
else
	BROWSER_LIMIT_MEM=$(MEM_40_PCT)  BIOREGISTER_LIMIT_MEM=$(MEM_40_PCT)  TRAEFIK_LIMIT_MEM=$(MEM_10_PCT)	STACK_NAME=$(BRO_STACK_NAME) ENV=$(ENV) docker stack deploy --with-registry-auth  -c docker/stack/browser/browser.yml -c docker/stack/browser/browser-$(ENV).yml $(BRO_STACK_NAME)

endif


stack_rm:  stack_rm_browser

stack_rm_browser:
	docker stack rm $(BRO_STACK_NAME)


scale_down_bioregister:
	ls -ls /efs/config/browser/
	docker service scale browser-$(ENV)_bioregister=0



docker_cleanup:
	docker volume prune -f  || true

