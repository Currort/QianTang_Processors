// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VCLA_16.h"
#include "VCLA_16__Syms.h"

//============================================================
// Constructors

VCLA_16::VCLA_16(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VCLA_16__Syms(contextp(), _vcname__, this)}
    , Ci{vlSymsp->TOP.Ci}
    , Co{vlSymsp->TOP.Co}
    , A{vlSymsp->TOP.A}
    , B{vlSymsp->TOP.B}
    , S{vlSymsp->TOP.S}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

VCLA_16::VCLA_16(const char* _vcname__)
    : VCLA_16(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VCLA_16::~VCLA_16() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VCLA_16___024root___eval_debug_assertions(VCLA_16___024root* vlSelf);
#endif  // VL_DEBUG
void VCLA_16___024root___eval_static(VCLA_16___024root* vlSelf);
void VCLA_16___024root___eval_initial(VCLA_16___024root* vlSelf);
void VCLA_16___024root___eval_settle(VCLA_16___024root* vlSelf);
void VCLA_16___024root___eval(VCLA_16___024root* vlSelf);

void VCLA_16::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VCLA_16::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VCLA_16___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VCLA_16___024root___eval_static(&(vlSymsp->TOP));
        VCLA_16___024root___eval_initial(&(vlSymsp->TOP));
        VCLA_16___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VCLA_16___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VCLA_16::eventsPending() { return false; }

uint64_t VCLA_16::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VCLA_16::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VCLA_16___024root___eval_final(VCLA_16___024root* vlSelf);

VL_ATTR_COLD void VCLA_16::final() {
    VCLA_16___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VCLA_16::hierName() const { return vlSymsp->name(); }
const char* VCLA_16::modelName() const { return "VCLA_16"; }
unsigned VCLA_16::threads() const { return 1; }
void VCLA_16::prepareClone() const { contextp()->prepareClone(); }
void VCLA_16::atClone() const {
    contextp()->threadPoolpOnClone();
}
