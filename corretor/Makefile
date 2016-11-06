ENTRADAS=entradas/2016-11-06.in

GERADORES=$(patsubst %.in,%.sh,$(ENTRADAS))

BINARIOSA=$(patsubst %.c,%.e,$(wildcard exec/*.c))

bin: gabaritos $(BINARIOSA)

hoje: $(ENTRADAS) gabaritos $(BINARIOSA)
	@cd exec && bash ../../sols/run-tests.sh ../entradas/`date +"%Y-%m-%d"`.in

exec/ssimples.O0: ../sols/ribas-fair.cpp
	cd ../sols && make ssimples.O0
	cp ../sols/ssimples.O0 exec/

exec/simples.O2: ../sols/ribas-fair.cpp
	cd ../sols && make simples.O2
	cp ../sols/simples.O2 exec/

exec/ribastree.O2: ../sols/ribastree.cpp
	cd ../sols && make ribastree.O2
	cp ../sols/ribastree.O2 exec/

exec/%.e: exec/%.c
	gcc -O2 -static $^ -o $@

gabaritos: exec/ssimples.O0 exec/simples.O2 exec/ribastree.O2

entradas/%.in: %.sh
	bash $^ > $@

clean:
	rm -f $(ENTRADAS)
