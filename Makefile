
TAG=digineode/discourse:latest

.PHONY: image
image:
	docker build -t ${TAG} .

.PHONY: push
push: image
	docker push ${TAG}
