

`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV


import uvm_pkg::*;
`include "uvm_macros.svh"


`include "uni_cell.sv"
`include "nni_cell.sv"
`include "wrapper_cell.sv"

class Expect_cells;
   NNI_cell q[$];
   int iexpect, iactual;
endclass : Expect_cells

class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)
	uvm_analysis_imp#(wrapper_cell, scoreboard) item_collected_export;

	uvm_analysis_port # (wrapper_cell) in_mon_ap; // from input  monitor to sb
	uvm_analysis_port # (wrapper_cell) out_mon_ap; // from output monitor to sb

	uvm_analysis_port #(wrapper_cell) cov_ap;  // used to send checker packets from the sb to the coverage

	uvm_tlm_analysis_fifo #(wrapper_cell) input_fifo;
	uvm_tlm_analysis_fifo #(wrapper_cell) output_fifo;


	Expect_cells expect_cells[];
	// iexpect increases as UNI packages is generated
	// iactual increases as NNI packages is captured and was registered into expect_cells.q[]
	// iactual increases as NNI packages is captured and was NOT registered into expect_cells.q[]
	int iexpect, iactual, nErrors;
 	NNI_cell error_cells[$];
 
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task get_input_data(uvm_tlm_analysis_fifo #(wrapper_cell) fifo, uvm_phase phase);
	extern task get_output_data(uvm_tlm_analysis_fifo #(wrapper_cell) fifo, uvm_phase phase);
	extern virtual function void write(wrapper_cell pkt);
	extern function void extract_phase( uvm_phase phase );
	extern function void display(string prefix);

// criar metodo de comparacao UNI_cell (entre o passivo e ativo)
endclass : scoreboard


// ----------------------------------- IMPLEMENTATION --------------------------------

  // new - constructor
function scoreboard::new (string name, uvm_component parent);
	super.new(name, parent);
endfunction : new

function void scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	in_mon_ap = new( "in_mon_ap", this);
//	out_mon_ap = new( "out_mon_ap", this); 
	cov_ap = new( "cov_ap", this); 
	input_fifo  = new( "input_fifo", this); 
	nErrors=0;
	out_mon_ap = new( "out_mon_ap", this); 
	output_fifo = new( "output_fifo", this);
	uvm_config_db #(uvm_analysis_port #(wrapper_cell) )::set(this, "", "out_mon_ap", out_mon_ap);
	uvm_config_db #(uvm_analysis_port #(wrapper_cell) )::set(this, "", "in_mon_ap", in_mon_ap);
	expect_cells = new[`TxPorts];
	foreach (expect_cells[i])
		expect_cells[i] = new();
endfunction : build_phase

function void scoreboard::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	in_mon_ap.connect(input_fifo.analysis_export);
	out_mon_ap.connect(output_fifo.analysis_export);
endfunction: connect_phase

// main task
task scoreboard::run_phase(uvm_phase phase);
  	fork
		get_input_data(input_fifo, phase);
		get_output_data(output_fifo, phase);
	join
endtask: run_phase

// task for input packets
task scoreboard::get_input_data(uvm_tlm_analysis_fifo #(wrapper_cell) fifo, uvm_phase phase);

	wrapper_cell tx;
	ATMCellType Pkt;
	CellCfgType CellCfg;
	forever begin
		int portn;
		NNI_cell ncell;
		phase.raise_objection(this);
		fifo.get(tx);

		tx._uni_cell.pack(Pkt);

		ncell = tx._uni_cell.to_NNI();
		CellCfg = top.squat.lut.read(tx._uni_cell.VPI);
		tx._uni_cell.display($sformatf("scoreboard received packet(FWD: %b)VPI %d: ",CellCfg.FWD, tx._uni_cell.VPI));

		for (int i=0; i<`RxPorts; i++)
			if (CellCfg.FWD[i]) begin
				// guardando informacao para verificar se saiu no TX
				expect_cells[i].q.push_back(ncell); // Save cell in this forward queue
				expect_cells[i].iexpect++;
				iexpect++;
     			end
		cov_ap.write(tx);
		phase.drop_objection(this);
	end
endtask: get_input_data

task scoreboard::get_output_data(uvm_tlm_analysis_fifo #(wrapper_cell) fifo, uvm_phase phase);
	wrapper_cell tx;
	int i;
	int match_idx;
	bit found;
	int portn;
	forever begin
		bit found = 0;
		phase.raise_objection(this);
		fifo.get(tx);
		portn = tx._portTx;


		if (expect_cells[portn].q.size() == 0) begin
			`uvm_info("scoreboard",$sformatf("@%0t: ************ ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn), UVM_LOW);

			nErrors++;
			continue;
		end
		expect_cells[portn].iactual++;
		iactual++;
		foreach (expect_cells[portn].q[i]) begin
			if (expect_cells[portn].q[i].compare(tx._nni_cell)) begin

				tx._nni_cell.display($sformatf("scoreboard pt %d collected nni_cell: ",portn));
				expect_cells[portn].q.delete(i);
				expect_cells[portn].iexpect--;

				found=1;
			end
		end
		cov_ap.write(tx);

		if (found)
			phase.drop_objection(this);
			continue;
		`uvm_info("scoreboard", $sformatf("@%0t: ERROR: %m cell not found. portn: %d", $time, portn), UVM_HIGH);
		tx._nni_cell.display("scoreboard: ");

		nErrors++;
		error_cells.push_back(tx._nni_cell);
		phase.drop_objection(this);
	end
	// write
endtask : get_output_data

function void scoreboard::write(wrapper_cell pkt);
	pkt.print();
endfunction : write

function void scoreboard::extract_phase( uvm_phase phase );
super.extract_phase(phase);
   `uvm_info("scoreboard extract_phase","----------------------------------------------------------------------------------------",UVM_LOW);
   `uvm_info("scoreboard extract_phase","---------------------------------------------------------------- EXTRACT FROM SCOREBOARD",UVM_LOW);
   `uvm_info("scoreboard extract_phase",$sformatf("@%0t: %m %0d expected cells, %0d actual cells received", $time, iexpect, iactual),UVM_LOW);

   // Look for leftover cells
   foreach (expect_cells[i]) begin
      if (expect_cells[i].q.size()) begin
	 `uvm_info("scoreboard extract_phase",$sformatf("@%0t: %m cells remaining in Tx[%0d] scoreboard at end of test", $time, i),UVM_HIGH);
	 this.display("Unclaimed: ");
	 nErrors++;
      end
   end
   `uvm_info("scoreboard extract_phase","----------------------------------------------------------------------------------------",UVM_LOW);
endfunction : extract_phase

function void scoreboard::display(string prefix);
	`uvm_info("scoreboard",$sformatf("@%0t: %m so far %0d expected cells, %0d actual cells received", $time, iexpect, iactual),UVM_HIGH);

	foreach (expect_cells[i]) begin
		`uvm_info("scoreboard",$sformatf("Tx[%0d]: exp=%0d, act=%0d", i, expect_cells[i].iexpect, expect_cells[i].iactual),UVM_HIGH);
		foreach (expect_cells[i].q[j])
			expect_cells[i].q[j].display($sformatf("%sScoreboard: Tx%0d: ", prefix, i));
	end
	`uvm_info("scoreboard","---- ERROR CELL!",UVM_HIGH);
	foreach(error_cells[i])
		error_cells[i].display(" ERROR CELL: ");
endfunction : display


`endif // SCOREBOARD__SV
