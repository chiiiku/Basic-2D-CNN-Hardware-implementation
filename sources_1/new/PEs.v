`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2024 13:30:43
// Design Name: 
// Module Name: all_in_one
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

module mac
#(parameter BITS = 8)(
    input clk,
    input reset,
    input start,
    input en,
    input [BITS-1:0] i0,
    input [BITS-1:0] i1,
    input [BITS-1:0] i2,
    input [BITS-1:0] i3,
    input [BITS-1:0] i4,
    input [BITS-1:0] i5,
    input [BITS-1:0] i6,
    input [BITS-1:0] i7,
    input [BITS-1:0] i8,
    output [BITS-1:0] out,
    output reg done_mac
    );
  
   reg [7:0] kernel [0:8];
   
   initial begin
        kernel[0] = 1; kernel[1] = 0; kernel[2] = 1;
        kernel[3] = 1; kernel[4] = 0; kernel[5] = 1;
        kernel[6] = 1; kernel[7] = 0; kernel[8] = 1;
    end
   
   reg [BITS-1:0] temp_reg, temp_next;
        
    always@(posedge clk) begin
    if(reset) begin
        temp_reg <= 0;
        done_mac <= 0;
    end
    else if(en | start) begin
        temp_reg <= temp_next;
        done_mac <= 1;
    end
    else begin
        temp_reg <= 0;
        done_mac <= 0;
    end
    end    
    
    always@(*) begin 
    temp_next = 
        kernel[0] * i0 + kernel[1] * i1 + kernel[2] * i2 +
        kernel[3] * i3 + kernel[4] * i4 + kernel[5] * i5 +
        kernel[6] * i6 + kernel[7] * i7 + kernel[8] * i8;    
    
    end                        
           
assign out = temp_reg;

endmodule




module relu
#(parameter BITS = 8)(
    input clk,
    input reset,
    input start,
    input [BITS-1:0] in,
    output [BITS-1:0] out,
    output reg done_relu 
    );
     
   reg [BITS-1:0] temp_reg, temp_next;

    always@(posedge clk) begin
    if(reset) begin
        temp_reg <= 0;
        done_relu <= 0;
    end
    else if(start) begin
        temp_reg <= temp_next;
        done_relu <= 1;
    end
    else begin
        temp_reg <= 0;
        done_relu <= 0;
    end
    end
            
    always@(*) begin 
        if(in < 0 | in == 0) temp_next = 0;
        else temp_next <= in;
    end

assign out = temp_reg;               
        
               
endmodule




module pool
#(parameter BITS = 8)(
    input clk,
    input reset,
    input [BITS-1:0] i0,
    input [BITS-1:0] i1,
    input [BITS-1:0] i2,
    input [BITS-1:0] i3,
    input start,
    output [BITS-1:0] out,
    output reg done_pool
    );
    
    reg [BITS-1:0] temp_reg, temp_next;
    
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            temp_reg <= 0;
            done_pool <= 0;
        end
        else if(start) begin
            temp_reg <= temp_next;
            done_pool <= 1;
        end
        else begin
            temp_reg <= temp_next;
            done_pool <= 0;
        end
    end
    
   always @(*) begin
    temp_next = i0; 
    if (i1 > temp_next) temp_next = i1;
    if (i2 > temp_next) temp_next = i2;
    if (i3 > temp_next) temp_next = i3;
    end
    
    assign out = temp_reg;
    
endmodule