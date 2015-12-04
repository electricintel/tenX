DEBUG ?= 0
STATIC ?= 0

# Submodules
PWD = $(shell pwd)
SEQTK_ROOT ?= ${PWD}/src/htslib/
BOOST_ROOT ?= ${PWD}/src/modular-boost/
DELLY_ROOT ?= ${PWD}/src/delly/src/

# Flags
CXX=g++
CXXFLAGS += -isystem ${SEQTK_ROOT} -isystem ${BOOST_ROOT} -isystem ${DELLY_ROOT} -pedantic -W -Wall -Wno-unknown-pragmas
LDFLAGS += -L${SEQTK_ROOT} -L${BOOST_ROOT}/stage/lib -lboost_iostreams -lboost_filesystem -lboost_system -lboost_program_options -lboost_date_time

# Additional flags for release/debug
ifeq (${STATIC}, 1)
	LDFLAGS += -static -static-libgcc -pthread -lhts -lz
else
	LDFLAGS += -lhts -lz -Wl,-rpath,${SEQTK_ROOT},-rpath,${BOOST_ROOT}/stage/lib
endif
ifeq (${DEBUG}, 1)
	CXXFLAGS += -g -O0 -fno-inline -DDEBUG
else ifeq (${DEBUG}, 2)
	CXXFLAGS += -g -O0 -fno-inline -DPROFILE
	LDFLAGS += -lprofiler -ltcmalloc
else
	CXXFLAGS += -O9 -DNDEBUG
endif

# External sources
BOOSTSOURCES = $(wildcard src/modular-boost/libs/iostreams/include/boost/iostreams/*.hpp)
HTSLIBSOURCES = $(wildcard src/htslib/*.c) $(wildcard src/htslib/*.h)
SVSOURCES = $(wildcard src/*.h) $(wildcard src/*.cpp)

# Targets
TARGETS = .htslib .boost src/genoDEL src/genoINS src/scaffold

all:   	$(TARGETS)

.htslib: $(HTSLIBSOURCES)
	cd src/htslib && make && make lib-static && cd ../../ && touch .htslib

.boost: $(BOOSTSOURCES)
	cd src/modular-boost && ./bootstrap.sh --prefix=${PWD}/src/modular-boost --without-icu --with-libraries=iostreams,filesystem,system,program_options,date_time && ./b2 && ./b2 headers && cd ../../ && touch .boost

src/genoDEL: .htslib .boost $(SVSOURCES)
	$(CXX) $(CXXFLAGS) $@.cpp -o $@ $(LDFLAGS)

src/genoINS: .htslib .boost $(SVSOURCES)
	$(CXX) $(CXXFLAGS) $@.cpp -o $@ $(LDFLAGS)

src/scaffold: .htslib .boost $(SVSOURCES)
	$(CXX) $(CXXFLAGS) $@.cpp -o $@ $(LDFLAGS)

clean:
	cd src/htslib && make clean
	cd src/modular-boost && ./b2 --clean-all
	rm -f $(TARGETS) $(TARGETS:=.o) .htslib .boost
