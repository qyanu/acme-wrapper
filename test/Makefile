SHELL := /bin/bash
MAKEFLAGS=--warn-undefined-variables
TESTS = $(wildcard *.entrypoint.sh)
TEST_DEPS = $(patsubst %.entrypoint.sh, %.result, $(TESTS))

.PHONY: test
test: $(TEST_DEPS)

packages-depends.list: extract-depends.py ../debian/control
	./extract-depends.py ../ > $@

packages-build-depends.list: extract-build-depends.py ../debian/control
	./extract-build-depends.py ../ > $@

%.result: \
	%.entrypoint.sh \
	Dockerfile-test \
	packages-depends.list \
	packages-build-depends.list \
	#
	docker build \
	    --progress=plain \
	    --file=Dockerfile-test \
	    --build-arg=VERSION=$(VERSION) \
	    --build-arg=TESTNAME=$* \
	    --tag=qyanu/$(PROJECT)-test/$*:$(VERSION) \
	    --tag=qyanu/$(PROJECT)-test/$*:latest \
	    ..
	docker run --rm=true \
		--network=none \
	    qyanu/$(PROJECT)-test/$*:$(VERSION)
	# TODO: Question from my current self to my past self:
	#   Shouldn't there be some comparison of expected to actual output of acme-wrapper?
	@touch $@

clean:
	rm -rf \
	    packages-depends.list \
	    packages-build-depends.list \
	    #
