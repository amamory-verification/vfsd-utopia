

`include "config.sv" 
`include "cpu_ifc.sv" 
`include "cpu_driver.sv" 

package dut_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   
`include "definitions.sv"
`include "uni_cell.sv"
`include "repeat_sequence.sv"


`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"

`include "teste.sv"

   
endpackage : dut_pkg
