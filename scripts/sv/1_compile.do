vlib work
vmap work work

vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/config.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/definitions.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/atm_cell.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/utopia.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/driver.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/cpu_ifc.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/cpu_driver.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/environment.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/coverage.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/scoreboard.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/monitor.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/generator.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/LookupTable.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/dut/utopia1_atm_rx.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/dut/utopia1_atm_tx.sv  
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/dut/squat.sv 
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/tb/test.sv
vlog -work work -sv +incdir+./src/tb +incdir+./src/dut ./src/dut/top.sv 

vsim work.top
