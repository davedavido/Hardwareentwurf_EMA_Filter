module alu(
	clk,
	rst,
	op1_i,
	op2_i,
	mode_i,
	valid_i,
	
	res_o,
	valid_o
);

parameter Win 		= 16;
parameter Wout 		= 32;

input 					clk;
input 					rst;
input signed [Win-1:0] 	op1_i;
input signed [Win:0]	op2_i; // Für alpha 
input 					valid_i;
input [1:0] 			mode_i;


output reg signed  [Wout-1:0] res_o; //1 Bit mehr wegen alpha
output reg valid_o;

//ALU Modes
localparam ALU_IDLE = 2'd0;
localparam ADD 		= 2'd1;
localparam MULT		= 2'd2;

reg signed [Win-1:0] 	op1_r;
reg signed [Win:0] 		op2_r;
reg 					valid_r;
reg [2:0] 				mode_r;

/// MULT STAGE 
wire signed [Wout-1:0] 	mult_res;
assign mult_res = op1_r * op2_r;

// ADD STAGE
wire signed [Wout-1:0] 	add_res;
assign add_res 	= op1_r + op2_r;


/// sequential part starts here
always @(posedge clk) begin
	if (rst) begin
		op1_r 	<= 'd0;
		op2_r 	<= 'd0;
		mode_r 	<= ALU_IDLE;
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
	if(mode_r == ADD) begin
		res_o 		= add_res;
	end
	else if(mode_r == MULT) begin
		res_o 		= mult_res;
	end
	else if (mode_r == ALU_IDLE) begin
		res_o 		= 'd0;
	end
end
endmodule
