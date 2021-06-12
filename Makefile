all: *.v
	iverilog -o pedestrian pedestrian_tb.v pedestrian.v
	vvp pedestrian > pedestrian.log
	cat pedestrian.log
	gtkwave pedestrian_tb.gtkw
   
clean:
	exec rm -f pedestrian_tb.vcd
	exec rm -f pedestrian
	exec rm -f pedestrian.log
