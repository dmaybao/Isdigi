transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/danmayoral/Documents/Isdigi/Práctica\ 1/ref/P1v23 {C:/Users/danmayoral/Documents/Isdigi/Práctica 1/ref/P1v23/shifter_2d_var.sv}
vlog -sv -work work +incdir+C:/Users/danmayoral/Documents/Isdigi/Práctica\ 1/ref/P1v23 {C:/Users/danmayoral/Documents/Isdigi/Práctica 1/ref/P1v23/counter.sv}
vlog -sv -work work +incdir+C:/Users/danmayoral/Documents/Isdigi/Práctica\ 1/ref/P1v23 {C:/Users/danmayoral/Documents/Isdigi/Práctica 1/ref/P1v23/FIFO.sv}

vlog -sv -work work +incdir+C:/Users/danmayoral/Documents/Isdigi/Práctica\ 1/ref/P1v23 {C:/Users/danmayoral/Documents/Isdigi/Práctica 1/ref/P1v23/tb_FIFO.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_FIFO

add wave *
view structure
view signals
run -all
