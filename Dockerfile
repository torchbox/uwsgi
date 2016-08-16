# Torchbox build of uWSGI.  Note that this is the nolang core only - it does
# not include any language support.  uWSGI source is left in /usr/src/uwsgi
# to allow building uWSGI plugins for language-specific containers.

FROM alpine:3.4

ENV LANG C.UTF-8

COPY . /usr/src/uswgi

RUN apk add --no-cache ca-certificates mailcap

RUN	set -ex								\
	&& apk add --no-cache --virtual .uwsgi-builddeps 		\
		pcre-dev gcc git libc-dev zlib-dev openssl-dev make 	\
		linux-headers python					\
	&& cp -r /usr/src/uwsgi /usr/src/uwsgi-build			\
	&& cd /usr/src/uwsgi-build					\
	&& make PROFILE=nolang						\
	&& cp uwsgi /usr/local/bin/uwsgi				\
	&& ln -s /usr/local/bin/uwsgi /					\
	&& cd /								\
	&& rm -rf /usr/src/uwsgi-build					\
	&& runDeps="$(							\
		scanelf --needed --nobanner --recursive /usr/local	\
		| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }'	\
		| sort -u						\
		| xargs -r apk info --installed				\
		| sort -u						\
		)"							\
	&& apk add --virtual .uwsgi-rundeps $runDeps			\
	&& rm -rf ~/.cache

CMD ["/bin/sh"]
