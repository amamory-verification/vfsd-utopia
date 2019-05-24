/**********************************************************************
 * Functional coverage code
 *
 * Author: Chris Spear
 * Revision: 1.01
 * Last modified: 8/2/2011
 *
 * (c) Copyright 2008-2011, Chris Spear, Greg Tumbush. *** ALL RIGHTS RESERVED ***
 * http://chris.spear.net
 *
 *  This source file may be used and distributed without restriction
 *  provided that this copyright statement is not removed from the file
 *  and that any derivative work contains this copyright notice.
 *
 * Used with permission in the book, "SystemVerilog for Verification"
 * By Chris Spear and Greg Tumbush
 * Book copyright: 2008-2011, Springer LLC, USA, Springer.com
 *********************************************************************/

`ifndef COVERAGE__SV
`define COVERAGE__SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "definitions.sv"

`include "uni_cell.sv"
`include "nni_cell.sv"
`include "wrapper_cell.sv"



class coverage extends uvm_subscriber #(wrapper_cell);
`uvm_component_utils(coverage);

	bit [1:0] portRx;
	bit [NumTx-1:0] fwdRx;
	bit [1:0] portTx;
	bit [NumTx-1:0] fwdTx;

	covergroup CG_Backward;

		coverpoint portRx
			{bins portRx[] = {[0:3]};
				option.weight = 0;}
		coverpoint fwdRx
			{bins fwdRx[] = {[1:15]}; // Ignore fwd==0
			 option.weight = 0;}
      		cross portRx, fwdRx;
	endgroup: CG_Backward;

	covergroup CG_Forward;
		coverpoint portTx
			{bins portTx[] = {[0:3]};
				option.weight = 0;}
		coverpoint fwdTx
			{bins fwd[] = {[1:15]}; // Ignore fwd==0
			 option.weight = 0;}

      		TX_FWD_CROSS : cross portTx, fwdTx
		{
			ignore_bins erroPorta = TX_FWD_CROSS with 
								((portTx == 3 && fwdTx>=1 && fwdTx<=7) ||
								(portTx == 2 && (
								        (fwdTx>=0 && fwdTx<=3) ||
									(fwdTx>=8 && fwdTx<=11)) ) ||
								(portTx == 1 && (
								        fwdTx==1 || 
									fwdTx==4 ||
									fwdTx==5 ||
									fwdTx==8 ||
									fwdTx==9 ||
									fwdTx==12 ||
									fwdTx==13)) ||
								(portTx == 0 && 
								        fwdTx%2==0));

		}
		ERRO_CROSS : cross portTx, fwdTx
		{
//			option.goal=0; // geracoes futuras, arrume aqui... Como fazer isso??
			ignore_bins corretosPorta = ERRO_CROSS with 
								((portTx == 3 && fwdTx>=8 && fwdTx<=15) ||
								(portTx == 2 && (
								        (fwdTx>=4 && fwdTx<=7) ||
									(fwdTx>=12 && fwdTx<=15)) ) ||
								(portTx == 1 && (
								        fwdTx==2 || 
								        fwdTx==3 || 
									fwdTx==6 ||
									fwdTx==7 ||
									fwdTx==10 ||
									fwdTx==11 ||
									fwdTx==14 ||
									fwdTx==15)) ||
								(portTx == 0 && 
								        fwdTx%2==1));

		}

   	endgroup : CG_Forward

     	// Instantiate the covergroup
     	
	extern function new(string name, uvm_component parent);
	extern function void write(wrapper_cell t);

endclass : coverage

function coverage::new(string name, uvm_component parent);
		super.new(name,parent);
//		CG_Forward::ERRO_CROSS::type_option.goal=5;
//		CG_Forward::ERRO_CROSS::type_option.weight=2;
		CG_Forward = new();
		CG_Backward = new();
//		CG_Forward.ERRO_CROSS.option.goal = 20;
//		CG_Forward.ERRO_CROSS.option.weight = 10;
endfunction : new

function void coverage::write(wrapper_cell t);
	if (t._io_type == wrapper_cell::OUTPUT_MONITOR)
	begin
		CellCfgType CellCfg;
		this.portTx = t._portTx;
		CellCfg= top.squat.lut.read(t._nni_cell.VPI);
		this.fwdTx = CellCfg.FWD;
		t._nni_cell.display($sformatf("coverage portn: %d fwd: %b. ", t._portTx, this.fwdTx));
		CG_Forward.sample();
	end
	if (t._io_type == wrapper_cell::INPUT_MONITOR)
	begin
		CellCfgType CellCfg;
		this.portRx = t._portRx;

		CellCfg= top.squat.lut.read(t._uni_cell.VPI);
		this.fwdRx = CellCfg.FWD;
//		$display("fwd: %d vpi: ", CellCfg.FWD, t._uni_cell.VPI);
		t._uni_cell.display($sformatf("coverage portn: %d fwd: %b[%d]. ", t._portRx, this.fwdRx, t._uni_cell.VPI));
		CG_Backward.sample();
	end
endfunction: write 

`endif // COVERAGE__SV
