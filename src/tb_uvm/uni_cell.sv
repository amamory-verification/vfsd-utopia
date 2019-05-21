`ifndef UNI_CELL__SV
`define UNI_CELL__SV


import uvm_pkg::*;
`include "uvm_macros.svh"

`include "definitions.sv"
`include "nni_cell.sv"

class UNI_cell extends uvm_sequence_item;


	// Physical fields
	rand bit        [3:0]  GFC;
	rand bit        [7:0]  VPI;
	rand bit        [15:0] VCI;
	rand bit               CLP;
	rand bit        [2:0]  PT;
        bit        	[7:0]  HEC;
	rand bit [0:47] [7:0]  Payload;


	// Meta-data fields
	static bit [7:0] syndrome[0:255];
	static bit syndrome_not_generated = 1;
	// TODO:	verificar macros com flags
	  //Utility and Field macros,
	`uvm_object_utils_begin(UNI_cell)
    		`uvm_field_int(GFC,UVM_ALL_ON)
    		`uvm_field_int(VPI,UVM_ALL_ON)
    		`uvm_field_int(VCI,UVM_ALL_ON)
    		`uvm_field_int(CLP,UVM_ALL_ON)
    		`uvm_field_int(PT,UVM_ALL_ON)
    		`uvm_field_int(HEC,UVM_ALL_ON)
    		`uvm_field_int(Payload,UVM_ALL_ON) 
 	`uvm_object_utils_end

	extern function new(string name ="");
	extern function void post_randomize();
	extern function void generate_syndrome();
	extern function bit [7:0] hec (bit [31:0] hdr);
	// verificar na classe base a existencia de pack/unpack
	extern function void pack(output ATMCellType to);
	extern function NNI_cell to_NNI();
	extern function void display(input string prefix);
endclass : UNI_cell


typedef uvm_sequencer #(UNI_cell) sequencer;

// -----------------------------IMPLEMENTATION --------------------------------------------------------------

function UNI_cell::new(string name ="");
	super.new(name);
	if (syndrome_not_generated)
		generate_syndrome();
endfunction : new

function void UNI_cell::post_randomize();
this.HEC = hec({GFC, VPI, VCI, CLP, PT});
endfunction : post_randomize

//------------------------------------------------
// Generate the syndome array, used to compute HEC
function void UNI_cell::generate_syndrome();
   bit [7:0] sndrm;
   for (int i = 0; i < 256; i = i + 1 ) begin
      sndrm = i;
      repeat (8) begin
         if (sndrm[7] === 1'b1)
           sndrm = (sndrm << 1) ^ 8'h07;
         else
           sndrm = sndrm << 1;
      end
      syndrome[i] = sndrm;
   end
   syndrome_not_generated = 0;
endfunction : generate_syndrome

// Function to compute the HEC value
function bit [7:0] UNI_cell::hec (bit [31:0] hdr);
   hec = 8'h00;
   repeat (4) begin
      hec = syndrome[hec ^ hdr[31:24]];
      hdr = hdr << 8;
   end
   hec = hec ^ 8'h55;
endfunction : hec

function void UNI_cell::pack(output ATMCellType to);
   to.uni.GFC     = this.GFC;
   to.uni.VPI     = this.VPI;
   to.uni.VCI     = this.VCI;
   to.uni.CLP     = this.CLP;
   to.uni.PT      = this.PT;
   to.uni.HEC     = this.HEC;
   to.uni.Payload = this.Payload;
//   $write("VPI: %x ", this.VPI);
//   $write("VCI: %x ", this.VCI);$display;
   //$write("Packed: "); foreach (to.Mem[i]) $write("%x ", to.Mem[i]); $display;
endfunction : pack

function NNI_cell UNI_cell::to_NNI();
   NNI_cell copy;
   copy = new();
   copy.VPI     = this.VPI;   // NNI has wider VPI
   copy.VCI     = this.VCI;
   copy.CLP     = this.CLP;
   copy.PT      = this.PT;
   copy.HEC     = this.HEC;
   copy.Payload = this.Payload;
   return copy;
endfunction : to_NNI

function void UNI_cell::display(input string prefix);
   ATMCellType p;

   $display("%sUNI GFC=%x, VPI=%d, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x",
	    prefix, GFC, VPI, VCI, CLP, PT, HEC, Payload[0]);
   this.pack(p);
   $write("%s", prefix);
   foreach (p.Mem[i]) $write("%x ", p.Mem[i]); $display;
   //$write("%sUNI Payload=%x %x %x %x %x %x ...",
   //	  prefix, Payload[0], Payload[1], Payload[2], Payload[3], Payload[4], Payload[5]);
   //foreach(Payload[i]) $write(" %x", Payload[i]);
   $display;
endfunction : display

`endif // UNI_CELL__SV


