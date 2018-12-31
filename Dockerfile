FROM ereboros/musl:v1.1.20-bootstrap AS musl

FROM alpine:3.8 AS zlib
RUN [ "apk", "add", "--no-cache", "llvm5" ]
RUN [ "apk", "add", "--no-cache", "clang" ]
RUN [ "apk", "add", "--no-cache", "cmake" ]
RUN [ "apk", "add", "--no-cache", "ninja" ]

COPY --from=musl /include /dep/musl/include

WORKDIR /src
COPY zlib .

WORKDIR /build
ENV CFLAGS="-nostdinc -nostdlib -I/dep/musl/include"
RUN [ \
	"cmake", "/src", "-G", "Ninja", \
	"-DCMAKE_C_COMPILER=clang", \
	"-D_CMAKE_TOOLCHAIN_PREFIX=llvm-", \
	"-DHAVE_OFF64_T=1", \
	"-DCMAKE_C_COMPILER_WORKS=1" \
]
RUN [ "ninja", "zlibstatic" ]

WORKDIR /pkg/include
RUN [ "cp", "/src/zlib.h", "/build/zconf.h", "." ]

WORKDIR /pkg/lib
RUN [ "cp", "/build/libz.a", "." ]

FROM scratch
COPY --from=zlib /pkg /
