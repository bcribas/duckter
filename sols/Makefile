
BINARIOS=simples.O0\
				 simples.O2\
				 simples.O3\
				 ssimples.O0\
				 ssimples.O2\
				 ssimples.O3\
				 ssimplesDP.O3\
				 simplesDP.O3\
				 ribastree.O3\
				 ribastree.O0\
				 ribastree.O2

TESTES=$(wildcard ../samples/*.in)
RESULTADOSTESTES=$(patsubst ../samples/%.in,%.result,$(TESTES))

all: $(BINARIOS)
	@echo "Voce pode rodar os experimentos com o comando:"
	@echo "  $ cd ../samples && make"
	@echo "  $ make run-samples"

ssimples.O%: ribas-fair.cpp
	g++ -D__SUPERSIMPLES -O$(subst ssimples.O,,$@) $^ -o $@

ssimplesDP.O%: ribas-fair.cpp
	g++ -D__SUPERSIMPLES -D__DUMBPIVOT -O$(subst ssimplesDP.O,,$@) $^ -o $@

simplesDP.O%: ribas-fair.cpp
	g++ -D__DUMBPIVOT -O$(subst simplesDP.O,,$@) $^ -o $@

simples.O%: ribas-fair.cpp
	g++ -O$(subst simples.O,,$@) $^ -o $@

ribastree.O%: ribastree.cpp
	g++ -O$(subst ribastree.O,,$@) $^ -o $@

all-samples.result: $(RESULTADOSTESTES)
	cat $(RESULTADOSTESTES) |tee all-samples.result

run-samples: /usr/bin/time run-tests $(BINARIOS) $(RESULTADOSTESTES) all-samples.result

%.result: ../samples/%.in
	@printf "Generating $@"
	@bash ./run-tests $^ > $@
	@echo .


clean:
	rm -f $(BINARIOS)
	rm -f $(RESULTADOSTESTES)
	rm -rf run-tests
