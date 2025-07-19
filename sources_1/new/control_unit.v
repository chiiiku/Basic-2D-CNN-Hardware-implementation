`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2025 19:46:31
// Design Name: 
// Module Name: control
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


module control
#(parameter STRIDE = 1, STRIDE_POOL = 2, IMG_COLS = 32, IMG_ROWS = 32, KERNEL_SIZE = 3, BITS = 8, POOL_COL = 2, POOL_ROW = 2)(
    input clk,
    input reset,
    input en,
    input macc,
    input reluu,
    input poolingg,
    output reg done,
    output [BITS-1:0] out
    );
    
   //for fsm  
   localparam [1:0] IDLE = 2'b00, MAC = 2'b01, RELU = 2'b10, POOL = 2'b11;
   reg [1:0] state, nextstate;
   
   //output size calculation
   localparam OUT_ROWS = ((IMG_ROWS - KERNEL_SIZE) / STRIDE) + 1;
   localparam OUT_COLS = ((IMG_COLS - KERNEL_SIZE) / STRIDE) + 1;
   
   //variables used
   //reg [7:0] img [0:63];
   reg [7:0] row, col;
   wire [BITS-1:0] o0, o1, o2, o3;
   wire [BITS-1:0] o00, o11, o22, o33;
   wire [BITS-1:0] send0, send1, send2, send3;

   (* ram_style = "block" *)reg [7:0] img [0:1023];  
   
   initial begin
       $readmemh("img.mem", img);
   end

    assign send0 = row * IMG_COLS + col;
    assign send1 = send0 + IMG_COLS;
    assign send2 = send0 + IMG_COLS * 2;
    assign send3 = send0 + IMG_COLS * 3;
    
    //mac instatiations
    mac u1(.clk(clk), .reset(reset), .i0(img[send0]), .i1(img[send0 + 8'd1]), .i2(img[send0 + 8'd2]), 
    .i3(img[send1]), .i4(img[send1 + 8'd1]), .i5(img[send1 + 8'd2]), 
    .i6(img[send2]), .i7(img[send2 + 8'd1]), .i8(img[send2 + 8'd2]), .out(o0), .start(poolingg), .done_mac(macc), .en(en));

    mac u2(.clk(clk), .reset(reset), .i0(img[send0 + STRIDE]), .i1(img[send0 + STRIDE + 8'd1]), .i2(img[send0 + STRIDE + 8'd2]), 
    .i3(img[send1 + STRIDE]), .i4(img[send1 + STRIDE + 8'd1]), .i5(img[send1 + STRIDE + 8'd2]), 
    .i6(img[send2 + STRIDE]), .i7(img[send2 + STRIDE + 8'd1]), .i8(img[send2 + STRIDE + 8'd2]), .out(o1), .start(poolingg), .done_mac(macc), .en(en));

    mac u3(.clk(clk), .reset(reset), .i0(img[send1]), .i1(img[send1 + 8'd1]), .i2(img[send1 + 8'd2]), 
    .i3(img[send2]), .i4(img[send2 + 8'd1]), .i5(img[send2 + 8'd2]), 
    .i6(img[send3]), .i7(img[send3 + 8'd1]), .i8(img[send3 + 8'd2]), .out(o2), .start(poolingg), .done_mac(macc), .en(en));

    mac u4(.clk(clk), .reset(reset), .i0(img[send1 + STRIDE]), .i1(img[send1 + STRIDE + 8'd1]), .i2(img[send1 + STRIDE + 8'd2]), 
    .i3(img[send2 + STRIDE]), .i4(img[send2 + STRIDE + 8'd1]), .i5(img[send2 + STRIDE + 8'd2]), 
    .i6(img[send3 + STRIDE]), .i7(img[send3 + STRIDE + 8'd1]), .i8(img[send3 + STRIDE + 8'd2]), .out(o3), .start(poolingg), .done_mac(macc), .en(en));

    //relu instantiations
    relu r1(.clk(clk), .reset(reset), .in(o0), .out(o00), .start(macc), .done_relu(reluu));
    relu r2(.clk(clk), .reset(reset), .in(o1), .out(o11), .start(macc), .done_relu(reluu));
    relu r3(.clk(clk), .reset(reset), .in(o2), .out(o22), .start(macc), .done_relu(reluu));
    relu r4(.clk(clk), .reset(reset), .in(o3), .out(o33), .start(macc), .done_relu(reluu));
    
    //pooling instantiations
    pool u5(.clk(clk), .reset(reset), .start(reluu), .i0(o00), .i1(o11), .i2(o22), .i3(o33), .out(out), .done_pool(poolingg));
    

    //sequential 
    always@(posedge clk) begin
    if(reset) begin
        row <= 0;
        col <= 0;
        done <= 0;
        state <= IDLE;
    end
    else begin
    if (state == MAC) begin
        if (col + STRIDE < (IMG_COLS - KERNEL_SIZE)) begin
            col <= col + 2*STRIDE;
        end
        else begin
            col <= 0;
            row <= row + 2*STRIDE;
        end
        
        if (row > (IMG_ROWS - KERNEL_SIZE)) begin
            done <= 1;
        end
        else done <= 0;
    end
    state <= nextstate;
    end
    end
       
//combinational       
    always@(*) begin
    case(state) 
        IDLE : begin
            nextstate = MAC; 
        end
        MAC : begin     
            if(macc) nextstate = RELU;
        end
        RELU : begin
            if(reluu) nextstate = POOL;
        end
        POOL : begin
            if(poolingg) nextstate = MAC;
        end
    endcase
    end
           
endmodule
