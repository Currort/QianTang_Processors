// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VCLA_16.h for the primary calling header

#include "verilated.h"

#include "VCLA_16__Syms.h"
#include "VCLA_16__Syms.h"
#include "VCLA_16___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VCLA_16___024root___dump_triggers__stl(VCLA_16___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void VCLA_16___024root___eval_triggers__stl(VCLA_16___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VCLA_16__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCLA_16___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (0U == vlSelf->__VstlIterCount));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VCLA_16___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
