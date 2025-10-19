# BrainTech Robotics – Tie-Breaker Engineering Makefile
SHELL := /bin/bash
.PHONY: all build test sync push clean

all: build test

build:
	@echo 'Building Tie-Breaker core modules...'
	@chmod +x src/loader/*.sh src/validator/*.sh || true

test:
	@echo 'Running validation tests...'
	@bash tests/test_local_pour.sh

sync:
	@echo 'Syncing to AIQ Motherbox...'
	rsync -avz --exclude '__pycache__' ./ aiq2:~/tie-breaker/

push:
	@git add .
	@git commit -m 'sync: automated Gold Protocol update'
	@git push

clean:
	@find . -name '__pycache__' -delete
	@echo 'Clean complete.'
