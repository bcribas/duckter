
BINARIOS=simples.O0\
				 simples.O2\
				 ssimples.O0\
				 ssimples.O2\
				 ssimplesDP.O3\
				 simplesDP.O3\
				 ssimplesDT.O2\
				 simplesDT.O2\
				 ssimplesDT.O0\
				 simplesDT.O0\
				 ssimplesRP.O2\
				 simplesRP.O2\
				 ssimplesRP.O0\
				 simplesRP.O0\
				 ribastree.O2\
				 marcustree.epp\
				 cpastro-first.e

TESTES=$(wildcard ../samples/*.in)
RESULTADOSTESTES=$(sort $(patsubst ../samples/%.in,%.result,$(TESTES)))

CFLAGS=-static
CXXFLAGS=$(CFLAGS)

all: $(BINARIOS)
	@echo "Voce pode rodar os experimentos com o comando:"
	@echo "  $ cd ../samples && make"
	@echo "  $ make run-samples"

%.epp:
	g++ $(CFLAGS) -O2 $(subst .epp,.cpp,$@) -o $@

%.e:
	gcc $(CFLAGS) -O2 $(subst .e,.c,$@) -o $@

simples.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -$(subst .,,$(suffix $@)) $^ -o $@

ssimples.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__SUPERSIMPLES -$(subst .,,$(suffix $@)) $^ -o $@

ssimplesDP.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__SUPERSIMPLES -D__DUMBPIVOT -$(subst .,,$(suffix $@)) $^ -o $@

ssimplesDT.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__SUPERSIMPLES -D__DUMBTRENDING -$(subst .,,$(suffix $@)) $^ -o $@

ssimplesRP.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__SUPERSIMPLES -D__RPIVOT -$(subst .,,$(suffix $@)) $^ -o $@

simplesRP.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__RPIVOT -$(subst .,,$(suffix $@)) $^ -o $@

simplesDP.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__DUMBPIVOT -$(subst .,,$(suffix $@)) $^ -o $@

simplesDT.O%: ribas-fair.cpp
	g++ $(CXXFLAGS) -D__DUMBTRENDING -$(subst .,,$(suffix $@)) $^ -o $@

ribastree.O%: ribastree.cpp
	g++ -std=c++14 $(CXXFLAGS) -$(subst .,,$(suffix $@)) $^ -o $@

all-samples.result: $(RESULTADOSTESTES)
	cat $(RESULTADOSTESTES) |tee all-samples.result

run-samples: /usr/bin/time run-tests $(BINARIOS) $(RESULTADOSTESTES) all-samples.result

%.result: ../samples/%.in
	@printf "Generating $@"
	@bash ./run-tests $^ > $@
	@echo .
	@cat $@


clean:
	rm -f $(BINARIOS)
	rm -f $(RESULTADOSTESTES)
	rm -rf run-tests
