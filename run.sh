#!/bin/bash

if [ "$1" = "sv" ]
then

  module load modelsim
  echo "	simulating... please wait"
  {
    #run vsim

    vsim -c -do ./scripts/sv/3_simul.do

    #save log file
    mv transcript simulation.log

    #cleanup
    rm -rf *.ini transcript *.wlf work ./src/*~

  } > /dev/null
  module unload modelsim

elif [ "$1" = "uvm" ]
then

  echo "	simulating... please wait"
  
  #run sim
  vsim -c -do scripts/uvm/1_compile.do

  #save log file
  mv transcript simulation.log

  #cleanup
  rm -rf dump.vcd teste* transcript utopia.ucdb  vsim.wlf work

else

  echo "NOT AVAILABLE OPTION. Please, run \"./run.sh sv\" or \"./run.sh uvm\" "

fi

