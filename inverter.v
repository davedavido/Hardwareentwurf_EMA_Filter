`include "projectGlobalParam.v"

module inverter(
	clk,
	rst,
	x_i,
	valid_i,
	y_o,
	valid_o,
	bussy_o
);

parameter 	Win 	= 8;
parameter 	Wout 	= 8;
localparam   Winternal = Win + Wout;

localparam ADD 			= 	3'd0;
localparam SUB 			= 	3'd1;
localparam SHIFTDOWN 	= 	3'd5;

localparam IDLE 		= 3'd0;	
localparam XSHIFT_FETCH	= 3'd1;
localparam XSHIFT_EXEC	= 3'd2;
localparam ACCU_FETCH	= 3'd3;
localparam ACCU_EXEC	= 3'd4;
localparam DIFF_FETCH	= 3'd5;
localparam DIFF_EXEC	= 3'd6;
localparam EVAL_RESULT	= 3'd7;


input 							clk;
input 							rst;
input signed [Win-1:0] 			x_i;
input 							valid_i;

output wire signed [Wout-1:0] 	y_o;
output reg 					    valid_o, bussy_o;

reg 							valid_r;					// input Register
reg signed [Win-1:0] 			x_r;						// input Register
reg [2:0] 						current_state, next_state;  // FSM

reg signed 	[Winternal -1:0] 	x_save_r, x_save_temp; 				// speichert x dauerhaft
reg signed 	[Winternal -1:0] 	diff_save_r, diff_save_temp; 		// Temp Register für Differenzwert
reg signed 	[Winternal -1:0] 	accu_r, accu_temp; 			 		// Register für Akkumulator
reg signed 	[Wout - 1:0] 		y_out_r, y_out_temp;				// Binärer Ergebnisvektor	
reg 		[Winternal-1:0] 	bit_shift_r, bit_shift_temp; 		// Bitshift Wert - Zweierpotenz
wire 							sigma;						 		// Vorzeichen der Differenz
assign 							sigma = diff_save_r[Winternal-1];	// MSB Vorzeichenbit der Differenz

reg [2:0] 						alu_mode;
reg 							alu_valid;
reg [Winternal - 1:0] 			alu_op1, alu_op2;
wire 						    alu_result_valid;
wire signed 	[Winternal - 1:0] 	alu_result;
reg  signed 	[Winternal - 1:0] 	alu_result_r;

alu_fixed_point #(.W_in(Winternal), .W_out(Winternal)) ALU(
	.clk		(clk),
	.rst		(rst),
	.op1_i		(alu_op1),
	.op2_i		(alu_op2),
	.mode_i		(alu_mode),
	.valid_i	(alu_valid),
	
	.res_o		(alu_result),
	.valid_o	(alu_result_valid)
);

always @ (posedge clk) begin
	if(rst == `RST_VAL) begin
		valid_r  		<= 1'b0;
		x_save_r  		<= 'd0;
		x_r		 		<= 'd0;
		bit_shift_r 	<= 'd0;
		y_out_r 		<= 'd0;
		accu_r 			<= 'd0;
		current_state 	<= IDLE;
		alu_result_r 	<= 'd0;
		diff_save_r 	<= 'd0;
	end
	else begin
		valid_r 		<= valid_i;
		x_save_r 		<= x_save_temp;
		x_r				<= x_i;
		bit_shift_r 	<= bit_shift_temp;
		y_out_r 		<= y_out_temp;
		accu_r 			<= accu_temp;
		current_state 	<= next_state;
		alu_result_r 	<= alu_result;
		diff_save_r 	<= diff_save_temp;
	end
end

always @ (*) begin
	x_save_temp 	= x_save_r;
	bit_shift_temp  = bit_shift_r;
	diff_save_temp  = diff_save_r;
	y_out_temp 		= y_out_r;
	accu_temp 		= accu_r;
	valid_o 		= 1'b0;
	bussy_o			= 1'b1;
	alu_mode 		= ADD;
	alu_op1			= 'd0;
	alu_op2			= 'd0;
	alu_valid 		= 1'b0;
	next_state 		= current_state;
	
	case(current_state)
		IDLE: begin
			bussy_o = 1'b0;
			if(valid_r) begin
				next_state 		= XSHIFT_FETCH;
				accu_temp 		= 'd0;
				x_save_temp 	= {x_r, {(Wout){1'b0}}};
				y_out_temp 		= 'd0;
				bit_shift_temp  = 'd0;
				diff_save_temp  = 'd0;
			end
		end
		
		XSHIFT_FETCH: begin  // x*sigma*2^(n(it))
			alu_mode 		= SHIFTDOWN;
			alu_op1			= (sigma == 1'b0) ?  x_save_r : -x_save_r;
			alu_op2			= bit_shift_r;
			next_state 		= XSHIFT_EXEC;
			alu_valid 		= 1'b1;
		end
		
		XSHIFT_EXEC: begin
			if(alu_result_valid) begin
				next_state 		= ACCU_FETCH;
			end
		end
		
		ACCU_FETCH: begin   // accu    = accu + x*sigma*2^(n(it));
			alu_mode 		= ADD;
			alu_op1			= accu_r;
			alu_op2			= alu_result_r;
			next_state 		= ACCU_EXEC;
			alu_valid 		= 1'b1;
		end
		
		ACCU_EXEC: begin
			if(alu_result_valid) begin
				next_state 		= DIFF_FETCH;
				accu_temp 		= alu_result;
			end
		end
		
		DIFF_FETCH: begin   // diff    = 1 - accu;
			alu_mode 		= SUB;
			alu_op1			= {{(Win-1){1'b0}}, 1'b1, {(Wout){1'b0}}}; // Festkomma 1 mit Win Bit Integer part und Wout Bit Fractional part 
			alu_op2			= accu_r;
			next_state 		= DIFF_EXEC;
			alu_valid 		= 1'b1;
		end
		
		DIFF_EXEC: begin
			if(alu_result_valid) begin
				next_state 			= EVAL_RESULT;
				diff_save_temp 		= alu_result;
			end
		end
		
		EVAL_RESULT: begin
			bit_shift_temp  		= bit_shift_r + 'd1; // 2^(n(it))
			y_out_temp[Wout - 1 - bit_shift_r] = !sigma;
			if(diff_save_r == 'd0 || bit_shift_r == (Wout-1)) begin
				valid_o 		= 1'b1;
				next_state 		= IDLE;
			end
			else begin
				next_state = XSHIFT_FETCH;
			end
		end
		
	endcase
	
end


assign y_o 		= y_out_temp;

endmodule


///// Reference Matlab Code
/* 
	function [res, resbinary] = myinversion(x,N)
 
    n           = [0:-1:-N+1];     % Vektor mit Zweierpotenzen zur Ergebnisdarstellung 
    sigma       = 1;               % Vorzeichen entweder 1 oder -1
    res         = 0;               % Vorinitialisierte Ergebnisvariable
    accu        = 0;               % Akkumulator-Register
    resbinary   = zeros(1,N);      % Binärer Ergebnisvektor initialisiert mit 0

    for it = 1:N 
        accu    = accu + x*sigma*2^(n(it));
        diff    = 1 - accu;
        sigma   = sign(diff);

        if(diff >= 0)
            resbinary(it) = 1; 
            res     = res + 2^(n(it));      % Ergebnisausgabe nur für Matlab relevant
            if(diff == 0)
                break;
            end
        else
           resbinary(it) = 0;
        end
    end 
	
	*/


