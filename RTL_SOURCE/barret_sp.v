`timescale 1ns / 1ps
//`include "define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/24 14:43:15
// Design Name: 
// Module Name: barret_sp
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

//barret_sp#(
//    .MAX_BW   ( 62 )
//)u_barret_sp(
//    .clk      ( clk      ),
//    .rst_n    ( rst_n    ),
//    .i_valid  ( i_valid  ),
//    .i_mode   ( i_mode   ),
//    .i_xy     ( i_xy     ),
//    .i_q      ( i_q      ),
//    .i_t      ( i_t      ),
//    .o_valid  ( o_valid  ),
//    .o_res    ( o_res    )
//);

//39???????????
//18mul+18mul+1sub+1sub+1mux=39delay;

//module barret_sp
//#(
//    parameter MAX_BW = 62
//)
//(
//    input                             clk     ,
//    input                             rst_n   ,
//    input                             i_valid ,
//    input                             i_mode  ,
//    input       [2*MAX_BW-1:0]        i_xy    ,
// //input        [5:0]                 i_l     ,
//    input       [MAX_BW-1:0]          i_q     , 
//    input       [MAX_BW:0]            i_t     ,
//    output                            o_valid,
//    output      [2*MAX_BW-1:0]        o_res //sp??         

//);

//assign o_res = {xy_d39[2*MAX_BW-1:MAX_BW],res} ;//sp??   
//assign o_valid = valid[38];

////-----------------------------------------------------------------------------------------
////reg [MAX_BW-1:0] q_sp=0;//sp??
////always@(posedge clk or negedge rst_n)
////begin
////    if(!rst_n)
////        q_sp<=0;
////    else if(i_mode)
////        q_sp<=128'hffffffffffffffffff;
////    else
////        q_sp<=i_q;
////end

//reg [40:0] valid=0;

//always@(posedge clk or negedge rst_n)
//begin
//    if(!rst_n)
//        valid<=0;
//    else
//        valid<={valid[39:0],i_valid};
//end

//reg [2*MAX_BW-1:0] 
//xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10, 
//xy_d11, xy_d12, xy_d13, xy_d14, xy_d15, xy_d16, xy_d17, xy_d18, xy_d19, xy_d20, 
//xy_d21, xy_d22, xy_d23, xy_d24, xy_d25, xy_d26, xy_d27, xy_d28, xy_d29, xy_d30, 
//xy_d31, xy_d32, xy_d33, xy_d34, xy_d35, xy_d36, xy_d37, xy_d38, xy_d39, xy_d40; 

//always@(posedge clk or negedge rst_n) 
//begin
//    if(!rst_n)
//        {
//            xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10, 
//            xy_d11, xy_d12, xy_d13, xy_d14, xy_d15, xy_d16, xy_d17, xy_d18, xy_d19, xy_d20, 
//            xy_d21, xy_d22, xy_d23, xy_d24, xy_d25, xy_d26, xy_d27, xy_d28, xy_d29, xy_d30, 
//            xy_d31, xy_d32, xy_d33, xy_d34, xy_d35, xy_d36, xy_d37, xy_d38, xy_d39, xy_d40
//        }
//        <=0;
//    else
//        {
//            xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10, 
//            xy_d11, xy_d12, xy_d13, xy_d14, xy_d15, xy_d16, xy_d17, xy_d18, xy_d19, xy_d20, 
//            xy_d21, xy_d22, xy_d23, xy_d24, xy_d25, xy_d26, xy_d27, xy_d28, xy_d29, xy_d30, 
//            xy_d31, xy_d32, xy_d33, xy_d34, xy_d35, xy_d36, xy_d37, xy_d38, xy_d39, xy_d40
//        }
//        <=
//        {
//            i_xy, xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10, 
//            xy_d11, xy_d12, xy_d13, xy_d14, xy_d15, xy_d16, xy_d17, xy_d18, xy_d19, xy_d20, 
//            xy_d21, xy_d22, xy_d23, xy_d24, xy_d25, xy_d26, xy_d27, xy_d28, xy_d29, xy_d30, 
//            xy_d31, xy_d32, xy_d33, xy_d34, xy_d35, xy_d36, xy_d37, xy_d38, xy_d39
//        };
//end
////----------------------------------------------------------------------------------------

