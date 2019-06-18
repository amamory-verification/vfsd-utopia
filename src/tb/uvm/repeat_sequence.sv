
`ifndef REP_SEQUENCE__SV
`define REP_SEQUENCE__SV


import uvm_pkg::*;

`include "uni_cell.sv"

class repeat_sequence extends uvm_sequence #(UNI_cell);
`uvm_object_utils(repeat_sequence);

	sequencer _sequencer[`RxPorts];

	function new(string name="");
		super.new(name);
	endfunction

	task body;
		int i = 0;

		repeat(1000)
		begin
			UNI_cell c;
			c = UNI_cell::type_id::create("c");
			start_item(c);
			assert(c.randomize());
			finish_item(c);
			i++;
		end
		`uvm_info("repeat_sequence","----------> REPEAT_SEQUENCE FINISHED SUCESSFULLY!", UVM_LOW);
	
	endtask: body

	virtual task pre_body();
		if (starting_phase != null) begin
			`uvm_info(get_type_name(), $sformatf("%s pre_body() raising %s objection",get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.raise_objection(this);
		end
	endtask: pre_body

	// Drop the objection in the post_body so the objection is removed when the root sequence is complete.
	virtual task post_body();
		if (starting_phase != null) begin
			`uvm_info(get_type_name(), $sformatf("%s post_body() dropping %s objection", get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.drop_objection(this);
		end
	endtask: post_body

endclass : repeat_sequence

`endif //  REP_SEQUENCE__SV
