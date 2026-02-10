`timescale 1ns / 1ps

module combiner_VOQ
#(
    // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=1024,
    parameter C_S_AXIS_DATA_WIDTH=1024,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128
)
(
    input axis_aclk,
    input axis_resetn,

    // Master Stream Ports (interface to data path)
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
    output m_axis_tvalid,
    input  m_axis_tready,
    output m_axis_tlast,

    // Slave Stream Ports (interface to RX queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    input  s_axis_tvalid,
    output reg s_axis_tready,
    input  s_axis_tlast,
    
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_mem_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_mem_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_mem_tuser,
    input  s_axis_mem_tvalid,
    output reg s_axis_mem_tready,
    input  s_axis_mem_tlast

);

  localparam NUM_STATES = 1;
  localparam IDLE = 0;
  localparam WR_PKT = 1;
  
  wire                                  nearly_full;
  wire                                  empty;
  reg [C_M_AXIS_DATA_WIDTH-1:0]         in_tdata;
  reg [((C_M_AXIS_DATA_WIDTH/8))-1:0]   in_tkeep;
  reg [C_M_AXIS_TUSER_WIDTH-1:0]        in_tuser;
  reg  	                                in_tvalid;
  reg                                   in_tlast;
  wire [C_M_AXIS_TUSER_WIDTH-1:0]       out_tuser;
  wire [C_M_AXIS_DATA_WIDTH-1:0]        out_tdata;
  wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  out_tkeep;
  wire  	                            out_tlast;
  wire                                  rd_en;
  wire                                  wr_en;
  
  reg                                   state;
  reg                                   state_next;
  
 fallthrough_small_fifo
       #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_TUSER_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
          .MAX_DEPTH_BITS(4))
     fifo
       (// Outputs
        .dout                           ({out_tlast, out_tuser, out_tkeep, out_tdata}),
        .full                           (),
        .nearly_full                    (nearly_full),
        .prog_full                      (),
        .empty                          (empty),
        // Inputs
        .din                            ({in_tlast, in_tuser, in_tkeep, in_tdata}),
        .wr_en                          (wr_en),
        .rd_en                          (rd_en),
        .reset                          (~axis_resetn),
        .clk                            (axis_aclk));
     
  assign m_axis_tuser = out_tuser;
  assign m_axis_tdata = out_tdata;
  assign m_axis_tlast = out_tlast;
  assign m_axis_tkeep = out_tkeep;
  assign m_axis_tvalid = ~empty;
  assign rd_en = m_axis_tready & !empty;
  assign wr_en = in_tvalid & !nearly_full;
  
   always @(*) begin
     state_next = state;
     in_tdata = s_axis_tdata;
     in_tkeep = s_axis_tkeep;
     in_tuser = s_axis_tuser;
     in_tvalid = s_axis_tvalid;
     in_tlast = s_axis_tuser[32];
     
     s_axis_tready = !nearly_full;
     s_axis_mem_tready = 1'b0;

     case(state)

       IDLE: begin
         in_tdata = s_axis_tdata;
         in_tkeep = s_axis_tkeep;
         in_tuser = s_axis_tuser;
         in_tvalid = s_axis_tvalid;
         in_tlast = s_axis_tuser[32];
         
         s_axis_tready = !nearly_full;
         s_axis_mem_tready = 1'b0;
         
         if(in_tvalid & !nearly_full & in_tlast) begin
            state_next = IDLE;
         end
         else if(in_tvalid & !nearly_full) begin
            state_next = WR_PKT;
         end
       end

       WR_PKT: begin
         in_tdata = s_axis_mem_tdata;
         in_tkeep = s_axis_mem_tkeep;
         in_tuser = s_axis_mem_tuser;
         in_tvalid = s_axis_mem_tvalid;
         in_tlast = s_axis_mem_tlast;
         
         s_axis_tready = 1'b0;
         s_axis_mem_tready = !nearly_full;
         
         if(in_tvalid & !nearly_full & in_tlast) begin
            state_next = IDLE;
          end
          else if (in_tvalid & !nearly_full) begin
            state_next = WR_PKT;
          end
       end // case: WR_PKT

     endcase // case(state)
  end // always @ (*)

  always @(posedge axis_aclk) begin
     if(~axis_resetn) begin
        state <= IDLE;
     end
     else begin
        state <= state_next;
     end
  end

endmodule

