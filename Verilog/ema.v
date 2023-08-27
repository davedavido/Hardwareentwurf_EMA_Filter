module ema (
		clk,
		rst, 
		x_i,
		alpha_i,
		valid_i,
		
		y_o,
		bussy_o,
		valid_o
);

parameter Win = 16;
parameter Wout = 16;
localparam Winternal = Win + Wout;

//ALU Modes
localparam ALU_IDLE = 2'd0;
localparam ADD 		= 2'd1;
localparam MULT		= 2'd2;

//FSM State Definitions
localparam IDLE 			= 2'd0;
localparam MULT_FETCH	 	= 2'd1;
localparam MULT_EXEC		= 2'd2;
localparam EVAL				= 2'd3;

// I/0 Ports
input 							clk;
input 							rst;
input signed [Win-1:0] 			x_i;
input  [Win-2:0]				alpha_i;
input 							valid_i;

output wire signed	[Wout-1:0] 	y_o;
output reg						valid_o, bussy_o;

// Internal Registers
reg 							valid_r;
reg signed [Win-1:0]			x_r;
reg 	   [Win-2:0]			alpha_r;

reg signed [Win-1:0]			x_save_temp, x_save_r;
reg signed [Win-1:0]      		y_o_temp;
reg signed [Win-1:0]			y_last_r;

//FSM
reg [1:0]						current_state, next_state;

//ALU
reg	[1:0]						alu_mode, alu2_mode;
reg								alu_valid, alu2_valid;
reg [Win-1:0]					alu_op1, alu_op2;
reg [Win-1:0]					alu2_op1, alu2_op2;
wire 							alu_result_valid, alu2_result_valid;
wire signed [Winternal-1:0]		alu_result, alu2_result;
reg signed [Winternal-1:0]		alu_result_r, alu2_result_r;

// Ergebnisregister
reg signed [Win-1:0]		mult_x_a_temp, mult_x_a_r;
reg signed [Win-1:0]		mult_y_a_temp, mult_y_a_r;

alu ALU (
.clk				(clk),
.rst				(rst),
.op1_i 				(alu_op1),
.op2_i				(alu_op2),
.valid_i 			(alu_valid),
.mode_i				(alu_mode),

.res_o				(alu_result),
.valid_o 			(alu_result_valid)
);

alu ALU2 (
.clk				(clk),
.rst				(rst),
.op1_i 				(alu2_op1),
.op2_i				(alu2_op2),
.valid_i 			(alu2_valid),
.mode_i				(alu2_mode),

.res_o				(alu2_result),
.valid_o 			(alu2_result_valid)
);

always @ (posedge clk) begin
	if (rst) begin
		valid_r 		<= 1'b0;
		x_save_r 		<= 'd0;
		x_r 			<= 'd0;
		alpha_r 		<= 'd0;
		current_state 	<= IDLE;
		alu_mode		<= ALU_IDLE;
		alu_result_r 	<= 'd0;
		mult_x_a_r 		<= 'd0;
		mult_y_a_r 		<= 'd0;
		y_last_r        <= 'd0;
	
	end
	
	else begin 
		valid_r 		<= valid_i;
		x_save_r		<= x_save_temp;
		x_r				<= x_i;
		alpha_r			<= alpha_i;
		mult_x_a_r		<= mult_x_a_temp;
		mult_y_a_r		<= mult_y_a_temp;
		alu_result_r	<= alu_result;
		alu2_result_r	<= alu2_result;
		current_state   <= next_state;
		y_last_r 		<= y_o_temp;
		
	end
end

always @ (*) begin
	x_save_temp			= x_save_r;
	y_o_temp			= y_last_r;
	mult_x_a_temp		= mult_x_a_r;
	mult_y_a_temp		= mult_y_a_r;
	valid_o				= 1'b0;
	bussy_o				= 1'b1;
	alu_mode			= ALU_IDLE;
	alu_op1				= 'd0;
	alu_op2				= 'd0;
	alu_valid			= 1'b0;
	alu2_mode			= ALU_IDLE;
	alu2_op1			= 'd0;
	alu2_op2			= 'd0;
	alu2_valid			= 1'b0;
	next_state			= current_state;

case (current_state)
	IDLE: begin	
	bussy_o 	= 1'b0;
	alu_mode	= ALU_IDLE;
		if (valid_r) begin
			next_state	= MULT_FETCH;
		end
	end
	
	MULT_FETCH: begin
		alu_mode 	= MULT;
		alu_op1 	= x_r;
		alu_op2		= {1'd0, alpha_r};
		alu_valid 	= 1'b1;
		
		alu2_mode	= MULT;
		alu2_op1	= y_last_r;
		alu2_op2	= {1'd0, ~alpha_r}; // (1-alpha) = inverted Binary
		alu2_valid 	= 1'b1;	
		
		next_state	= MULT_EXEC;
	end
	
	MULT_EXEC: begin
		if (alu_result_valid & alu2_result_valid) begin
		alu_mode 		= ALU_IDLE;
		alu2_mode		= ALU_IDLE;
		next_state 		= EVAL ;
		mult_x_a_temp 	= alu_result >>> (Win-1);
		mult_y_a_temp 	= alu2_result >>> (Win-1);
		end
	end
	
	EVAL: begin
		valid_o 		= 1'b1;
		y_o_temp		= mult_x_a_r + mult_y_a_r;
		alu_mode 		= ALU_IDLE;
		next_state		= IDLE;
	end
endcase
	
end

assign y_o = y_o_temp;

endmodule