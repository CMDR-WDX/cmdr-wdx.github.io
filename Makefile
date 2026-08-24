.PHONY: run
.PHONY: build
run:
	uv run zensical serve
build:
	uv run zensical build
spell:
	uv run typos
spell-fix:
	uv run typos -w
fix: spell-fix
	