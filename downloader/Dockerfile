# alpine is a lightweight linux image.  This is step 2.  This is for persistent
# data when containers are removed.
# apk is alpine version of apt-get
# making git clone the entry point and will specify a clone url (project repo)

FROM alpine:latest
RUN apk update && apk add git
WORKDIR /scan-target
ENTRYPOINT ["git", "clone"]