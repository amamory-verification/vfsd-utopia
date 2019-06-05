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

`include "definitions.sv"

class Coverage;

   bit [1:0] src;
   bit [NumTx-1:0] fwd;

   covergroup CG_Forward;

      coverpoint src
	{bins src[] = {[0:3]};
	 option.weight = 0;}
      coverpoint fwd
	{bins fwd[] = {[1:15]}; // Ignore fwd==0
	 option.weight = 0;}
      cross src, fwd;

   endgroup : CG_Forward

     // Instantiate the covergroup
     function new;
	CG_Forward = new;
     endfunction : new

   // Sample input data
   function void sample(input bit [1:0] src,
			input bit [NumTx-1:0] fwd);
      $display("@%0t: Coverage: src=%d. FWD=%b", $time, src, fwd);
      this.src = src;
      this.fwd = fwd;
      CG_Forward.sample();
   endfunction : sample

endclass : Coverage

`endif // COVERAGE__SV
