

//   RAM64M    : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (RAM64M_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // RAM64M: 64-deep by 4-wide Multi Port LUT RAM (Mapped to four SliceM LUT6s)
   //         Artix-7
   // Xilinx HDL Language Template, version 2023.2

   RAM64M #(
      .INIT_A(64'h0000000000000000), // Initial contents of A Port
      .INIT_B(64'h0000000000000000), // Initial contents of B Port
      .INIT_C(64'h0000000000000000), // Initial contents of C Port
      .INIT_D(64'h0000000000000000)  // Initial contents of D Port
   ) RAM64M_inst (
      .DOA(DOA),     // Read port A 1-bit output
      .DOB(DOB),     // Read port B 1-bit output
      .DOC(DOC),     // Read port C 1-bit output
      .DOD(DOD),     // Read/write port D 1-bit output
      .DIA(DIA),     // RAM 1-bit data write input addressed by ADDRD,
                     //   read addressed by ADDRA
      .DIB(DIB),     // RAM 1-bit data write input addressed by ADDRD,
                     //   read addressed by ADDRB
      .DIC(DIC),     // RAM 1-bit data write input addressed by ADDRD,
                     //   read addressed by ADDRC
      .DID(DID),     // RAM 1-bit data write input addressed by ADDRD,
                     //   read addressed by ADDRD
      .ADDRA(ADDRA), // Read port A 6-bit address input
      .ADDRB(ADDRB), // Read port B 6-bit address input
      .ADDRC(ADDRC), // Read port C 6-bit address input
      .ADDRD(ADDRD), // Read/write port D 6-bit address input
      .WE(WE),       // Write enable input
      .WCLK(WCLK)    // Write clock input
   );

   // End of RAM64M_inst instantiation
						
					