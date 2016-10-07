GERADORES=01-sample1-verysmall\
					02-sample2-verysmall\
					03-sample3-small\
					04-sample4-smallstress\
#					05-sample5-hugeforasample

all: $(GERADORES)

%: ../gerador/%.sh
	cd ../gerador && bash $@.sh > ../samples/$@
