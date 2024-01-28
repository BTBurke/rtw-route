NOW=$(date -u +%Y%m%d)
SHELL=/bin/bash -o pipefail

iso-country.json:
	cat countries-110m.json | jq '[.objects.countries.geometries | .[] | select(.id != null) | {(.id): (.properties.name)} | select (. != null)]' > $@

country-iso.json:
	cat countries-110m.json | jq '[.objects.countries.geometries | .[] | select(.id != null) | {(.properties.name): (.id)} | select (. != null)]' > $@

.PHONY: build_tiles
build_tiles:
	docker run --rm -v ${PWD}/custom_files:/custom_files -p 8002:8002 -e tileset_name=${NAME}_tiles --name valhalla -e serve_tiles=False -e build_admins=True -e build_time_zones=True -e force_rebuild=True ghcr.io/gis-ops/docker-valhalla/valhalla:latest

andorra: custom_files/andorra-latest.osm.pbf
	$(MAKE) build_tiles NAME=$@

.PHONY: _dirs
_dirs:
	mkdir -p custom_files
	mkdir -p custom_files/admin_data custom_files/timezone_data
	cp valhalla.json custom_files/

custom_files/andorra-latest.osm.pbf: _dirs
	wget -O custom_files/$@ https://download.geofabrik.de/europe/$@
