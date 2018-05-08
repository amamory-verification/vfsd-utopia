/**********************************************************************
 * Definition of an ATM configuration
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


`ifndef CONFIG__SV
`define CONFIG__SV


/////////////////////////////////////////////////////////////////////////////
// Configuration descriptor for ATM testbench
/////////////////////////////////////////////////////////////////////////////
class Config;
   int nErrors, nWarnings;		// Number of errors, warnings during simulation
   
   bit [31:0] numRx, numTx;		// Copy of parameters

   constraint c_numRxTx_valid
     {numRx inside {[1:16]};
      numTx inside {[1:16]};}

   rand bit [31:0] nCells;	// Total number of cells to transmit / receive
   constraint c_nCells_valid
     {nCells > 0; }
   constraint c_nCells_reasonable
     {nCells < 1000; }

   rand bit in_use_Rx[];	// Input / output channel enabled
   constraint c_in_use_valid
     {in_use_Rx.sum > 0; }	// Make sure at least one RX is enabled

   rand bit [31:0] cells_per_chan[];
   constraint c_sum_ncells_sum		// Split cells over all channels
     {cells_per_chan.sum == nCells;	// Total number of cells
      }

   // Set the cell count to zero for any channel not in use
   constraint c_zero_unused_channels
     {foreach (cells_per_chan[i])
       {
	solve in_use_Rx[i] before cells_per_chan[i];  // Needed for even dist of in_use
	if (in_use_Rx[i]) 
	     cells_per_chan[i] inside {[1:nCells]};
	else cells_per_chan[i] == 0;
	}
      }

   extern function new(input bit [31:0] numRx, numTx);
   extern virtual function void display(input string prefix="");

endclass : Config


//---------------------------------------------------------------------------
   function Config::new(input bit [31:0] numRx, numTx);
   if (!(numRx inside {[1:16]})) begin
      $display("FATAL %m numRx %0d out of bounds 1..16", numRx);
      $finish;
   end
   this.numRx = numRx;
   in_use_Rx = new[numRx];

   if (!(numTx inside{[1:16]})) begin
      $display("FATAL %m numTx %0d out of bounds 1..16", numTx);
      $finish;
   end
   this.numTx = numTx;

   cells_per_chan = new[numRx];
endfunction : new


//---------------------------------------------------------------------------
function void Config::display(input string prefix);
    $write("%sConfig: numRx=%0d, numTx=%0d, nCells=%0d (", prefix, numRx, numTx, nCells);
   foreach (cells_per_chan[i])
      $write("%0d ", cells_per_chan[i]);
   $write("), enabled RX: ", prefix);
   foreach (in_use_Rx[i]) if (in_use_Rx[i]) $write("%0d ", i);
   $display;
 endfunction : display

`endif // CONFIG__SV
