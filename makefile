SHELL := /bin/bash

run: 
	@export ODIN=odin; \
	$$ODIN run . -out:tymbaca.bin
	# if hash odin.exe 2>/dev/null; then \
	# 	export ODIN=odin.exe; \
	# fi; \
	$$ODIN run . -out:tymbaca.bin

range:
	@export ODIN=odin; \
	if hash odin.exe 2>/dev/null; then \
		export ODIN=odin.exe; \
	fi; \
	$$ODIN run test/range -out:tymbaca.bin

