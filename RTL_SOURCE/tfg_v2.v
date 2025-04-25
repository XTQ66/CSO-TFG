`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/25 10:22:03
// Design Name: 
// Module Name: tfg_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: tfg只包含计算资源，引出mux控制信号的版本，与visio电路完全一致。n+1选一的mux
//index = 0时，乘数为1。
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "define.vh"

(* USE_DSP= "no" *)  module tfg
#(
    parameter MAX_BW = 62,
    parameter n = 16, //例化的BFU个数，
    parameter PIPELINE_CC = 8
)
(
    input                           clk                 ,
    input                           rst_n               ,
    //MUX控制信号
    input       [n-1:0]             i_input_ff_mux      ,//n个二选一mux
    input                           i_output_ff_initial ,
    input       [n-1:0]             i_output_ff_mux     ,//n个二选一mux
    input       [$clog2(n):0]       i_tfseed_mux        ,//一个(n+1)选一mux，0表示选择1，其他为按顺序n个tfseed
    input                                  i_po_en             ,
    input       [PIPELIEN_CC_PO-1:0]       i_po_ff_mux         ,
    input       [$clog2(PIPELIEN_CC_PO):0] i_poseed_mux        ,
    //
    input       [MAX_BW-1:0]        i_q                 , 
    input       [MAX_BW:0]          i_t                 ,
    //
    input                           i_orginal_tf_valid  ,//pulse
    input       [MAX_BW-1:0]        i_orginal_tf        ,
    //
    input                                  i_valid      ,
    output                                 o_valid      ,
    output      [n*MAX_BW-1:0]             o_tfg               
        
);

localparam PIPELIEN_CC_PO = PIPELINE_CC + 1;
localparam   MM_PIPELINE_CC = PIPELINE_CC ;

assign o_valid = valid[MM_PIPELINE_CC-1];
genvar z;
generate
    for(z=0;z<n;z=z+1)
    begin: gen_o_tfg
        assign o_tfg[MAX_BW*z +: MAX_BW] = output_ff[z];
    end
endgenerate


//------------------------------------------------------------------------------------

reg [70:0] valid;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        valid<=0;
    else
        valid[70:0]<={valid[69:0],i_valid};
end


//----------------------------------------输入FF--------------------------------------

reg     [MAX_BW:0]       input_ff         [n:0] ; 

genvar u;
generate
    for(u=0;u<n+1;u=u+1)
    begin: gen_input_mux_ff
        if(u==0)
        begin
            always@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    input_ff[u]<=0;
                else if(i_orginal_tf_valid)
                    input_ff[u]<=i_orginal_tf;
                else if(i_input_ff_mux[u])
                    input_ff[u]<=output_ff[u];
                else
                    input_ff[u]<=input_ff[u];
            end
        end
        else if(u<n)
        begin
            always@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    input_ff[u]<=0;
                else if(i_input_ff_mux[u])
                    input_ff[u]<=barret_out[u][MAX_BW-1:0];
                else
                    input_ff[u]<=input_ff[u];
            end
        end
        else
        begin
            always@(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                    input_ff[u]<=0;
                else
                    input_ff[u]<=1;
            end
        end
    end
endgenerate


//----------------------------------------n+1选1mux-----------------------------------
wire     [MAX_BW-1:0]       tf_seed_mux       ;

assign tf_seed_mux = input_ff[i_tfseed_mux];

//---------------------------------------PO ff--------------------------------------
reg     [MAX_BW:0]       po_ff         [PIPELIEN_CC_PO:0] ; 

genvar p;
generate
    for(p=0;p<PIPELIEN_CC_PO+1;p=p+1)
    begin
        if(p==PIPELIEN_CC_PO)
            begin
                always@(posedge clk or negedge rst_n)
                begin
                    if(!rst_n)
                        po_ff[p]<=0;
                     else
                        po_ff[p]<=1;
                end
            end
         else
            begin
                always@(posedge clk or negedge rst_n)
                begin
                    if(!rst_n)
                        po_ff[p]<=0;
                     else if(i_po_ff_mux[p])
                        po_ff[p]<=output_ff[p];
                     else
                        po_ff[p]<=po_ff[p];
                end
            end
    end
endgenerate

//----------------------------------------n+1选1mux-----------------------------------
wire     [MAX_BW-1:0]       po_seed_mux       ;

assign po_seed_mux = po_ff[i_poseed_mux]       ;

//----------------------------------------乘法器\乘法器输入输出MUX\BARRET\输出FF+MUX--------------------------------------


wire [MAX_BW-1:0]       multipier_A   [n-1:0] ;
wire [MAX_BW-1:0]       multipier_B   [n-1:0] ;
wire [2*MAX_BW-1:0]     multipier_P   [n-1:0] ;


wire [2*MAX_BW-1:0] barret_out    [n-1:0] ;//1+18+39=58 Clock Cycle
wire        [n-1:0] barret_valid          ;

reg     [MAX_BW-1:0]       output_ff         [n-1:0] ;

genvar j;
generate
for(j=0;j<n;j=j+1)
    begin: gen_tfg_mm_mux_ff

    assign multipier_A[j] = output_ff[j];
    assign multipier_B[j] = i_po_en ? po_seed_mux : tf_seed_mux;
    
    `ifdef TFG_USE_KARATSUBER
        if(j < `NO_DSP_NUM) begin
        (* dont_touch = "true" *) karatsuba_multiply_62_no_dsp u_karatsuba_multiply_62(
            .clk        (clk                ),
            .x          ( multipier_A[j]    ),
            .y          ( multipier_B[j]    ),
            .product    ( multipier_P[j]    )
        ); end
        else begin
        (* dont_touch = "true" *) karatsuba_multiply_62 u_karatsuba_multiply_62(
            .clk        (clk                ),
            .x          ( multipier_A[j]    ),
            .y          ( multipier_B[j]    ),
            .product    ( multipier_P[j]    )
        ); 
        end
    `else
        mult_gen_0  tfg_multipier(
        .CLK(clk),  // input wire CLK
        .A(multipier_A[j]),      // input wire [61 : 0] A
        .B(multipier_B[j]),      // input wire [61 : 0] B
        .P(multipier_P[j])      // output wire [123 : 0] P，pipeline stages = 18;
    );
    `endif
    
    barret_sp#(
       .MAX_BW ( MAX_BW )
    )tfg_barret_sp(
       .clk    ( clk                 ),
       .rst_n  ( rst_n               ),
       .i_valid( 1'b1                ),
       .i_mode ( 1'b0                ),
       .i_xy   ( multipier_P[j]      ),
       .i_q    ( i_q                 ),
       .i_t    ( i_t                 ),
       .o_valid( barret_valid[j]     ),
       .o_res  ( barret_out[j]       )
    );

    
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            output_ff[j]<=0;
        else if(i_output_ff_initial)
            output_ff[j]<=tf_seed_mux;
        else if(i_output_ff_mux[j])
            output_ff[j]<=barret_out[j][MAX_BW-1:0];
        else
            output_ff[j]<=output_ff[j];
    end

    end
    
endgenerate
//-----------------------------------------------------------------------------------


endmodule
