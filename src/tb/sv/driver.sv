/**********************************************************************
 * Definition of an ATM driver
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

`ifndef DRIVER__SV
`define DRIVER__SV

`include "atm_cell.sv"

typedef virtual Utopia.TB_Rx vUtopiaRx;

typedef class Driver;
/////////////////////////////////////////////////////////////////////////////
// Driver callback class
// Simple callbacks that are called before and after a cell is transmitted
// This class has empty tasks, which are used by default
// A testcase can extend this class to inject new behavior in the driver
// without having to change any code in the driver
class Driver_cbs;
   virtual task pre_tx(input Driver drv,
		       input UNI_cell c,
		       inout bit drop);
   endtask : pre_tx

   virtual task post_tx(input Driver drv,
		       input UNI_cell c);
   endtask : post_tx
endclass : Driver_cbs


/////////////////////////////////////////////////////////////////////////////
class Driver;

   mailbox gen2drv;	// For cells sent from generator
   event   drv2gen;	// Tell generator when I am done with cell
   vUtopiaRx Rx;	// Virtual interface for transmitting cells
   Driver_cbs cbsq[$];  // Queue of callback objects
   int PortID;
   
   extern function new(input mailbox gen2drv, input event drv2gen, 
		       input vUtopiaRx Rx, input int PortID);
   extern task run();
   extern task send (input UNI_cell c);

endclass : Driver


//---------------------------------------------------------------------------
// new(): Construct a driver object
//---------------------------------------------------------------------------
function Driver::new(input mailbox gen2drv,
		     input event drv2gen,
		     input vUtopiaRx Rx,
		     input int PortID);
   this.gen2drv = gen2drv;
   this.drv2gen = drv2gen;
   this.Rx      = Rx;
   this.PortID  = PortID;
endfunction : new 


//---------------------------------------------------------------------------
// run(): Run the driver. 
// Get transaction from generator, send into DUT
//---------------------------------------------------------------------------
task Driver::run();
   UNI_cell c;
   bit drop = 0;

   // Initialize ports
   Rx.cbr.data  <= 0;
   Rx.cbr.soc   <= 0;
   Rx.cbr.clav  <= 0;

   forever begin
      // Read the cell at the front of the mailbox
      gen2drv.peek(c);
      begin: Tx
	 // Pre-transmit callbacks
	 foreach (cbsq[i]) begin
	    cbsq[i].pre_tx(this, c, drop);
	    if (drop) disable Tx; 	// Don't transmit this cell
	 end

	 c.display($sformatf("@%0t: Drv%0d: ", $time, PortID));
	 send(c);
	 
	 // Post-transmit callbacks
	 foreach (cbsq[i])
	   cbsq[i].post_tx(this, c);
      end

      gen2drv.get(c);     // Remove cell from the mailbox
      ->drv2gen;	  // Tell the generator we are done with this cell
   end
endtask : run


//---------------------------------------------------------------------------
// send(): Send a cell into the DUT
//---------------------------------------------------------------------------
task Driver::send(input UNI_cell c);
   ATMCellType Pkt;

   c.pack(Pkt);
   $write("Sending cell: "); foreach (Pkt.Mem[i]) $write("%x ", Pkt.Mem[i]); $display;

   // Iterate through bytes of cell, deasserting Start Of Cell indicater
   @(Rx.cbr);
   Rx.cbr.clav <= 1;
   for (int i=0; i<=52; i++) begin
      // If not enabled, loop
      while (Rx.cbr.en === 1'b1) @(Rx.cbr);

      // Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
      Rx.cbr.soc  <= (i == 0);
      Rx.cbr.data <= Pkt.Mem[i];
      @(Rx.cbr);
    end
   Rx.cbr.soc <= 'z;
   Rx.cbr.data <= 8'bx;
   Rx.cbr.clav <= 0;
endtask

`endif // DRIVER__SV
