FROM debian:latest as base
# pulling latest debian image to use as base and build upon.  It is not
# best security practice to pull latest - we  should always use a specific
# tag with a hash to verify integrity.


RUN apt-get -y update && apt-get -y install \
    curl
# updating the packages present in the image.  -y inputs yes to proceed
# then I install curl because I need this to install syft

RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
RUN syft --version
# install syft the run syft --verion to confirm as requested

FROM cyclonedx/cyclonedx-cli as cyclonedx
# pulled cyclonedx-cli image since it is available on Docker Hub

FROM python:3-slim as final
# pull a light-weight python image to put python project in.

WORKDIR /app
# set location to install language package

RUN pip install cyclonedx-bom
# install python language plugin. pip is the package installer for python

RUN apt-get update -y && apt-get install -y \
    libicu-dev curl jq
# Cyclonedx is an app written in C# and has a dependency on libicu-dev.
# libicu-dev is a development package that provides advanced Unicode and
# globalization support for software applications. Will also need curl in
# this container to connect to the dependencytrack later on.  Used jq as a
#  way to restructure JSON output from cyclonedx.  Dependencytrack's API needs
# data in a certain format.


RUN useradd appuser
USER appuser
# adding a non-root user and switching to it

COPY --from=base /usr/local/bin/syft /usr/local/bin/syft
# have to copy since every build stage starts over

COPY --from=cyclonedx /cyclonedx /usr/local/bin/cyclonedx

COPY --chown=appuser:appuser ./scan.sh /app/scan.sh

ENTRYPOINT ["/app/scan.sh"]
# this is the first command that is going to run in the container. Turns my
# container into an executable that accepts arguments.  Without it I would be
# in a python shell because I would be executing python:3-slim's CMD