//wire    [MAX_BW:0]  ah, bh ; 
//assign ah = i_mode ? 0:(i_xy[2*MAX_BW-1:MAX_BW-1]); // >> (l+1) //sp??
//assign bh = i_t;

//wire [2*MAX_BW+2-1:0] uh_out ;
//mult_gen_1 uh_multi  (
//  .CLK(clk),             // input wire CLK
//  .A(ah),                // input wire [62 : 0] A
//  .B(bh),                // input wire [62 : 0] B
//  .P(uh_out)             // output wire [125 : 0] P, pipeline stages = 18;
//);

//wire    [MAX_BW:0]  uh_out_high ; // high l+1 bits
//assign uh_out_high = uh_out[2*MAX_BW+2-1:MAX_BW+1]; // >> (l+1)

//wire    [MAX_BW:0]  al, bl ; 
//assign al = uh_out_high;
//assign bl = {1'b0,i_q};

//wire [2*MAX_BW+2-1:0] lh_out ;
//mult_gen_1 lh_multi  (
//  .CLK(clk),             // input wire CLK
//  .A(al),                // input wire [62 : 0] A
//  .B(bl),                // input wire [62 : 0] B
//  .P(lh_out)             // output wire [125 : 0] P, pipeline stages = 18;
//);

//wire    [MAX_BW:0]      lh_out_low; //low l+1 bits
//assign lh_out_low = lh_out[MAX_BW:0];

//reg    [MAX_BW:0]   sub1    = 0 ; //????????????signed????,????????锟斤拷
//reg    [MAX_BW:0]   sub1_d1 = 0 ; 

////
//always@(posedge clk or negedge rst_n)
//begin
//    if(!rst_n)  
//        sub1<=0;
//    else
//        sub1<=xy_d36[MAX_BW:0]-lh_out_low;////sp??
//end

//always@(posedge clk or negedge rst_n)   
//begin
//    if(!rst_n)  
//        sub1_d1<=0;
//    else
//        sub1_d1<=sub1;
//end

//reg  signed  [MAX_BW+1:0]   sub2    = 0 ; 

//always@(posedge clk or negedge rst_n)
//begin
//    if(!rst_n)
//        sub2<=0;
//    else
//        sub2<=$signed({1'b0,sub1})-$signed({2'b0,i_q});
//end

//reg     [MAX_BW-1:0]      res;
//always@(posedge clk or negedge rst_n)
//begin
//    if(!rst_n)
//        res<=0;
//    else if(sub2[MAX_BW+1] || i_mode) //mux??????,sp??
//        res<=sub1_d1;
//    else
//        res<=sub2;
//end


//endmodule

//-----------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------

//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/31 11:10:21
// Design Name: 
// Module Name: barret_sp_hanming
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


module barret_sp
#(
    parameter MAX_BW = 62
)
(
    input                             clk     ,
    input                             rst_n   ,
    input                             i_valid ,
    input                             i_mode  ,
    input       [2*MAX_BW-1:0]        i_xy    ,
 //input        [5:0]                 i_l     ,
    input       [MAX_BW-1:0]          i_q     , 
    input       [MAX_BW:0]            i_t     ,
    output                            o_valid,
    output      [2*MAX_BW-1:0]        o_res //sp??         

);

wire                             i_hamming_sign0       ;
wire       [4:0]                 i_hamming_index0      ;
wire                             i_hamming_sign1       ;
wire       [4:0]                 i_hamming_index1      ;

wire                             i_hamming_sign0_T     ;
wire       [4:0]                 i_hamming_index0_T    ;
wire                             i_hamming_sign1_T     ;
wire       [4:0]                 i_hamming_index1_T    ;
wire                             i_hamming_sign2_T     ;
wire       [4:0]                 i_hamming_index2_T    ;
wire                             i_hamming_sign3_T     ;
wire       [4:0]                 i_hamming_index3_T    ;


assign {i_hamming_sign0    ,
        i_hamming_index0   ,
        i_hamming_sign1    ,
        i_hamming_index1   ,
        
        i_hamming_sign0_T  ,
        i_hamming_index0_T ,
        i_hamming_sign1_T  ,
        i_hamming_index1_T ,
        i_hamming_sign2_T  ,
        i_hamming_index2_T ,
        i_hamming_sign3_T  ,
        i_hamming_index3_T } = i_t[35:0];


