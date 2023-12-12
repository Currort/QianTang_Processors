VERILATOR  = verilator
VCC        = $(VERILATOR) --cc


VFLAGS  = \
	--trace\
	--exe \
	-Wall \
	-j 0  \


OBJ_DIR =   obj_dir
SRC     =   mem_block.v 
CPPSRC  =   mem_block_test.cpp
VSRC    =$(addprefix V, $(SRC))
VOUT_RUN    = $(OBJ_DIR)/$(patsubst %.v,%,$(VSRC))
VOUT_MK     = $(patsubst %.v,%.mk,$(VSRC))

TARGET  =   mem_block.vcd

$(TARGET) : $(VOUT_RUN) 
	./$(VOUT_RUN)

$(VOUT_RUN): $(VOUT_MK)
	make -C $(OBJ_DIR) -f $(VOUT_MK)

$(VOUT_MK) : $(SRC) $(CPPSRC)
	$(VCC) $(VFLAGS) mem_block.v  mem_block_test.cpp

clean:
	rm -rf $(OBJ_DIR)

	

