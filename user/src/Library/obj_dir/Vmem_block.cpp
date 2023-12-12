// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vmem_block.h"
#include "Vmem_block__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vmem_block::Vmem_block(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vmem_block__Syms(contextp(), _vcname__, this)}
    , clk_i{vlSymsp->TOP.clk_i}
    , write_bits_i{vlSymsp->TOP.write_bits_i}
    , addr_i{vlSymsp->TOP.addr_i}
    , data_i{vlSymsp->TOP.data_i}
    , data_o{vlSymsp->TOP.data_o}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vmem_block::Vmem_block(const char* _vcname__)
    : Vmem_block(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vmem_block::~Vmem_block() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vmem_block___024root___eval_debug_assertions(Vmem_block___024root* vlSelf);
#endif  // VL_DEBUG
void Vmem_block___024root___eval_static(Vmem_block___024root* vlSelf);
void Vmem_block___024root___eval_initial(Vmem_block___024root* vlSelf);
void Vmem_block___024root___eval_settle(Vmem_block___024root* vlSelf);
void Vmem_block___024root___eval(Vmem_block___024root* vlSelf);

void Vmem_block::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmem_block::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vmem_block___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vmem_block___024root___eval_static(&(vlSymsp->TOP));
        Vmem_block___024root___eval_initial(&(vlSymsp->TOP));
        Vmem_block___024root___eval_settle(&(vlSymsp->TOP));
    }
    // MTask 0 start
    VL_DEBUG_IF(VL_DBG_MSGF("MTask0 starting\n"););
    Verilated::mtaskId(0);
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vmem_block___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfThreadMTask(vlSymsp->__Vm_evalMsgQp);
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vmem_block::eventsPending() { return false; }

uint64_t Vmem_block::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vmem_block::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vmem_block___024root___eval_final(Vmem_block___024root* vlSelf);

VL_ATTR_COLD void Vmem_block::final() {
    Vmem_block___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vmem_block::hierName() const { return vlSymsp->name(); }
const char* Vmem_block::modelName() const { return "Vmem_block"; }
unsigned Vmem_block::threads() const { return 1; }
std::unique_ptr<VerilatedTraceConfig> Vmem_block::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vmem_block___024root__trace_init_top(Vmem_block___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmem_block___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmem_block___024root*>(voidSelf);
    Vmem_block__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    Vmem_block___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void Vmem_block___024root__trace_register(Vmem_block___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vmem_block::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vmem_block::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vmem_block___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
