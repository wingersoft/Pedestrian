all: *.v
	iverilog -o pedestrian *.v
	vvp pedestrian > pedestrian.log
	cat pedestrian.log
	gtkwave pedestrian_tb.gtkw 2> /dev/null
   
clean:
	rm -f pedestrian.vcd
	rm -f pedistrian
	rm -f pedistrian.log
