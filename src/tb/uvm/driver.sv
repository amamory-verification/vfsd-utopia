

`ifndef DRIVER__SV
`define DRIVER__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uni_cell.sv"

class driver extends uvm_driver #(UNI_cell);
`uvm_component_utils(driver);

	virtual Utopia.TB_Rx utopia_if;

	extern function new(string name="driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send(input UNI_cell c);

endclass: driver

// ---------------------------- IMPLEMENTATION  ------------------------------------------------------------

function driver::new(string name="driver", uvm_component parent);
	super.new(name, parent);
endfunction : new

function void driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db #(virtual Utopia.TB_Rx)::get (this, "", "utopia_if", utopia_if) )
	begin
		uvm_config_db #(int)::dump(); 
		`uvm_fatal("driver", "No top_receive_if");
	end
endfunction : build_phase


task driver::run_phase(uvm_phase phase);
	UNI_cell c;
	forever
	begin
		seq_item_port.get_next_item(c);
		send(c);
		seq_item_port.item_done();
	end
endtask : run_phase

//---------------------------------------------------------------------------
// send(): Send a cell into the DUT
//---------------------------------------------------------------------------
task driver::send(input UNI_cell c);
   ATMCellType Pkt;

   c.pack(Pkt);

   c.display("driver sending cell: ");

   // Iterate through bytes of cell, deasserting Start Of Cell indicater
   @(utopia_if.cbr);
   utopia_if.cbr.clav <= 1;
   for (int i=0; i<=52; i++) begin
      // If not enabled, loop
      while (utopia_if.cbr.en === 1'b1) @(utopia_if.cbr);

      // Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
      utopia_if.cbr.soc  <= (i == 0);
      utopia_if.cbr.data <= Pkt.Mem[i];
      @(utopia_if.cbr);
    end
   utopia_if.cbr.soc <= 'z;
   utopia_if.cbr.data <= 8'bx;
   utopia_if.cbr.clav <= 0;
endtask


`endif // DRIVER__SV
