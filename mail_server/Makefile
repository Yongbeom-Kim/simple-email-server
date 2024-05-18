ifeq "$(PORT)" ""
	PORT=8080
endif

ifeq "$(IMAGE_TAG)" ""
	IMAGE_TAG=mail_server_test_image
endif

dev:
	flask --app app run --reload --port $(PORT) --host 0.0.0.0

build: .venv
	. .venv/bin/activate && pip install -r requirements.txt

docker_build: build
	docker build -t $(IMAGE_TAG) --build-arg PORT=$(PORT) .

docker_run:
	docker run -it -p $(PORT):$(PORT) $(IMAGE_TAG)