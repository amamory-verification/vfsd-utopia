vlib work
vmap work work

vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/config.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/definitions.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/atm_cell.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/utopia.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/driver.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/cpu_ifc.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/cpu_driver.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/environment.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/coverage.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/scoreboard.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/monitor.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/generator.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/LookupTable.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/dut/utopia1_atm_rx.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/dut/utopia1_atm_tx.sv  
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/dut/squat.sv 
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/tb/sv/test.sv
vlog -work work -sv +incdir+./src/tb/sv +incdir+./src/dut ./src/dut/top_sv.sv 

vsim work.top
