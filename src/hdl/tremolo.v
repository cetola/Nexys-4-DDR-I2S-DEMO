`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: PSU
// Engineer: Stephano Cetola
// 
// Create Date: 11/30/2018 02:37:45 PM
// Design Name: 
// Module Name: distortion
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Tremelo effect. More comments soon.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tremolo #(
    parameter DATA_WIDTH = 24
) (
    input wire clk,
    input wire tremolo_sw,
    input  wire [DATA_WIDTH-1:0] rx_data,
    output reg [DATA_WIDTH-1:0] tx_data
);

    reg [14:0] tremolo_count = 0;
    reg [9:0] tremolo_amp = 0;
    reg tremolo_dec = 0;
    
    always@(posedge clk) begin
        tremolo_count <= tremolo_count + 1'b1;
        
        if(&tremolo_count) begin
            if(tremolo_dec) begin
                tremolo_amp = tremolo_amp - 1'b1;
                if (tremolo_amp === 0) tremolo_dec = !tremolo_dec;
            end
            else begin
                tremolo_amp = tremolo_amp + 1'b1;
                if (tremolo_amp === 1024) tremolo_dec = !tremolo_dec;
            end
        end
        
        if (tremolo_sw)
            tx_data <= (rx_data * (1024 + tremolo_amp)>>10);
        else
            tx_data <= rx_data;
    end
endmodule
