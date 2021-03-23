NAME=`ls -d src/*/ | cut -f2 -d'/'`

all: deps_opt test

test:
	crystal spec
deps:
	shards install
deps_update:
	shards update
deps_opt:
	@[ -d lib/ ] || make deps
doc:
	crystal docs

.PHONY: all run build release test deps deps_update doc
