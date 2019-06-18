


`ifndef ENVIRONMENT__SV
`define ENVIRONMENT__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "agent.sv"
`include "cpu_ifc.sv"
`include "cpu_driver.sv"
`include "config.sv"
`include "scoreboard.sv"
`include "coverage.sv"


class environment extends uvm_env;  
  `uvm_component_utils(environment)

	agent _agent_active[`RxPorts];
  	agent _agent_passive[`TxPorts];
	scoreboard _scoreboard;
	coverage _coverage;
   
	// new - constructor
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task configure_phase(uvm_phase phase); 
	extern function void connect_phase(uvm_phase phase);
endclass : environment

// ---------------------------------------- IMPLEMENTATION -------------------------------------


function environment::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction : new

// build_phase
function void environment::build_phase(uvm_phase phase);
	super.build_phase(phase);
	_scoreboard = scoreboard::type_id::create("_scoreboard", this);
	_coverage = coverage::type_id::create("_coverage", this);
	foreach (_agent_active[i]) begin
		uvm_config_int::set(this, $sformatf("agent_active_%0d",i), "is_active", UVM_ACTIVE);
		uvm_config_db #(int)::set (this,$sformatf("agent_active_%0d",i), "portn", i);
		_agent_active[i] = agent::type_id::create($sformatf("agent_active_%0d",i), this);
	end
	foreach (_agent_passive[i]) begin
		uvm_config_int::set(this, $sformatf("agent_passive_%0d",i), "is_active", UVM_PASSIVE);
		uvm_config_db #(int)::set (this,$sformatf("agent_passive_%0d",i), "portn", i);
		_agent_passive[i] = agent::type_id::create($sformatf("agent_passive_%0d",i), this);
	end
//	_agent = agent::type_id::create("agent", this);
endfunction : build_phase


task environment::configure_phase(uvm_phase phase);
	super.configure_phase(phase);
endtask : configure_phase

function void environment::connect_phase(uvm_phase phase);
  `uvm_info("msg", "Connecting ENV", UVM_HIGH)

  // conenct sb with coverage
  //if (cfg.enable_coverage == 1)
  _scoreboard.cov_ap.connect(_coverage.analysis_export);
  `uvm_info("msg", "Connecting ENV Done !", UVM_HIGH)
endfunction: connect_phase

`endif // environment