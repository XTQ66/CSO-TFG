`timescale 1ns/1ps

module automatic test_karatsuba_62();

logic clk,rst;
logic [61:0] x,y;
wire [123:0] product;

reg [123:0] test,test_d1,test_d2,test_d3,test_d4,test_d5,test_d6,test_d7,test_d8;

always@(posedge clk)
    test<=x*y;

always@(posedge clk)
    {test_d8,test_d7,test_d6,test_d5,test_d4,test_d3,test_d2,test_d1}<={test_d7,test_d6,test_d5,test_d4,test_d3,test_d2,test_d1,test}; 
    

always #5 clk = ~clk;
initial
begin
    clk = 0;
    rst = 0;
    @(negedge clk)
        rst = 1;
    fork
        begin
            forever
            begin
                @(negedge clk)
                x = $random % (64'b1 << 62);
                y = $random % (64'b1 << 62);
            end
        end
    join_none
end

karatsuba_multiply_62 dut
(
    .clk(clk)         ,
    .x(x)             , 
    .y(y)             ,   
    .product(product) 
);
    
wire compare;

assign compare = product == test_d7;

endmodule

