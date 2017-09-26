clean:
	rm -fr public

build: clean
	hugo

deploy: build
	awsie tslw-infrastructure s3 sync public s3://cf:TheserverlesswayComWebBucket: --delete