assign o_res = {xy_d9[2*MAX_BW-1:MAX_BW],res} ;//sp改   
assign o_valid = valid[3];

//-----------------------------------------------------------------------------------------


reg [15:0] valid=0;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        valid<=0;
    else
        valid<={valid[14:0],i_valid};
end

reg [2*MAX_BW-1:0] 
xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10; 

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        {
            xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10
        }
        <=0;
    else
        {
            xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9, xy_d10
        }
        <=
        {
            i_xy, xy_d1, xy_d2, xy_d3, xy_d4, xy_d5, xy_d6, xy_d7, xy_d8, xy_d9
        };
end
//----------------------------------------------------------------------------------------

wire    [MAX_BW:0]  ah; 
assign ah = i_mode ? 0:(i_xy[2*MAX_BW-1:MAX_BW-1]); // >> (l+1) //sp改

//--------------------------------upper half multiplier-----------------------------------   

reg     [MAX_BW:0]              ah_d1,   ah_d2, ah_d3, ah_d4                ;      

reg     [2*(MAX_BW+1)-1:0]      temp0,  temp1,  temp2, temp3,  temp4        ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        {ah_d1,ah_d2,ah_d3,ah_d4}<=0;
    else
        {ah_d1,ah_d2,ah_d3,ah_d4}<={ah,ah_d1,ah_d2,ah_d3};
end

always@(*)
begin
    if(!rst_n)
        temp0=0;
    else    
        temp0=( ah << (MAX_BW+1) );
end

always@(*) 
begin
    if(i_hamming_sign0_T)
        temp1=temp0-( ah << i_hamming_index0_T );       
    else
        temp1=temp0+( ah << i_hamming_index0_T );
end

always@(*) 
begin
    if(i_hamming_sign1_T)
        temp2=temp1-( ah << i_hamming_index1_T );    
    else
        temp2=temp1+( ah << i_hamming_index1_T );
end

always@(*) 
begin
    if(i_hamming_sign2_T)
        temp3=temp2-( ah << i_hamming_index2_T );       
    else
        temp3=temp2+( ah << i_hamming_index2_T );
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        temp4<=0;
    else if(i_hamming_sign3_T)
        temp4<=temp3-( ah << i_hamming_index3_T );    
    else
        temp4<=temp3+( ah << i_hamming_index3_T );
end


wire    [MAX_BW:0]  uh_out_high ; // high l+1 bits
assign uh_out_high = temp4[2*MAX_BW+2-1:MAX_BW+1]; // >> (l+1)

//--------------------------------lower half multiplier----------------------------------

wire    [MAX_BW:0]  al; 
assign al = uh_out_high;
wire    [MAX_BW:0]      lh_out_low; //low l+1 bits

reg     [MAX_BW:0]              al_d1,   al_d2                ;  
reg     [2*(MAX_BW+1)-1:0]      temp5,  temp6,  temp7         ;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        {al_d1,al_d2}<=0;
    else
        {al_d1,al_d2}<={al,al_d1};
end

always@(*)
begin   
        temp5=al+( al << (MAX_BW-1) );
end

always@(*) 
begin
    if(i_hamming_sign0)
        temp6=temp5-( al << i_hamming_index0 );       
    else
        temp6=temp5+( al << i_hamming_index0 );
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
        temp7 <= 0;
    else if(i_hamming_sign1)
        temp7<=temp6-( al << i_hamming_index1 );    
    else
        temp7<=temp6+( al << i_hamming_index1 );
end


assign lh_out_low = temp7[MAX_BW:0];

reg    [MAX_BW:0]   sub1    = 0 ; //这个减法是不是signed存疑,已经扩了一位
reg    [MAX_BW:0]   sub1_d1 = 0 ; 

//
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)  
        sub1<=0;
    else
        sub1<=xy_d2[MAX_BW:0]-lh_out_low;////sp改
end


reg  signed  [MAX_BW+1:0]   sub2    = 0 ; 

always@(*)
begin
     sub2=$signed({1'b0,sub1})-$signed({2'b0,i_q});
end

reg     [MAX_BW-1:0]      res;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        res<=0;
    else if(sub2[MAX_BW+1] || i_mode) //mux选择信号,sp改
        res<=sub1;
    else
        res<=sub2;
end


endmodule