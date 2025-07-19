`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2024 13:45:17
// Design Name: 
// Module Name: all_in_one_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module all_in_one_tb();

reg clk;
reg reset;
reg en;

control dut(.clk(clk), 
            .reset(reset), .en(en));

initial begin
clk = 0;
forever #10 clk = ~clk;
end

initial begin

reset = 1;
en = 0;
#70;
reset = 0;
en = 1;
#20;
en = 0;

end

// initial begin
//        $monitor("Time: %0t | clk: %b | reset: %b", $time, clk, reset);
// end
    
endmodule
