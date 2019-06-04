


`ifndef AGENT__SV
`define AGENT__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "driver.sv"
`include "monitor.sv"
`include "uni_cell.sv"

class agent extends uvm_agent;
`uvm_component_utils(agent)

	driver    _driver;
	sequencer _sequencer;
	monitor   _monitor;

	extern function new (string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern function void end_of_elaboration();

endclass : agent

// -------------------------------- IMPLEMENTATION ---------------------------------------

// constructor
function agent::new (string name, uvm_component parent);
	super.new(name, parent);
endfunction : new

// build_phase
function void agent::build_phase(uvm_phase phase);
	virtual Utopia utopia_if;
	int portn;
	super.build_phase(phase);
	if (!uvm_config_db #(virtual Utopia)::get (this, "", "utopia_if", utopia_if) )
	begin
		uvm_config_db #(int)::dump(); 
		`uvm_fatal("agent", "No top_receive_if");
	end
	uvm_config_db #(virtual Utopia)::set (this,"monitor", "utopia_if", utopia_if);
	if(get_is_active() == UVM_ACTIVE) begin
		_driver = driver::type_id::create("driver", this);
		_sequencer = sequencer::type_id::create("sequencer", this);
		uvm_config_db #(virtual Utopia.TB_Rx)::set (this,"driver", "utopia_if", utopia_if);
		uvm_config_db #(bit)::set (this,"monitor", "is_active", 1);
	end
	else
	begin
		uvm_config_db #(bit)::set (this,"monitor", "is_active", 0);
	end
	uvm_config_db #(int)::get (this,"", "portn", portn);
	uvm_config_db #(int)::set (this,"monitor", "portn", portn);
	_monitor = monitor::type_id::create("monitor", this);

endfunction : build_phase

function void agent::connect_phase(uvm_phase phase);
	if(get_is_active() == UVM_ACTIVE) begin
		_driver.seq_item_port.connect(_sequencer.seq_item_export);
	end
endfunction : connect_phase

//---------------------------------------  
// End of elaboration phase - debbuging connection
//---------------------------------------
// http://www.learnuvmverification.com/index.php/2016/05/22/debugging-uvm-environment/
// This can be controlled by the flag +UVM_VERBOSITY = LOW/HIGH at simulation command
function void agent::end_of_elaboration();

   //DEBUG connection
   if ( get_is_active() ) begin

      _driver.seq_item_port.debug_connected_to();
      _monitor.uni_collected_port.debug_connected_to();
      
   end else begin
      
      _monitor.nni_collected_port.debug_connected_to();

   end

endfunction



`endif // AGENT__SV
