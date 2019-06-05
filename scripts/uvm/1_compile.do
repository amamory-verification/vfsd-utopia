vlib work
vmap work work

vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/utopia.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/dut/utopia1_atm_rx.sv 
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/dut/utopia1_atm_tx.sv  
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/LookupTable.sv 
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/dut/squat.sv 
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/definitions.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/nni_cell.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/uni_cell.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/repeat_sequence.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/parallel_sequence.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/driver.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/monitor.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/agent.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/scoreboard.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/coverage.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/environment.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/teste_parallel.sv
vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/tb/uvm/teste.sv

vlog -work work -novopt -sv +incdir+./src/tb/uvm +incdir+./src/dut +incdir+./src/tb/uvm  ./src/dut/top.sv 

#vsim work.top -coverage +UVM_PHASE_TRACE +UVM_OBJECTION_TRACE +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=teste 

#add wave -position insertpoint {sim:/top/Rx[0]/*}
#add wave -position insertpoint {sim:/top/Tx[0]/*}
#add wave -position insertpoint {sim:/top/Tx[1]/*}
#add wave -position insertpoint {sim:/top/Tx[2]/*}
#add wave -position insertpoint {sim:/top/Tx[3]/*}
#add wave -position insertpoint sim:/top/mif/*

vsim work.top -coverage +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=teste 
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run 10ms
coverage attribute -name TESTNAME -value teste
coverage save teste.ucdb
vcover report teste.ucdb -cvg -details

vsim work.top -coverage +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=teste_parallel
set NoQuitOnFinish 1
onbreak {resume}
run 10ms
coverage attribute -name TESTNAME -value teste_parallel
coverage save teste_parallel.ucdb

vcover merge  -out utopia.ucdb teste.ucdb teste_parallel.ucdb
vcover report utopia.ucdb -cvg -details