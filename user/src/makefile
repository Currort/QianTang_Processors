VERILATOR  = verilator
VCC        = $(VERILATOR) --cc


VFLAGS  = \
	--trace\
	--exe \
	-Wall \
	-j 0  \
	-y include \
	-y ALU_submodule \
	-y Library \
	-y Trap_submodule \

OBJ_DIR =   obj_dir
SRC     =   SOC.v 
CPPSRC  =   SOC.cpp
VSRC    =$(addprefix V, $(SRC))
VOUT_RUN    = $(OBJ_DIR)/$(patsubst %.v,%,$(VSRC))
VOUT_MK     = $(patsubst %.v,%.mk,$(VSRC))
VCD  =   waveform.vcd
GTKW :=

$(VCD) : $(VOUT_RUN) 
	./$(VOUT_RUN)

$(VOUT_RUN): $(VOUT_MK)
	make -C $(OBJ_DIR) -f $(VOUT_MK)

$(VOUT_MK) : $(SRC) $(CPPSRC)
	$(VCC) $(VFLAGS) $^

gtkwave: $(GTKW) $(VCD)
	gtkwave $<

clean:
	rm -rf $(OBJ_DIR)

	

