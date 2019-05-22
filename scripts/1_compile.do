vlib work
vmap work work



vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/dut/utopia1_atm_rx.sv 
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/dut/utopia1_atm_tx.sv  
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb/LookupTable.sv 
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/dut/squat.sv 
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/definitions.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/nni_cell.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/uni_cell.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/repeat_sequence.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/driver.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/monitor.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/agent.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/scoreboard.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/coverage.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/environment.sv
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/teste.sv

#vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/config.sv 
#vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/cpu_ifc.sv 
#vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/tb_uvm/cpu_driver.sv 
#vlog -work work -novopt -sv +incdir+./src/dut +incdir+./src/tb_uvm ./src/tb_uvm/dut_pkg.sv 
vlog -work work -novopt -sv +incdir+./src/tb +incdir+./src/dut +incdir+./src/tb_uvm  ./src/dut/top.sv 

#vsim work.top -coverage +UVM_PHASE_TRACE +UVM_OBJECTION_TRACE +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=teste 
vsim work.top -coverage +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=teste 
#vsim work.top -coverage +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=teste 

add wave -position insertpoint {sim:/top/Rx[0]/*}
add wave -position insertpoint {sim:/top/Tx[0]/*}
add wave -position insertpoint {sim:/top/Tx[1]/*}
add wave -position insertpoint {sim:/top/Tx[2]/*}
add wave -position insertpoint {sim:/top/Tx[3]/*}
add wave -position insertpoint sim:/top/mif/*

set NoQuitOnFinish 1
#run 26600ns
run 10ms

#quit -sim


coverage attribute -name TESTNAME -value teste
coverage save teste.ucdb

#vcover merge  smoke_test.ucdb zeros_test.ucdb neg_test.ucdb
vcover report teste.ucdb -cvg -details

