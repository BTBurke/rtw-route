FROM ghcr.io/gis-ops/docker-valhalla/valhalla:latest

ARG TARFILE=valhalla_tiles
ENV serve_tiles True
ENV traffic_name ""
ENV tileset_name ${TARFILE}
COPY ./custom_files/ /custom_files/

