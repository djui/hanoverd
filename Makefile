all: hanoverd

# So that make knows about hanoverd's other dependencies.
-include hanoverd.deps

# Compute a file that looks like "hanoverd: file.go" for all go source files
# that hanoverd depends on.
hanoverd.deps:
	./generate-deps.sh hanoverd . > $@

hanoverd: hanoverd.deps
	# Build hanoverd using
	go generate
	docker build -t hanoverd-buildtime .
	docker run --rm hanoverd-buildtime cat /go/bin/hanoverd > ./hanoverd
	chmod +x ./hanoverd

release: hanoverd
	mv hanoverd hanoverd_linux_amd64
	gphr release -keep=true hanoverd_linux_amd64

iptables:
	cp $(shell which iptables) .
	sudo setcap 'cap_net_admin,cap_net_raw=+ep' iptables

test: hanoverd iptables
	PATH=$$PWD:$$PATH go test -v ./tests

# GNU Make instructions
.PHONY: release test
# Required for hanoverd.deps
.DELETE_ON_ERROR:
