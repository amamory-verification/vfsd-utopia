

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "squat.sv"


//import dut_pkg::*;

`timescale 1ns/1ns

`define TxPorts 4  // set number of transmit ports
`define RxPorts 4  // set number of receive ports


module top;

	parameter int NumRx = `RxPorts;
	parameter int NumTx = `TxPorts;

	logic rst, clk;

	// System Clock and Reset
	initial begin
		rst = 0; clk = 0;
		#5ns rst = 1;
		#5ns clk = 1;
		#5ns rst = 0; clk = 0;
		forever 
      			#5ns clk = ~clk;
	end

	Utopia Rx[0:NumRx-1] ();	// NumRx x Level 1 Utopia Rx Interface
	Utopia Tx[0:NumTx-1] ();	// NumTx x Level 1 Utopia Tx Interface
	cpu_ifc mif();	  // Intel-style Utopia parallel management interface
	squat #(NumRx, NumTx) squat(Rx, Tx, mif, rst, clk);	// DUT


	initial 
		uvm_config_db#(virtual cpu_ifc)::set(null, "*", "mif", mif);

	// pass the interfaces to the agents and they will pass it to their monitors and drivers
	for(genvar i=0; i< NumRx; i++) 
	begin 
		initial 
			uvm_config_db#(virtual Utopia)::set(null, $sformatf("uvm_test_top.env.agent_active_%0d",i), "utopia_if", Rx[i]);
	end
	for(genvar i=0; i< NumTx; i++) 
	begin	
		initial 
			uvm_config_db#(virtual Utopia)::set(null, $sformatf("uvm_test_top.env.agent_passive_%0d",i), "utopia_if", Tx[i]);
	end	


	initial
	begin
		$dumpfile("dump.vcd"); $dumpvars;
	end 

	initial begin
		run_test();
		$write("test finished!");
 	end

endmodule : top


