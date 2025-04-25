

module FOF_TFG 
#(
    parameter PIPELINE_CC = 8,
    parameter MAX_BW = 62,
    parameter n = 16 
)
(
    input                           clk,
    input                           rst,
    input                       i_valid,
    input    [MAX_BW-1:0]       i_phi  ,
    input    [MAX_BW-1:0]       i_q    ,
    input    [MAX_BW:0]         i_t    ,
    input    [3:0]              i_log2N,
    output                      o_valid,
    output   [n*MAX_BW-1:0]     o_tfg   

);
assign o_valid = FTC_valid;
localparam PIPELIEN_CC_PO = PIPELINE_CC + 1;    

wire       [n-1:0]                    FTC_input_ff_mux      ;//n个二选一mux
wire                                  FTC_output_ff_initial ;//STF初始�?
wire       [n-1:0]                    FTC_output_ff_mux     ;//n个二选一mux
wire       [$clog2(n):0]              FTC_tfseed_mux        ;//�?�?(n+1)选一mux�?0表示选择1，其他为按顺序n个tfseed wire
wire                                  FTC_valid             ;//�?始正式输出TFG
wire                                  FTC_po_en             ;
wire       [PIPELIEN_CC_PO-1:0]       FTC_po_ff_mux         ;
wire       [$clog2(PIPELIEN_CC_PO):0] FTC_poseed_mux        ;
    
FOF_TFG_Ctrl#(
    .PIPELINE_CC          ( PIPELINE_CC ),
    .n                    ( n           )
)u_FOF_TFG_Ctrl(
    .clk                  ( clk                    ),
    .rst                  ( rst                    ),
    .i_valid              ( i_valid                ),
    .i_log2N              ( i_log2N                ),
    .o_input_ff_mux       ( FTC_input_ff_mux       ),
    .o_output_ff_initial  ( FTC_output_ff_initial  ),
    .o_output_ff_mux      ( FTC_output_ff_mux      ),
    .o_tfseed_mux         ( FTC_tfseed_mux         ),
    .o_po_en              ( FTC_po_en              ),
    .o_po_ff_mux          ( FTC_po_ff_mux          ),
    .o_poseed_mux         ( FTC_poseed_mux         ),
    .o_valid              ( FTC_valid              )
);

wire o_tfg_valid;

tfg#(
    .MAX_BW               ( MAX_BW           ),
    .n                    ( n                ),
    .PIPELINE_CC          ( PIPELINE_CC      )
)u_tfg(
    .clk                  ( clk                    ),
    .rst_n                ( rst                    ),
    .i_input_ff_mux       ( FTC_input_ff_mux       ),
    .i_output_ff_initial  ( FTC_output_ff_initial  ),
    .i_output_ff_mux      ( FTC_output_ff_mux      ),
    .i_tfseed_mux         ( FTC_tfseed_mux         ),
    .i_po_en              ( FTC_po_en              ),
    .i_po_ff_mux          ( FTC_po_ff_mux          ),
    .i_poseed_mux         ( FTC_poseed_mux         ),
    .i_q                  ( i_q                    ),
    .i_t                  ( i_t                    ),
    .i_orginal_tf_valid   ( i_valid                ),
    .i_orginal_tf         ( i_phi                  ),
    .i_valid              ( FTC_valid              ),
    .o_valid              ( o_tfg_valid            ),
    .o_tfg                ( o_tfg                  )
);





endmodule