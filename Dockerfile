FROM public.ecr.aws/sam/build-nodejs20.x:latest AS builder

RUN dnf update -y && dnf groupinstall -y "Development Tools" && dnf install -y \
    glib2-devel expat-devel libjpeg-turbo-devel libpng-devel giflib-devel libexif-devel librsvg2-devel libtiff-devel lcms2-devel meson cmake nasm

ENV PREFIX_PATH=/opt
ENV PKG_CONFIG_PATH=${PREFIX_PATH}/lib/pkgconfig
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PREFIX_PATH}/lib

ENV LIBDE265_VERSION=1.0.15
ENV X265_VERSION=3.6
ENV LIBAOM_VERSION=3.9.0
ENV LIBHEIF_VERSION=1.17.6
ENV WEBP_VERSION=1.3.2
ENV VIPS_VERSION=8.15.2
ARG SHARP_VERSION
ENV SHARP_VERSION=${SHARP_VERSION}

# install libde265
RUN curl -L https://github.com/strukturag/libde265/releases/download/v${LIBDE265_VERSION}/libde265-${LIBDE265_VERSION}.tar.gz | tar zx && \
    cd libde265-${LIBDE265_VERSION} && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=${PREFIX_PATH} -DCMAKE_INSTALL_LIBDIR=${PREFIX_PATH}/lib .. && make V=1 && make install

# install x265
ARG BUILD_HEVC_ENCODER
RUN if [[ ${BUILD_HEVC_ENCODER} == 1 ]]; then curl -L https://bitbucket.org/multicoreware/x265_git/downloads/x265_${X265_VERSION}.tar.gz | tar zx && \
    cd x265_${X265_VERSION}/source && cmake -DCMAKE_INSTALL_PREFIX=${PREFIX_PATH} . && make V=1 && make install; fi

# install libaom
ARG BUILD_AV1_ENCODER
RUN curl -L https://storage.googleapis.com/aom-releases/libaom-${LIBAOM_VERSION}.tar.gz | tar zx && \
    cd libaom-${LIBAOM_VERSION} && cd build && cmake -DCONFIG_AV1_ENCODER=$BUILD_AV1_ENCODER -DBUILD_SHARED_LIBS=1 -DENABLE_TESTS=0 -DENABLE_DOCS=0 -DCMAKE_INSTALL_PREFIX=${PREFIX_PATH} -DCMAKE_INSTALL_LIBDIR=${PREFIX_PATH}/lib .. && make V=1 && make install

# install libheif
RUN curl -L https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz | tar zx && \
    cd libheif-${LIBHEIF_VERSION} && mkdir build && cd build && cmake --preset=release-noplugins -DCMAKE_INSTALL_PREFIX=${PREFIX_PATH} -DCMAKE_INSTALL_LIBDIR=${PREFIX_PATH}/lib .. && make V=1 && make install

# install libwebp
RUN curl -L https://github.com/webmproject/libwebp/archive/v${WEBP_VERSION}.tar.gz | tar zx && \
    cd libwebp-${WEBP_VERSION} && ./autogen.sh && ./configure --enable-libwebpmux --prefix=${PREFIX_PATH} --libdir=${PREFIX_PATH}/lib && make V=1 && make install

# install libvips
RUN curl -L https://github.com/libvips/libvips/archive/refs/tags/v${VIPS_VERSION}.tar.gz | tar zx && \
    cd libvips-${VIPS_VERSION} && meson setup build --prefix ${PREFIX_PATH} --libdir ${PREFIX_PATH}/lib -Dheif=enabled -Dheif-module=disabled && \
    cd build && meson compile && meson install

# install sharp
ARG BUILD_TARGET
RUN mkdir -p ${PREFIX_PATH}/nodejs && mkdir -p ${PREFIX_PATH}/sharp-lib && \
    npm install --prefix ${PREFIX_PATH}/nodejs node-addon-api node-gyp && npm --prefix ${PREFIX_PATH}/nodejs install --cpu=${BUILD_TARGET} --os=linux --foreground-scripts sharp@${SHARP_VERSION} && \
    rm -rf ${PREFIX_PATH}/nodejs/node_modules/\@img && \
    ldd ${PREFIX_PATH}/nodejs/node_modules/sharp/src/build/Release/sharp-linux-x64.node | awk '{print $3}' | xargs -I {} cp {} ${PREFIX_PATH}/sharp-lib && \
    npm uninstall node-addon-api node-gyp

FROM public.ecr.aws/sam/build-nodejs20.x:latest AS packager

ENV PREFIX_PATH=/opt

COPY --from=builder ${PREFIX_PATH}/sharp-lib ${PREFIX_PATH}/lib
COPY --from=builder ${PREFIX_PATH}/nodejs ${PREFIX_PATH}/nodejs

# test installation before packaging
COPY test.mjs .
COPY sample.heic .
COPY sample.avif .
ARG BUILD_HEVC_ENCODER
ARG BUILD_AV1_ENCODER
RUN BUILD_HEVC_ENCODER=${BUILD_HEVC_ENCODER} BUILD_AV1_ENCODER=${BUILD_AV1_ENCODER} node test.mjs

# packaging
RUN cd ${PREFIX_PATH} && zip -r /tmp/sharp-heif-lambda-layer.zip lib nodejs