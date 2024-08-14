#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "./obj_dir/Vmem_block.h"
#include "./obj_dir/Vmem_block___024root.h"

#define MAX_SIM_TIME 200 
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vmem_block *dut = new Vmem_block;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    int flag  = 0;
    dut->clk_i = 1;
    dut->data_i =0XFFFFFFFFFFFFFFF0;
    dut->addr_i =0;
    while (sim_time < MAX_SIM_TIME) {
        if(dut->clk_i == 0) dut->clk_i = 1;
        else                dut->clk_i = 0;
        if(flag){
            dut->addr_i +=4;
            dut->data_i +=3;
        } else if(sim_time > MAX_SIM_TIME/2){
            dut->addr_i =0;
            dut->write_bits_i =0;
            dut->data_i = 0xFFFFFFFFFFFFFFF0;
            flag = 1;
        } else {
            dut->addr_i +=4;
            dut->write_bits_i = 8;
            dut->data_i +=3;
        }
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}


