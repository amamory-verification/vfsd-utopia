/**********************************************************************
 * Definition of the CPU driver class
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


`ifndef CPU_DRIVER__SV
 `define CPU_DRIVER__SV

`include "config.sv"
`include "cpu_ifc.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

class CPU_driver;
   vCPU_T mif;
   CellCfgType lookup [255:0]; // copy of look-up table
   Config cfg;
   bit [NumTx-1:0] fwd;
   bit clk;

   extern function new(vCPU_T mif, Config cfg);
   extern task Initialize_Host ();
   extern task HostWrite (int a, CellCfgType d); // configure
   extern task HostRead (int a, output CellCfgType d);
   extern task run();
endclass : CPU_driver


function CPU_driver::new(vCPU_T mif, Config cfg);
   this.mif = mif;
   this.cfg = cfg;
endfunction : new


task CPU_driver::Initialize_Host ();
   mif.BusMode <= 1;
   mif.Addr <= 0;
   mif.DataIn <= 0;
   mif.Sel <= 1;
   mif.Rd_DS <= 1;
   mif.Wr_RW <= 1;
endtask : Initialize_Host


task CPU_driver::HostWrite (int a, CellCfgType d); // configure
   #10 mif.Addr <= a; mif.DataIn <= d; mif.Sel <= 0;
   #10 mif.Wr_RW <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 mif.Wr_RW <= 1; mif.Sel <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostWrite


task CPU_driver::HostRead (int a, output CellCfgType d);
   #10 mif.Addr <= a; mif.Sel <= 0;
   #10 mif.Rd_DS <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 d = mif.DataOut; mif.Rd_DS <= 1; mif.Sel <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostRead


task CPU_driver::run();
   CellCfgType CellFwd;

   Initialize_Host();

   // Configure through Host interface


	`uvm_info("cpu_driver","Memory: Loading ... ",UVM_HIGH);
   for (int i=0; i<=255; i++) begin
      CellFwd.FWD = $urandom();
`ifdef FWDALL
      CellFwd.FWD = '1
`endif
	`uvm_info("cpu_driver",$sformatf("CellFwd.FWD[%0d]=%0d", i, CellFwd.FWD),UVM_HIGH);
      CellFwd.VPI = i;
      HostWrite(i, CellFwd);
      lookup[i] = CellFwd;
   end

   // Verify memory
`uvm_info("cpu_driver","Veryfing ... ",UVM_HIGH);
   for (int i=0; i<=255; i++) begin
      HostRead(i, CellFwd);
      if (lookup[i] != CellFwd) begin
         $display("FATAL, Mem Location 0x%x contains 0x%x, expected 0x%x",
                  i, CellFwd, lookup[i]);
         $finish;
      end
   end
	`uvm_info("cpu_driver","Verified",UVM_HIGH);


endtask : run


`endif // CPU_DRIVER__SV
