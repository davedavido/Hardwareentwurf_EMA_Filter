`include "projectGlobalParam.v"

module alu_fixed_point(
	clk,
	rst,
	op1_i,
	op2_i,
	mode_i,
	valid_i,
	
	res_o,
	valid_o
);

parameter W_in 		= 8;
parameter W_out 	= 16;

input 					clk;
input 					rst;
input signed [W_in-1:0] 	op1_i, op2_i;
input 					valid_i;
input [2:0] 			mode_i;


output reg signed  [W_out-1:0] res_o;
output reg valid_o;

localparam ADD 			= 	3'd0;
localparam SUB 			= 	3'd1;
localparam MULT 		= 	3'd2;
localparam DIV 			= 	3'd3;
localparam SHIFTUP 		= 	3'd4;
localparam SHIFTDOWN 	= 	3'd5;

reg signed [W_in-1:0] 	op1_r, op2_r;
reg 					valid_r;
reg [2:0] 				mode_r;

/// MULT STAGE 
wire signed [W_out-1:0] 	mult_res;
assign mult_res = op1_r * op2_r;

// ADD & SUB STAGE
wire signed [W_out-1:0] 	add_res;
assign add_res 	= (mode_r == ADD) ? op1_r + op2_r : op1_r - op2_r;

// Shift Stage
wire signed [W_out-1:0] shift_res;
assign shift_res = (mode_r == SHIFTUP) ? op1_r <<< op2_r : op1_r >>> op2_r;

/// sequential part starts here
always @(posedge clk) begin
	if (rst == `RST_VAL) begin
		op1_r 	<= 'd0;
		op2_r 	<= 'd0;
		mode_r 	<= ADD;
		valid_r <= 'd0;
	end
	else begin
		op1_r 	<= op1_i;
		op2_r 	<= op2_i;
		mode_r 	<= mode_i;
		valid_r <= valid_i;
	end
end

/// combinational part starts here for writing L-values to buffer
always @(*) begin
	res_o 		= 'd0;
	valid_o 	= valid_r;
	if(mode_r == ADD || mode_r == SUB) begin
		res_o 		= add_res;
	end
	else if(mode_r == MULT) begin
		res_o 		= mult_res;
	end
	else if(mode_r == SHIFTUP || mode_r == SHIFTDOWN) begin
		res_o 		= shift_res;
	end
end
endmodule
