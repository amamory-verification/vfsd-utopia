#disable transcript
transcript on

#do compilation
do 1_compile.do

#do waves
do 2_wave.do

#simulate
run 1000 ms

#quit vsim
quit -sim
quit -f