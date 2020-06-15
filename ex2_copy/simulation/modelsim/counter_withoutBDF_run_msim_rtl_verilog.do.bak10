transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy {D:/quartus17/project/ex2_copy/updown_counter.v}
vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy {D:/quartus17/project/ex2_copy/top.v}
vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy {D:/quartus17/project/ex2_copy/clkEnable.v}

vlog -vlog01compat -work work +incdir+D:/quartus17/project/ex2_copy/simulation/modelsim {D:/quartus17/project/ex2_copy/simulation/modelsim/top.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  top_vlg_tst

add wave *
view structure
view signals
run -all
