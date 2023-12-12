// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmem_block__Syms.h"


void Vmem_block___024root__trace_chg_sub_0(Vmem_block___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vmem_block___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_chg_top_0\n"); );
    // Init
    Vmem_block___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmem_block___024root*>(voidSelf);
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vmem_block___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void Vmem_block___024root__trace_chg_sub_0(Vmem_block___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelf->clk_i));
    bufp->chgCData(oldp+1,(vlSelf->write_bits_i),4);
    bufp->chgSData(oldp+2,(vlSelf->addr_i),16);
    bufp->chgQData(oldp+3,(vlSelf->data_i),64);
    bufp->chgQData(oldp+5,(vlSelf->data_o),64);
    bufp->chgIData(oldp+7,(vlSelf->mem_block__DOT__less_and_equal_16__DOT__x),32);
}

void Vmem_block___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_cleanup\n"); );
    // Init
    Vmem_block___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmem_block___024root*>(voidSelf);
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
