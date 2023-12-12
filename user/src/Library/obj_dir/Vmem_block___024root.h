// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmem_block.h for the primary calling header

#ifndef VERILATED_VMEM_BLOCK___024ROOT_H_
#define VERILATED_VMEM_BLOCK___024ROOT_H_  // guard

#include "verilated.h"


class Vmem_block__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vmem_block___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(write_bits_i,3,0);
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk_i__0;
    CData/*0:0*/ __VactContinue;
    VL_IN16(addr_i,15,0);
    IData/*31:0*/ mem_block__DOT__less_and_equal_16__DOT__x;
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VactIterCount;
    VL_IN64(data_i,63,0);
    VL_OUT64(data_o,63,0);
    VlUnpacked<CData/*7:0*/, 65536> mem_block__DOT__less_and_equal_16__DOT__block;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vmem_block__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vmem_block___024root(Vmem_block__Syms* symsp, const char* v__name);
    ~Vmem_block___024root();
    VL_UNCOPYABLE(Vmem_block___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
