/**********************************************************************
 * Definition of the monitor class for the ATM testbench
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


`ifndef MONITOR__SV
`define MONITOR__SV

`include "atm_cell.sv"

typedef virtual Utopia.TB_Tx vUtopiaTx;

typedef class Monitor;
/////////////////////////////////////////////////////////////////////////////
// Monitor callback class
// Simple callbacks that are called before and after a cell is transmitted
// This class has empty tasks, which are used by default
// A testcase can extend this class to inject new behavior in the monitor
// without having to change any code in the monitor
class Monitor_cbs;
   virtual task post_rx(input Monitor mon,
		        input NNI_cell c);
   endtask : post_rx
endclass : Monitor_cbs


/////////////////////////////////////////////////////////////////////////////
class Monitor;

   vUtopiaTx Tx;		// Virtual interface with output of DUT
   Monitor_cbs cbsq[$];		// Queue of callback objects
   int PortID;

   extern function new(input vUtopiaTx Tx, input int PortID);
   extern task run();
   extern task receive (output NNI_cell c);
endclass : Monitor


//---------------------------------------------------------------------------
// new(): construct an object
//---------------------------------------------------------------------------
function Monitor::new(input vUtopiaTx Tx, input int PortID);
   this.Tx     = Tx;
   this.PortID = PortID;
endfunction : new


//---------------------------------------------------------------------------
// run(): Run the monitor
//---------------------------------------------------------------------------
task Monitor::run();
   NNI_cell c;
      
   forever begin
      receive(c);
      foreach (cbsq[i])
	cbsq[i].post_rx(this, c); 	 // Post-receive callback
   end
endtask : run


//---------------------------------------------------------------------------
// receive(): Read a cell from the DUT output, pack it into a NNI cell
//---------------------------------------------------------------------------
task Monitor::receive(output NNI_cell c);
   ATMCellType Pkt;

   Tx.cbt.clav <= 1;
   while (Tx.cbt.soc !== 1'b1 && Tx.cbt.en !== 1'b0)
     @(Tx.cbt);
   for (int i=0; i<=52; i++) begin
      // If not enabled, loop
      while (Tx.cbt.en !== 1'b0) @(Tx.cbt);
      
      Pkt.Mem[i] = Tx.cbt.data;
      @(Tx.cbt);
   end

   Tx.cbt.clav <= 0;

   c = new();
   c.unpack(Pkt);
   c.display($sformatf("@%0t: Mon%0d: ", $time, PortID));
   
endtask : receive

`endif // MONITOR__SV
