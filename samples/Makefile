ENTRADAS=01-sample1-verysmall.in\
					02-sample2-verysmall.in\
					03-sample3-small.in\
					04-sample4-smallstress.in\
					05-sample5-hugeforasample.in

GERADORES=$(patsubst %.in,../gerador/%.sh,$(ENTRADAS))

all: $(ENTRADAS)

%.in: ../gerador/%.sh
	cd ../gerador && bash $^ > ../samples/$@
