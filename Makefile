clean:
	rm -fr public

build: clean
	hugo

release: build deploy-dev check-dev deploy-prod check-prod

deploy-prod: build
	awsie tslw-infrastructure s3 sync public s3://cf:TheserverlesswayComWebBucket: --delete

deploy-dev: build
	awsie tslw-infrastructure s3 sync public s3://cf:DevelopmentTheserverlesswayComWebBucket: --delete

check-dev:
	linkchecker $(shell awsie tslw-infrastructure --command "echo cf:DevelopmentTheserverlesswayComWebBucketWebsiteUrl:")

check-prod:
	linkchecker https://theserverlessway.com

check-local:
	linkchecker http://docker.for.mac.localhost:1313