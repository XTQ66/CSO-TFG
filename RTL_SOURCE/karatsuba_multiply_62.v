`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/09 12:39:22
// Design Name: 
// Module Name: karatsuba_multiply_62
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
//module karatsuba_multiply_62
//(
//    input  [61:0]  x, 
//    input  [61:0]  y, 
//    output [123:0]  product
//);
    
//    wire [31:0] a,b,c,d,ab,cd;
//    wire [63:0] ac,bd, ab_cd;
//      // Split x and y into 31-bit parts
//      assign a = {1'b0,x[61:31]};   // High 31 bits of x
//      assign b = {1'b0,x[30:0]};    // Low 31 bits of x
//      assign c = {1'b0,y[61:31]};   // High 31 bits of y
//      assign d = {1'b0,y[30:0]};    // Low 31 bits of y

//      // Step 1: Compute ac = a * c
//      karatsuba_multiply_32 u_karatsuba_multiply_32_0
//      (
//          .x        ( a     ),
//          .y        ( c     ),
//          .product  ( ac    )
//      );

//      // Step 2: Compute bd = b * d
//      karatsuba_multiply_32 u_karatsuba_multiply_32_1
//      (
//          .x        ( b     ),
//          .y        ( d     ),
//          .product  ( bd    )
//      );

//        assign ab = (a + b);
//        assign cd = (c + d);

//      // Step 3: Compute (a + b) * (c + d)
//      karatsuba_multiply_32 u_karatsuba_multiply_32_2
//      (
//          .x        ( ab       ),
//          .y        ( cd       ),
//          .product  ( ab_cd    )
//      );


//      // Step 4: Combine results to get the final product
//       assign product = {ac[61:0], 62'b0} + {$signed({1'b0,ab_cd}) - $signed({1'b0,ac}) - $signed({1'b0,bd}), 31'b0} + bd;
    
//endmodule


module karatsuba_multiply_62
(
    input                      clk,
    input       [61:0]           x, 
    input       [61:0]           y, 
    output reg [123:0]     product
);
    
    wire [31:0] a,b,c,d;
    wire [32:0] ab,cd;
    wire [63:0] ac,bd, ab_cd;
    reg  [63:0] ac_d1, ac_d2, bd_d1;
    reg [123:0] temp0,temp1,temp2;
      // Split x and y into 31-bit parts
      assign a = {1'b0,x[61:31]};   // High 31 bits of x
      assign b = {1'b0,x[30:0]};    // Low 31 bits of x
      assign c = {1'b0,y[61:31]};   // High 31 bits of y
      assign d = {1'b0,y[30:0]};    // Low 31 bits of y

      // Step 1: Compute ac = a * c
      karatsuba_multiply_32 u_karatsuba_multiply_32_0
      (
          .clk      (clk    ),
          .x        ( a     ),
          .y        ( c     ),
          .product  ( ac    )
      );

      // Step 2: Compute bd = b * d
      karatsuba_multiply_32 u_karatsuba_multiply_32_1
      (
          .clk      (clk    ),
          .x        ( b     ),
          .y        ( d     ),
          .product  ( bd    )
      );

        assign ab = (a + b);
        assign cd = (c + d);

      // Step 3: Compute (a + b) * (c + d)
      karatsuba_multiply_32 u_karatsuba_multiply_32_2
      (
          .clk      (clk       ),
          .x        ( ab[31:0] ),
          .y        ( cd[31:0] ),
          .product  ( ab_cd    )
      );

      always@(posedge clk ) begin
        bd_d1 <= bd;
        {ac_d1,ac_d2}<={ac,ac_d1};
        temp0 <= {$signed({1'b0,ab_cd}) - $signed({1'b0,ac}) - $signed({1'b0,bd}), 31'b0};
        temp1 <= temp0 + bd_d1;
        product <= temp1 + {ac_d2[61:0], 62'b0} ;
      end

endmodule