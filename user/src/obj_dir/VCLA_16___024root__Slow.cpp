// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VCLA_16.h for the primary calling header

#include "verilated.h"

#include "VCLA_16__Syms.h"
#include "VCLA_16__Syms.h"
#include "VCLA_16___024root.h"

void VCLA_16___024root___ctor_var_reset(VCLA_16___024root* vlSelf);

VCLA_16___024root::VCLA_16___024root(VCLA_16__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    VCLA_16___024root___ctor_var_reset(this);
}

void VCLA_16___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

VCLA_16___024root::~VCLA_16___024root() {
}
