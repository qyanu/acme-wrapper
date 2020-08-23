
TESTS = $(wildcard *.entrypoint.sh)
RESULTS = $(patsubst %.entrypoint.sh, %.result, $(TESTS))
.PHONY: test
test: $(RESULTS)

test-base.built: Dockerfile-base acme-wrapper.tar.bz2
	chronic docker build \
		--file=Dockerfile-base --build-arg=VERSION=$(VERSION) \
		--tag=qyanu/acme-wrapper-test:$(VERSION) \
		--tag=qyanu/acme-wrapper-test:latest \
		.
	@touch $@

%.result: %.entrypoint.sh Dockerfile-test test-base.built
	chronic docker build \
		--file=Dockerfile-test --build-arg=VERSION=$(VERSION) \
		--build-arg=TESTNAME=$* \
		--tag=qyanu/acme-wrapper-test/$*:$(VERSION) \
		--tag=qyanu/acme-wrapper-test/$*:latest \
		.
	docker run --rm=true \
		qyanu/acme-wrapper-test/$*:$(VERSION)
	@touch $@
