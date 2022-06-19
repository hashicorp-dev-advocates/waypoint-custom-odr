DOCKER_REGISTRY=nicholasjackson/waypoint-custom-odr
DOCKER_TAG=0.1.0

build-odr-dev:
	DOCKER_BUILDKIT=1 docker build --progress=plain -f Dockerfile -t ${DOCKER_REGISTRY}:0.1.0 .

build-odr-multi-arch:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multi || true
	docker buildx use multi
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/arm64,linux/amd64 \
		-t ${DOCKER_REGISTRY}:${DOCKER_TAG} \
    -f ./Dockerfile \
    .  \
		--push
	docker buildx rm multi
