

`ifndef MONITOR__SV
`define MONITOR__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "uni_cell.sv"
`include "wrapper_cell.sv"

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

	virtual Utopia utopia_if;

	enum bit [0:2] { reset, soc, vpi_vci, vci, vci_clp_pt, hec, payload, ack } _utopiaStatus;
	local bit [0:5] _payloadIndex;

	uvm_analysis_port #(wrapper_cell) uni_collected_port;
	UNI_cell uni_trans_collected;
	uvm_analysis_port #(wrapper_cell) nni_collected_port;
	NNI_cell nni_trans_collected;
	
	uvm_active_passive_enum is_active;
	int portn;

	extern function new(string name="monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task run_active(uvm_phase phase);
	extern task run_passive(uvm_phase phase);
endclass : monitor
 
// ----------------------- IMPLEMENTATION --------------------------------


function monitor::new(string name="monitor", uvm_component parent);
	super.new(name, parent);
	is_active=UVM_ACTIVE;
endfunction : new

function void monitor::build_phase(uvm_phase phase);
	bit active_type;
	super.build_phase(phase);

	if (!uvm_config_db #(virtual Utopia)::get (this,"", "utopia_if", utopia_if) )
	begin
		uvm_config_db #(int)::dump(); 
		`uvm_fatal("monitor", "No top_receive_if");
	end


	
	if (!uvm_config_db #(bit)::get (this,"", "is_active", active_type) )
	begin
		uvm_config_db #(int)::dump(); 
		`uvm_fatal("monitor", "No active/passive configuration");
	end

	if (active_type)
	begin
		is_active = UVM_ACTIVE;
		uni_collected_port = new("monitor_port", this); 
	end
	else
	begin
		is_active = UVM_PASSIVE;
		nni_collected_port = new("monitor_port", this); 
	end
	if (!uvm_config_db #(int)::get (this,"", "portn", portn) )
	begin
		uvm_config_db #(int)::dump(); 
		`uvm_fatal("monitor", "No portn configuration");
	end
endfunction : build_phase

function void monitor::connect_phase(uvm_phase phase);
	if (is_active == UVM_ACTIVE)
	begin
		uvm_analysis_port # (wrapper_cell) in_mon_ap; 
		uvm_config_db #(uvm_analysis_port #(wrapper_cell) )::get(null, "uvm_test_top.env._scoreboard", "in_mon_ap", in_mon_ap);
		uni_collected_port.connect(in_mon_ap);
	end
	else //UVM_PASSIVE
	begin
		uvm_analysis_port # (wrapper_cell) out_mon_ap; 
		uvm_config_db #(uvm_analysis_port #(wrapper_cell) )::get(null, "uvm_test_top.env._scoreboard", "out_mon_ap", out_mon_ap);
		nni_collected_port.connect(out_mon_ap);
	end
endfunction : connect_phase

// run phase
task monitor::run_phase(uvm_phase phase);
	// popular trans_colleted com os valores da interface

	// INPUT: ready, reset, soc, clav, clk_in, data
	//OUTPUT: valid, en, ATMCell, clk_out

	if (is_active==UVM_ACTIVE)
	begin
		this.run_active(phase);		
	end
	if (is_active==UVM_PASSIVE)
	begin
		this.run_passive(phase);		
	end
endtask : run_phase

task monitor::run_active(uvm_phase phase);

	forever
		begin :forever_loop
			@(posedge utopia_if.clk_in, posedge utopia_if.reset)
			if (utopia_if.reset) 
			begin
				_utopiaStatus <= reset;
			end
			else
			begin : not_reset
				unique case (_utopiaStatus)
				reset:
					begin: reset_state
						if (utopia_if.ready)
							_utopiaStatus <= soc;
					end : reset_state
				soc: 
					begin : soc_state
						if (utopia_if.soc && utopia_if.clav) 
						begin
							uni_trans_collected = UNI_cell::type_id::create("uni_cell_collected");
							{uni_trans_collected.GFC, uni_trans_collected.VPI[7:4]} <=utopia_if.data;
							_utopiaStatus <= vpi_vci;
						end
					end : soc_state
				vpi_vci:
					begin : vpi_vci_state
						if (utopia_if.clav) 
						begin
							{uni_trans_collected.VPI[3:0], uni_trans_collected.VCI[15:12]} <=utopia_if.data;
							_utopiaStatus <= vci;
						end 
					end : vpi_vci_state
				vci:
					begin : vci_state
						if (utopia_if.clav)
						begin
							uni_trans_collected.VCI[11:4] <=utopia_if.data;		
							_utopiaStatus <= vci_clp_pt;
						end
					end : vci_state

				vci_clp_pt:
					begin : vci_clp_state
						if (utopia_if.clav)
						begin
							{uni_trans_collected.VCI[3:0], uni_trans_collected.CLP, uni_trans_collected.PT} <= utopia_if.data;
							_utopiaStatus <= hec;
						end
					end : vci_clp_state
				hec:
					begin : hec_state
						if (utopia_if.clav)
						begin
							uni_trans_collected.HEC <= utopia_if.data;
							_utopiaStatus <= payload;
							_payloadIndex = 0; 
						end
					end : hec_state
				payload:
					begin: payload_state
						if (utopia_if.clav) 
						begin
							uni_trans_collected.Payload[_payloadIndex] <= utopia_if.data;
							if (_payloadIndex==47) begin
								_utopiaStatus <= ack;
							end	
							_payloadIndex++;
						end
					end: payload_state
				ack:
					begin : ack_state
						if (!utopia_if.ready)
						begin
							wrapper_cell collected_cell = new ();
							collected_cell._uni_cell = uni_trans_collected;
							collected_cell._io_type = wrapper_cell::INPUT_MONITOR;
							collected_cell._portRx = portn;
							uni_collected_port.write(collected_cell);
							_utopiaStatus <= reset;					
						end
					end: ack_state
				default: _utopiaStatus <= reset;
				endcase
			end :not_reset
			//
	
		end: forever_loop
endtask : run_active


task monitor::run_passive(uvm_phase phase);

	forever
		begin :forever_loop_passive
			ATMCellType Pkt;
			@(posedge utopia_if.clk_in, posedge utopia_if.reset)


			utopia_if.cbt.clav <= 1;
			while (utopia_if.cbt.soc !== 1'b1 && utopia_if.cbt.en !== 1'b0)
				@(utopia_if.cbt);
			for (int i=0; i<=52; i++) begin
				// If not enabled, loop

				while (utopia_if.cbt.en !== 1'b0)
				begin
					if (utopia_if.reset===1'b1) break;
					@(utopia_if.cbt);
				end
				if (utopia_if.reset===1'b1) break;

				Pkt.Mem[i] = utopia_if.cbt.data;
				@(utopia_if.cbt);
			end
			if (utopia_if.reset===1'b1) continue;
			else
			begin
				wrapper_cell collected_cell = new();
				utopia_if.cbt.clav <= 0;

				nni_trans_collected = new();
				nni_trans_collected.unpack(Pkt);
			
				collected_cell._nni_cell = nni_trans_collected;
				collected_cell._io_type = wrapper_cell::OUTPUT_MONITOR;
				collected_cell._portTx = portn;
				nni_collected_port.write(collected_cell);
				nni_trans_collected.display($sformatf(" monitor %d nni_cell: ",portn));
			end
		end: forever_loop_passive

endtask : run_passive

`endif // MONITOR__SV
