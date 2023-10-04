// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VCLA_16.h for the primary calling header

#ifndef VERILATED_VCLA_16___024ROOT_H_
#define VERILATED_VCLA_16___024ROOT_H_  // guard

#include "verilated.h"


class VCLA_16__Syms;

class alignas(VL_CACHE_LINE_BYTES) VCLA_16___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(Ci,0,0);
    VL_OUT8(Co,0,0);
    CData/*0:0*/ __VactContinue;
    VL_IN16(A,15,0);
    VL_IN16(B,15,0);
    VL_OUT16(S,15,0);
    IData/*31:0*/ __VstlIterCount;
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    VCLA_16__Syms* const vlSymsp;

    // CONSTRUCTORS
    VCLA_16___024root(VCLA_16__Syms* symsp, const char* v__name);
    ~VCLA_16___024root();
    VL_UNCOPYABLE(VCLA_16___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
