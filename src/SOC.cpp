#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "./obj_dir/VSOC.h"
#include "./obj_dir/VSOC___024root.h"
#include "./obj_dir/VSOC_CLA_16__G1.h"
#include "./obj_dir/VSOC__Syms.h"

#define MAX_SIM_TIME 2000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    VSOC *dut = new VSOC;
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");
    int flag  = 0;
    dut->clk_sys_i = 1;
    dut->rst_i     = 1;
    while (sim_time < MAX_SIM_TIME) {
        if(dut->clk_sys_i == 0) dut->clk_sys_i = 1;
        else                    dut->clk_sys_i = 0;
        if(sim_time == 20) dut->rst_i =0;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}


