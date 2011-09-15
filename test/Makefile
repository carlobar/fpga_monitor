TOPDIR?=$(shell pwd)
SYS_DIR=$(TOPDIR)/../rtl
CORES_DIR=$(TOPDIR)/../cores

DIR=$(TOPDIR)

SRC =					\
	$(SYS_DIR)/system.v

VINCDIR= 				\
	-I$(DIR)/unisims		\
	-I$(SYS_DIR)			\
	-I$(SYS_DIR)/../test/unisims	\
	-I$(CORES_DIR)/vga_controller/rtl	\
	-I$(CORES_DIR)/lcd_2x16/rtl	\
	-I$(CORES_DIR)/memory/rtl	\
	-I$(CORES_DIR)/phase_ctl/rtl	\
	-I$(CORES_DIR)/rot_button/rtl	\
	-I$(CORES_DIR)/graph/rtl	\
	-I$(CORES_DIR)/sampling/rtl	
	
SIM_SRC=						\
	$(wildcard $(TOPDIR)/unisims/*.v)		\
	$(wildcard $(CORES_DIR)/vga_controller/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/lcd_2x16/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/memory/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/phase_ctl/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/rot_button/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/graph/rtl/*.v)		\
	$(wildcard $(CORES_DIR)/sampling/rtl/*.v)		

EXEC = system_tb


all: ${EXEC} {EXEC}.vcd


{EXEC}.vcd: ${EXEC}
	./$(EXEC)
	
call_gtkwave: ${EXEC}.vcd
	gtkwave ${EXEC}.vcd

${EXEC}: $(SRC) $(SIM_SRC) system_tb.v
	rm -f $@.list
	@for i in `echo $^`; do \
	    echo $$i >> $@.list; \
	done
	rm -rf make.log
	iverilog -Tmax -v -D SIMULATION $(VINCDIR) $(LIBDIR) -c $@.list -o ${EXEC} -s $@ >> make.log 2>&1

clean:
	rm -f *.log  system ${EXEC} ${EXEC}.vcd *~ *.list *.png

.PHONY: clean

