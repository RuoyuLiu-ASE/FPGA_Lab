transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy {D:/quartus17/project/ex2_copy/updown_counter.v}
vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy {D:/quartus17/project/ex2_copy/clkEnable.v}

