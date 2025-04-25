
//module karatsuba_multiply_32
//(
//    input  [31:0]  x, 
//    input  [31:0]  y, 
//    output [63:0]  product
//);
    
//    wire [15:0] a,b,c,d;
//    wire [31:0] ac,bd, ab_cd;
//      // Split x and y into 31-bit parts
//      assign a = x[31:16];   // High 31 bits of x
//      assign b = x[15:0];    // Low 31 bits of x
//      assign c = y[31:16];   // High 31 bits of y
//      assign d = y[15:0];    // Low 31 bits of y

//      // Step 1: Compute ac = a * c
//      assign ac = a * c;

//      // Step 2: Compute bd = b * d
//      assign bd = b * d;

//      // Step 3: Compute (a + b) * (c + d)
//      assign ab_cd = (a + b) * (c + d);

//      // Step 4: Combine results to get the final product
//       assign product = {ac, 32'b0} + {$signed({1'b0,ab_cd}) - $signed({1'b0,ac}) - $signed({1'b0,bd}), 16'b0} + bd;
    
//endmodule

module karatsuba_multiply_32
(
    input               clk     ,
    input       [31:0]  x       , 
    input       [31:0]  y       ,   
    output reg  [63:0]  product
);
    
    wire [15:0] a,b,c,d;
    reg [31:0] ac,bd, ac_d1,ac_d2,ac_d3, bd_d1,bd_d2,bd_d3;
    reg [16:0] a_add_b, c_add_d;
    reg [33:0] ab_cd, ab_cd_d1; 
    reg [63:0] temp0,temp1,temp2;
      // Split x and y into 31-bit parts
      assign a = x[31:16];   // High 31 bits of x
      assign b = x[15:0];    // Low 31 bits of x
      assign c = y[31:16];   // High 31 bits of y
      assign d = y[15:0];    // Low 31 bits of y

      always@(posedge clk) begin
        {ac_d1,ac_d2,ac_d3}<={ac,ac_d1,ac_d2};
        {bd_d1,bd_d2,bd_d3}<={bd,bd_d1,bd_d2};
        ab_cd_d1 <= ab_cd;
      end

      // Step 1: Compute ac = a * c
      always@(posedge clk ) begin
        ac <= a * c;
      end 

      // Step 2: Compute bd = b * d
      always@(posedge clk ) begin 
        bd <= b * d;
      end


      // Step 3: Compute (a + b) * (c + d)
      always@(posedge clk ) begin
        a_add_b <= (a + b) ;
        c_add_d <= (c + d) ;
        ab_cd <= a_add_b * c_add_d;
      end

      always @(posedge clk ) begin
        temp0 <= {$signed({1'b0,ab_cd}) - $signed({1'b0,ac_d1}) - $signed({1'b0,bd_d1}), 16'b0};
        temp1 <= temp0 + bd_d2;
        product <= temp1 + {ac_d3, 32'b0};
      end

endmodule