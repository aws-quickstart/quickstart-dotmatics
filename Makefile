# @author Laurent Krishnathas
# @year 2018
# WARNING: Used in CI and production, please do not modify without DevOps authorization
#


# Need to run outside the repo so it can be uploaded to s3
# -n  : keep stack after test or on failure
# -P : aws profile

QSS3KeyPrefix=quickstart-dotmatics/

taskcat:
	cd .. && \
	pwd && \
	taskcat -c quickstart-dotmatics/ci/config.vpc.yml  -P taskcat_test -v

taskcat_debug:
	cd .. && \
	pwd && \
	taskcat -c quickstart-dotmatics/ci/config.vpc.yml -n -P taskcat_test -t user=$$(whoami) -s $$(whoami)

initialize:
	git submodule init
	git submodule update


copy_oraclebins:
	aws s3 cp   s3://devspacepaul/oraclebins/linuxx64_12201_database.zip s3://quickstart-test-dotmatics-devops-v2/oraclebins/linuxx64_12201_database.zip
	aws s3 cp   s3://devspacepaul/oraclebins/linuxx64_12201_grid_home.zip s3://quickstart-test-dotmatics-devops-v2/oraclebins/linuxx64_12201_grid_home.zip
	aws s3 cp   s3://devspacepaul/oraclebins/oracleasmlib-2.0.12-1.el7.x86_64.rpm s3://quickstart-test-dotmatics-devops-v2/oraclebins/oracleasmlib-2.0.12-1.el7.x86_64.rpm

APP_INSTANCE_NAME_TAG=Dotmatics App Server
ssm_app_server: check_aws_profile
	aws ssm start-session --target $$(aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:Name,Values=$(APP_INSTANCE_NAME_TAG)" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output=text)

DB_INSTANCE_NAME_TAG=dotmtsdb
ssm_db_server: check_aws_profile
	aws ssm start-session --target $$(aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:Name,Values=$(DB_INSTANCE_NAME_TAG)" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output=text)


