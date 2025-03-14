SHELL := /bin/bash

run: shader
	@export ODIN=odin; \
	if hash odin.exe 2>/dev/null; then \
		export ODIN=odin.exe; \
	fi; \
	$$ODIN run . -out:tymbaca.bin

shader: 
	@echo ""
