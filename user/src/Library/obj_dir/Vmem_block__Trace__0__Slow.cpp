// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmem_block__Syms.h"


VL_ATTR_COLD void Vmem_block___024root__trace_init_sub__TOP__0(Vmem_block___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+1,"clk_i", false,-1);
    tracep->declBus(c+2,"write_bits_i", false,-1, 3,0);
    tracep->declBus(c+3,"addr_i", false,-1, 15,0);
    tracep->declQuad(c+4,"data_i", false,-1, 63,0);
    tracep->declQuad(c+6,"data_o", false,-1, 63,0);
    tracep->pushNamePrefix("mem_block ");
    tracep->declBus(c+9,"SIZE", false,-1, 31,0);
    tracep->declBus(c+10,"ADDR_WIDTH", false,-1, 31,0);
    tracep->declBus(c+11,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+1,"clk_i", false,-1);
    tracep->declBus(c+2,"write_bits_i", false,-1, 3,0);
    tracep->declBus(c+3,"addr_i", false,-1, 15,0);
    tracep->declQuad(c+4,"data_i", false,-1, 63,0);
    tracep->declQuad(c+6,"data_o", false,-1, 63,0);
    tracep->pushNamePrefix("less_and_equal_16 ");
    tracep->declBus(c+8,"x", false,-1, 31,0);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void Vmem_block___024root__trace_init_top(Vmem_block___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_init_top\n"); );
    // Body
    Vmem_block___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vmem_block___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vmem_block___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vmem_block___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vmem_block___024root__trace_register(Vmem_block___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&Vmem_block___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&Vmem_block___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&Vmem_block___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vmem_block___024root__trace_full_sub_0(Vmem_block___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vmem_block___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_full_top_0\n"); );
    // Init
    Vmem_block___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmem_block___024root*>(voidSelf);
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vmem_block___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vmem_block___024root__trace_full_sub_0(Vmem_block___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmem_block___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->clk_i));
    bufp->fullCData(oldp+2,(vlSelf->write_bits_i),4);
    bufp->fullSData(oldp+3,(vlSelf->addr_i),16);
    bufp->fullQData(oldp+4,(vlSelf->data_i),64);
    bufp->fullQData(oldp+6,(vlSelf->data_o),64);
    bufp->fullIData(oldp+8,(vlSelf->mem_block__DOT__less_and_equal_16__DOT__x),32);
    bufp->fullIData(oldp+9,(8U),32);
    bufp->fullIData(oldp+10,(0x10U),32);
    bufp->fullIData(oldp+11,(0x40U),32);
}
