
`ifndef WRAPPER_CELL__SV
`define WRAPPER_CELL__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "definitions.sv"

`include "uni_cell.sv"
`include "nni_cell.sv"

class wrapper_cell extends uvm_sequence_item;
`uvm_object_utils(wrapper_cell);

	UNI_cell _uni_cell;
	NNI_cell _nni_cell;
	typedef enum bit { INPUT_MONITOR=0, OUTPUT_MONITOR=1 } monitor_io_type_enum;
	monitor_io_type_enum _io_type;
	int _portRx;
	int _portTx;

	function new(string name ="");
		super.new(name);
		this._io_type = INPUT_MONITOR;
		this._portRx=-1;
		this._portTx=-1;
	endfunction

endclass : wrapper_cell


`endif // wrapper_cell