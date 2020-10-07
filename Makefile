.PHONY: builder

CONTAINER_NAME=duckling

builder:
	@DOCKER_BUILDKIT=1 docker build -t duckling-builder --target builder .

test:
	@DOCKER_BUILDKIT=1 docker build -t duckling-tester:latest --target tester .

image:
	@DOCKER_BUILDKIT=1 docker build -t duckling:latest .

server:
	@docker run -p 8000:8000 --rm --name ${CONTAINER_NAME} duckling:latest

repl: builder
	@docker run -it duckling-builder:latest stack repl --no-load
