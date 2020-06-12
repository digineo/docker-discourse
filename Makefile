
VERSION=master
REPO=digineode/discourse

.PHONY: build
build:
	docker build -t ${REPO}:latest --build-arg "VERSION=${VERSION}" .

.PHONY: push
push: build
	docker push ${REPO}:latest
ifneq ($(VERSION),master)
	docker tag  ${REPO}:latest ${REPO}:${VERSION}
	docker push ${REPO}:${VERSION}
endif

