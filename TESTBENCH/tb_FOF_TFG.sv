`timescale 1ns/1ps

module automatic tb_FOF_TFG();

parameter MAX_BW = 62;
parameter PIPELINE_CC = 7;
parameter n = 16;

logic               clk     = 0 ;
logic               rst     = 0 ; 
logic               i_valid = 0 ;
logic [MAX_BW-1:0]  i_phi   = 0 ;
logic [MAX_BW-1:0]  i_q     = 0 ;
logic [MAX_BW  :0]  i_t     = 0 ;
logic [3       :0]  i_log2N = 0 ;

initial
begin
    test_FOF_TFG();
end

always #5 clk = ~clk;

task automatic test_FOF_TFG();
begin
 fork
    begin:initial_process
        logic [7:0] l;
        i_q = 62'd2305843009221820417;
        l = $clog2(i_q);
        
        i_t = ( 128'b1<<(2*l) )/i_q;
        
        i_t = 0;
        i_t[35:0] = {1'b0,5'd23,1'b1,5'd18,1'b1,5'd25,1'b0,5'd20,1'b1,5'd1,1'b1,5'd1};
        
        i_log2N = 16-1;
        i_phi = 2;
        i_valid = 0;
        rst = 0;
    end

    begin:driven
        #100;
        rst = 1;
        @(negedge clk)
            i_valid = 1;
            #5;
        @(negedge clk)
            i_valid = 0;
        #10000;
//        $finish;
    end
 join
end
endtask


//---------------------------------------DUT-------------------------------------
wire                    o_valid ;
wire [n*MAX_BW-1:0]     o_tfg   ;

FOF_TFG#(
    .PIPELINE_CC ( PIPELINE_CC      ),
    .MAX_BW      ( MAX_BW           ),
    .n           ( n                )
)u_FOF_TFG(
    .clk         ( clk         ),
    .rst         ( rst         ),
    .i_valid     ( i_valid     ),
    .i_phi       ( i_phi       ),
    .i_q         ( i_q         ),
    .i_t         ( i_t         ),
    .i_log2N     ( i_log2N     ),
    .o_valid     ( o_valid     ),
    .o_tfg       ( o_tfg       )
);

// 文件写入逻辑
integer file;
integer i;
logic [MAX_BW-1:0] tfg_data;

always @(posedge clk) begin
    if (o_valid) begin
        // 打开文件，文件名为 "output.txt"
        file = $fopen("output.txt", "a"); // "a" 表示追加模式
        // 分割 o_tfg 并写入文件
        for (i = 0; i < n; i = i + 1) begin
            tfg_data = o_tfg[i*MAX_BW +: MAX_BW]; // 获取每个 62-bit 数据
            if (i == n-1) // 最后一个数后不加逗号
                $fwrite(file, "%0d", tfg_data);
            else
                $fwrite(file, "%0d,", tfg_data);
        end
        $fwrite(file, "\n");
        // 关闭文件
        $fclose(file);
    end
end

endmodule