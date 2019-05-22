`ifndef NNI_CELL__SV
`define NNI_CELL__SV


import uvm_pkg::*;
`include "uvm_macros.svh"

`include "definitions.sv"

class NNI_cell extends uvm_sequence_item;
   // Physical fields
   rand bit        [11:0] VPI;
   rand bit        [15:0] VCI;
   rand bit               CLP;
   rand bit        [2:0]  PT;
        bit        [7:0]  HEC;
   rand bit [0:47] [7:0]  Payload;

   // Meta-data fields
   static bit [7:0] syndrome[0:255];
   static bit syndrome_not_generated = 1;

   extern function new(string name="");
   extern function void post_randomize();
   extern function void generate_syndrome();
   extern function bit [7:0] hec (bit [31:0] hdr);
   extern function void unpack(input ATMCellType from);
   extern function void pack(output ATMCellType to);
   extern function void display(input string prefix);
endclass : NNI_cell

function NNI_cell::new(string name ="");
	super.new(name);
	if (syndrome_not_generated)
		generate_syndrome();
endfunction : new

function void NNI_cell::post_randomize();
   HEC = hec({VPI, VCI, CLP, PT});
endfunction : post_randomize

function void NNI_cell::generate_syndrome();
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

function bit [7:0] NNI_cell::hec (bit [31:0] hdr);
   hec = 8'h00;
   repeat (4) begin
      hec = syndrome[hec ^ hdr[31:24]];
      hdr = hdr << 8;
   end
   hec = hec ^ 8'h55;
endfunction : hec

function void NNI_cell::unpack(input ATMCellType from);
   this.VPI     = from.nni.VPI;
   this.VCI     = from.nni.VCI;
   this.CLP     = from.nni.CLP;
   this.PT      = from.nni.PT;
   this.HEC     = from.nni.HEC;
   this.Payload = from.nni.Payload;
endfunction : unpack

function void NNI_cell::pack(output ATMCellType to);
   to.nni.VPI     = this.VPI;
   to.nni.VCI     = this.VCI;
   to.nni.CLP     = this.CLP;
   to.nni.PT      = this.PT;
   to.nni.HEC     = this.HEC;
   to.nni.Payload = this.Payload;
endfunction : pack

function void NNI_cell::display(input string prefix);
	ATMCellType p;
	string text;
	`uvm_info("NNI_CELL",$sformatf("%sNNI  VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x",
	    prefix, VPI, VCI, CLP, PT, HEC, Payload[0]), UVM_HIGH);

	this.pack(p);
	text = prefix;
        foreach (p.Mem[i]) text={text,$sformatf("%x ", p.Mem[i])}; 
	`uvm_info("UNI_CELL",text,UVM_HIGH);
endfunction : display

`endif // NNI_CELL__SV

