CONTAINER_NAME := "dbarrosop-jekyll"

.PHONY: build
build:
	docker build . --tag $(CONTAINER_NAME):latest

.PHONY: serve
serve: stop build
	docker run -it --name $(CONTAINER_NAME) \
		-p 4000:4000 \
		-v $(PWD):/srv/jekyll \
		$(CONTAINER_NAME) \
		jekyll serve --config _config.yml --future --drafts --watch

.PHONY: stop
stop:
	@docker rm $(CONTAINER_NAME) -f || exit 0
