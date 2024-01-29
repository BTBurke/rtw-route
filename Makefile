NOW=$(shell date -u +%Y%m%d)
SHELL=/bin/bash -o pipefail
REGISTRY=us-central1-docker.pkg.dev/rtwrun/rtw-route

asia: prep
	wget -q -O custom_files/asia-latest.osm.pbf https://download.geofabrik.de/asia-latest.osm.pbf
	$(MAKE) build_tiles NAME=$@

stans: prep
	wget -P ./custom_files/ \
	https://download.geofabrik.de/asia/kazakhstan-latest.osm.pbf \
	https://download.geofabrik.de/asia/kyrgyzstan-latest.osm.pbf \
	https://download.geofabrik.de/asia/uzbekistan-latest.osm.pbf \
	https://download.geofabrik.de/asia/tajikistan-latest.osm.pbf \
	https://download.geofabrik.de/asia/turkmenistan-latest.osm.pbf
	$(MAKE) build_tiles NAME=$@
	
andorra: prep
	wget -q -O $@ https://download.geofabrik.de/europe/andorra-latest.osm.pbf
	$(MAKE) build_tiles NAME=$@

prep:
	mkdir -p custom_files
	mkdir -p custom_files/admin_data custom_files/timezone_data
	cp valhalla.json custom_files/

build_tiles:
	docker run --rm -v ${PWD}/custom_files:/custom_files -p 8002:8002 -e tileset_name=${NAME}_tiles --name valhalla -e serve_tiles=False -e build_admins=True -e build_time_zones=True -e force_rebuild=True ghcr.io/gis-ops/docker-valhalla/valhalla:latest
	docker build -t ${REGISTRY}/${NAME}:latest -t ${REGISTRY}/${NAME}:${NOW} .
	docker push ${REGISTRY}/${NAME} --all-tags

iso-country.json:
	cat countries-110m.json | jq '[.objects.countries.geometries | .[] | select(.id != null) | {(.id): (.properties.name)} | select (. != null)]' > $@

country-iso.json:
	cat countries-110m.json | jq '[.objects.countries.geometries | .[] | select(.id != null) | {(.properties.name): (.id)} | select (. != null)]' > $@

.PHONY: prep stans build_tiles _dirs andorra asia
