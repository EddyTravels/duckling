.PHONY: builder

image:
	DOCKER_BUILDKIT=1 docker build -t duckling:latest .

builder:
	DOCKER_BUILDKIT=1 docker build -t duckling-builder --target builder .

test:
	DOCKER_BUILDKIT=1 docker build -t duckling-tester:latest --target tester .

server: image
	docker run -it -p 8000:8000 duckling:latest

repl: builder
	docker run -it duckling-builder:latest stack repl --no-load
