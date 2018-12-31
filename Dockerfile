FROM ereboros/musl:v1.1.20-bootstrap AS musl

FROM alpine:3.8 AS zlib
RUN [ "apk", "add", "--no-cache", "llvm5" ]
RUN [ "apk", "add", "--no-cache", "clang" ]
RUN [ "apk", "add", "--no-cache", "cmake" ]
RUN [ "apk", "add", "--no-cache", "ninja" ]

COPY --from=musl / /usr

WORKDIR /src
COPY zlib .

WORKDIR /build
RUN [ \
	"cmake", "/src", "-G", "Ninja", \
	"-DCMAKE_C_COMPILER=clang", \
	"-D_CMAKE_TOOLCHAIN_PREFIX=llvm-", \
	"-DHAVE_OFF64_T=1", \
	"-DCMAKE_C_COMPILER_WORKS=1" \
]
RUN [ "ninja", "zlibstatic" ]

WORKDIR /pkg/lib
RUN [ "cp", "/src/zlib.h", "/build/zconf.h", "." ]

WORKDIR /pkg/include
RUN [ "cp", "/build/libz.a", "." ]

FROM scratch
COPY --from=zlib /pkg /
