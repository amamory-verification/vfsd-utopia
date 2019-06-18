




import uvm_pkg::*;
`include "uvm_macros.svh"
`include "environment.sv"
`include "repeat_sequence.sv"
`include "cpu_driver.sv"
`include "config.sv"
`include "cpu_ifc.sv"

class teste extends uvm_test;
`uvm_component_utils(teste);

	virtual interface Utopia rx;

	environment _environment;
	repeat_sequence _sequence;
	CPU_driver _cpu;
	Config _cfg;
	vCPU_T _mif;

	//env my_env;
	extern function new(string name="teste", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task configure_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass : teste

// -------------------------------------- IMPLEMENTATION -----------------------------------------

function teste::new(string name="teste", uvm_component parent);
	super.new(name, parent);
endfunction: new

task teste::configure_phase(uvm_phase phase);
	super.configure_phase(phase);
	
endtask : configure_phase

function void teste::build_phase(uvm_phase phase);
super.build_phase(phase);
 
    _environment = environment::type_id::create("env", this);
    _sequence = repeat_sequence::type_id::create("_sequence");
    _cfg = new(`RxPorts,`TxPorts);
    uvm_config_db#(virtual cpu_ifc)::get(null, "*", "mif", _mif);
    _cpu = new(_mif, _cfg);
endfunction : build_phase

task teste::run_phase(uvm_phase phase);
  int indice=0;
  phase.raise_objection(this);
  _cpu.run();
  // start the virtual sequence
  foreach (_sequence._sequencer[i]) begin
    _sequence._sequencer[i] = _environment._agent_active[i]._sequencer;
  end

  foreach (_sequence._sequencer[i])
  begin
	`uvm_info("repeat_sequence",$sformatf("---------------------------------------> SEQUENCER %d",indice), UVM_LOW);
	_sequence.start(_sequence._sequencer[i]);  
	indice++;
  end
  phase.drop_objection(this);
endtask : run_phase



