clean:
	rm -fr public

update:
	git submodule update --recursive --remote

build: clean update
	hugo

run: update
	hugo server

release: build deploy-dev deploy-prod
	echo RELEASED NEW WEBSITE

deploy-prod: build
	awsie tslw-infrastructure s3 sync public s3://cf:CloudfrontWebBucket: --delete

deploy-dev: build
	awsie tslw-infrastructure s3 sync public s3://cf:CloudfrontdevelopmentWebBucket: --delete

check-dev:
	linkchecker https://dev.theserverlessway.com

check-prod:
	linkchecker https://theserverlessway.com

check-local:
	linkchecker http://docker.for.mac.localhost:1313
