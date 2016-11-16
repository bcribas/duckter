ENTRADAS=01-sample1-verysmall.in\
					02-sample2-verysmall.in\
					03-sample3-small.in\
					04-sample4-smallstress.in\
					05-sample5-hugeforasample.in\
					06-sample6-crazytrending.in\
					07-sample7-crazytrending2.in\
					08-sample8-newday-rises.in\
					09-sample9-newday-twodays.in\
					10-sample10-newday-craydays.in

GERADORES=$(patsubst %.in,../gerador/%.sh,$(ENTRADAS))

all: $(ENTRADAS)

%.in: ../gerador/%.sh
	cd ../gerador && bash $^ > ../samples/$@

clean:
	rm -f $(ENTRADAS)
