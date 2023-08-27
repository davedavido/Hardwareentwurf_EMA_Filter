module ema_tb;

reg clk, rst;


reg [15:0] x_i; //Q16.0
reg [14:0] alpha_i; //Q0.15 
reg valid_i;

wire signed [15:0] y_o; //Q16.0
wire bussy_o, valid_o;

integer fd_i, fd_o, tmp;

ema DUT(
	.rst		(rst),
	.clk		(clk),
	.x_i		(x_i),
	.alpha_i 	(alpha_i),
	.valid_i 	(valid_i),
	
	.y_o		(y_o),
	.bussy_o	(bussy_o),
	.valid_o 	(valid_o)
);

always 
		#1 clk = !clk;
		
initial begin
	fd_i = $fopen("input.txt", "r");
	fd_o = $fopen("output.txt", "w");
	
	if (fd_i)     $display("File was opened successfully : %0d", fd_i);
    else      	  $display("File was NOT opened successfully : %0d", fd_i);

    if (fd_o)     $display("File was opened successfully : %0d", fd_o);
    else      	  $display("File was NOT opened successfully : %0d", fd_o);
	
	#50
	clk		= 0;
	rst	    = 1;
	x_i		= 16'd0;
	alpha_i = 15'd9830; // -> alpha = 0.3 Q0.15
	#2
	rst 		= 0;

end

always @ (posedge clk) begin

	if (!($feof(fd_i))) begin
			tmp = $fscanf(fd_i, "%d\n", x_i);
			#2
			valid_i = 1'b1;
			#6
			$fwrite(fd_o, "%d\n", y_o);
			valid_i = 1'b0;
	end 
	
	else begin
		$fclose(fd_i);
		$fclose(fd_o);
		$finish;
	end
end
endmodule