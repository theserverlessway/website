clean:
	rm -fr public

build: clean
	hugo

deploy: build dev-deploy check
	awsie tslw-infrastructure s3 sync public s3://cf:TheserverlesswayComWebBucket: --delete

dev-deploy: build
	awsie tslw-infrastructure s3 sync public s3://cf:DevelopmentTheserverlesswayComWebBucket: --delete

check:
	linkchecker $(shell awsie tslw-infrastructure --command "echo cf:DevelopmentTheserverlesswayComWebBucketWebsiteUrl:")

check-local:
	linkchecker http://docker.for.mac.localhost:1313