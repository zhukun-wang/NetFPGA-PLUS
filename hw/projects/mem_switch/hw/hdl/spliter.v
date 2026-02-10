`timescale 1ns/1ns

module spliter
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
    
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_mem_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_mem_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_mem_tuser,
    output m_axis_mem_tvalid,
    input  m_axis_mem_tready,
    output m_axis_mem_tlast,

    // Slave Stream Ports (interface to RX queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    input  s_axis_tvalid,
    output reg s_axis_tready,
    input  s_axis_tlast

);

  function integer log2;
     input integer number;
     begin
        log2=0;
        while(2**log2<number) begin
           log2=log2+1;
        end
     end
  endfunction // log2

  localparam NUM_STATES = 1;
  localparam IDLE = 0;
  localparam WR_PKT = 1;

  wire                                  header_nearly_full;
  wire                                  header_empty;
  wire [C_M_AXIS_DATA_WIDTH-1:0]        header_in_tdata;
  wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  header_in_tkeep;
  wire [C_M_AXIS_TUSER_WIDTH-1:0]       header_in_tuser;
  wire  	                            header_in_tvalid;
  wire                                  header_in_tlast;
  wire [C_M_AXIS_TUSER_WIDTH-1:0]       header_out_tuser;
  wire [C_M_AXIS_DATA_WIDTH-1:0]        header_out_tdata;
  wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  header_out_tkeep;
  wire  	                            header_out_tlast;
  wire                                  header_rd_en;
  reg                                   header_wr_en;
  
  wire                                  payload_nearly_full;
  wire                                  payload_empty;
  wire [C_M_AXIS_DATA_WIDTH-1:0]        payload_in_tdata;
  wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  payload_in_tkeep;
  wire [C_M_AXIS_TUSER_WIDTH-1:0]       payload_in_tuser;
  wire  	                            payload_in_tvalid;
  wire                                  payload_in_tlast;
  wire [C_M_AXIS_TUSER_WIDTH-1:0]       payload_out_tuser;
  wire [C_M_AXIS_DATA_WIDTH-1:0]        payload_out_tdata;
  wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  payload_out_tkeep;
  wire  	                            payload_out_tlast;
  wire                                  payload_rd_en;
  reg                                   payload_wr_en;
  
  reg                                   state;
  reg                                   state_next;

 fallthrough_small_fifo
       #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_TUSER_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
          .MAX_DEPTH_BITS(3))
     header_fifo
       (// Outputs
        .dout                           ({header_out_tlast, header_out_tuser, header_out_tkeep, header_out_tdata}),
        .full                           (),
        .nearly_full                    (header_nearly_full),
        .prog_full                      (),
        .empty                          (header_empty),
        // Inputs
        .din                            ({header_in_tlast, header_in_tuser, header_in_tkeep, header_in_tdata}),
        .wr_en                          (header_wr_en),
        .rd_en                          (header_rd_en),
        .reset                          (~axis_resetn),
        .clk                            (axis_aclk));

 fallthrough_small_fifo
       #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_TUSER_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
          .MAX_DEPTH_BITS(5))
     payload_fifo
       (// Outputs
        .dout                           ({payload_out_tlast, payload_out_tuser, payload_out_tkeep, payload_out_tdata}),
        .full                           (),
        .nearly_full                    (payload_nearly_full),
        .prog_full                      (),
        .empty                          (payload_empty),
        // Inputs
        .din                            ({payload_in_tlast, payload_in_tuser, payload_in_tkeep, payload_in_tdata}),
        .wr_en                          (payload_wr_en),
        .rd_en                          (payload_rd_en),
        .reset                          (~axis_resetn),
        .clk                            (axis_aclk));

  assign header_in_tdata        = s_axis_tdata;
  assign header_in_tkeep        = s_axis_tkeep;
  assign header_in_tuser        = {s_axis_tuser[C_M_AXIS_TUSER_WIDTH-1:33], s_axis_tlast, s_axis_tuser[31:0]};
  assign header_in_tvalid       = s_axis_tvalid;
  assign header_in_tlast        = 1'b1;
  
  assign payload_in_tdata        = s_axis_tdata;
  assign payload_in_tkeep        = s_axis_tkeep;
  assign payload_in_tuser        = s_axis_tuser;
  assign payload_in_tvalid       = s_axis_tvalid;
  assign payload_in_tlast        = s_axis_tlast;
 
  assign m_axis_tuser = header_out_tuser;
  assign m_axis_tdata = header_out_tdata;
  assign m_axis_tlast = header_out_tlast;
  assign m_axis_tkeep = header_out_tkeep;
  assign m_axis_tvalid = ~header_empty;
  assign header_rd_en = m_axis_tready & !header_empty;
  
  assign m_axis_mem_tuser = payload_out_tuser;
  assign m_axis_mem_tdata = payload_out_tdata;
  assign m_axis_mem_tlast = payload_out_tlast;
  assign m_axis_mem_tkeep = payload_out_tkeep;
  assign m_axis_mem_tvalid = ~payload_empty;
  assign payload_rd_en = m_axis_mem_tready & !payload_empty;
  
   always @(*) begin
     state_next      = state;
     header_wr_en    = s_axis_tready & s_axis_tvalid;
     payload_wr_en   = 0;
     s_axis_tready   = !header_nearly_full;

     case(state)

       IDLE: begin
         s_axis_tready = !header_nearly_full;
         header_wr_en = s_axis_tready & s_axis_tvalid;
         payload_wr_en = 1'b0;
         
         if(s_axis_tvalid & s_axis_tready & s_axis_tlast) begin
            state_next = IDLE;
         end
         else if(s_axis_tvalid & s_axis_tready) begin
            state_next = WR_PKT;
         end
       end

       WR_PKT: begin
         s_axis_tready = !payload_nearly_full;
         header_wr_en = 1'b0;
         payload_wr_en = s_axis_tready & s_axis_tvalid;
         
         if(s_axis_tvalid & s_axis_tready & s_axis_tlast) begin
            state_next = IDLE;
          end
          else if (s_axis_tvalid & s_axis_tready) begin
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

