SHELL := /bin/bash

range:
	@export ODIN=odin; \
	if hash odin.exe 2>/dev/null; then \
		export ODIN=odin.exe; \
	fi; \
	$$ODIN run test/range -out:tymbaca.bin

run: 
	@export ODIN=odin; \
	if hash odin.exe 2>/dev/null; then \
		export ODIN=odin.exe; \
	fi; \
	$$ODIN run . -out:tymbaca.bin

