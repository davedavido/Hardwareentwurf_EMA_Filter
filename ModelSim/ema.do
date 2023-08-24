vlog -work work -stats=none C:/Users/David/Documents/GitHub/Hardwareentwurf_EMA_Filter/Verilog/alu.v
vlog -work work -stats=none C:/Users/David/Documents/GitHub/Hardwareentwurf_EMA_Filter/Verilog/ema_tb.v
vlog -work work -stats=none C:/Users/David/Documents/GitHub/Hardwareentwurf_EMA_Filter/Verilog/ema.v

vsim -gui work.ema_tb

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ema_tb/DUT/clk
add wave -noupdate /ema_tb/DUT/rst
add wave -noupdate -divider Input
add wave -noupdate /ema_tb/DUT/x_i
add wave -noupdate /ema_tb/DUT/x_r
add wave -noupdate /ema_tb/DUT/x_save_r
add wave -noupdate /ema_tb/DUT/x_save_temp
add wave -noupdate -radix unsigned /ema_tb/DUT/alpha_i
add wave -noupdate /ema_tb/DUT/alpha_r
add wave -noupdate /ema_tb/DUT/valid_i
add wave -noupdate /ema_tb/DUT/valid_r
add wave -noupdate -divider FSM
add wave -noupdate -radix unsigned /ema_tb/DUT/current_state
add wave -noupdate -radix unsigned /ema_tb/DUT/next_state
add wave -noupdate -radix unsigned /ema_tb/DUT/alu_mode
add wave -noupdate -divider ALU
add wave -noupdate /ema_tb/DUT/ALU/op1_i
add wave -noupdate /ema_tb/DUT/ALU/op2_i
add wave -noupdate /ema_tb/DUT/ALU/valid_i
add wave -noupdate /ema_tb/DUT/ALU/valid_o
add wave -noupdate /ema_tb/DUT/ALU/res_o
add wave -noupdate /ema_tb/DUT/ALU/op1_r
add wave -noupdate /ema_tb/DUT/ALU/op2_r
add wave -noupdate /ema_tb/DUT/ALU/valid_r
add wave -noupdate /ema_tb/DUT/ALU/mode_i
add wave -noupdate /ema_tb/DUT/ALU/mode_r
add wave -noupdate /ema_tb/DUT/ALU/mult_res
add wave -noupdate /ema_tb/DUT/ALU/add_res
add wave -noupdate -divider Zwischenwerte
add wave -noupdate /ema_tb/DUT/y_last_r
add wave -noupdate /ema_tb/DUT/mult_x_a_temp
add wave -noupdate /ema_tb/DUT/mult_x_a_r
add wave -noupdate /ema_tb/DUT/mult_y_a_temp
add wave -noupdate /ema_tb/DUT/mult_y_a_r
add wave -noupdate /ema_tb/DUT/y_o_temp
add wave -noupdate -divider Output
add wave -noupdate /ema_tb/DUT/y_o
add wave -noupdate /ema_tb/DUT/valid_o
add wave -noupdate /ema_tb/DUT/bussy_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 340
configure wave -valuecolwidth 212
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {54 ps}
run -all