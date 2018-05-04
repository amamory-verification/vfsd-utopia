vlib work
vmap work work

vlog -work work -sv +incdir+./src +incdir+./modules ./src/config.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/definitions.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/atm_cell.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/utopia.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/driver.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/cpu_ifc.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/cpu_driver.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/environment.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/coverage.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/scoreboard.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/monitor.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/generator.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/LookupTable.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/utopia1_atm_rx.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/utopia1_atm_tx.sv  
vlog -work work -sv +incdir+./src +incdir+./modules ./src/squat.sv 
vlog -work work -sv +incdir+./src +incdir+./modules ./src/test.sv
vlog -work work -sv +incdir+./src +incdir+./modules ./src/top.sv 

vsim work.top
