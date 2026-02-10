`timescale 1ns / 1ps

module combiner
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
    output s_axis_tready,
    input  s_axis_tlast,
    
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_mem_0_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_mem_0_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_mem_0_tuser,
    input  s_axis_mem_0_tvalid,
    output s_axis_mem_0_tready,
    input  s_axis_mem_0_tlast,
    
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_mem_1_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_mem_1_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_mem_1_tuser,
    input  s_axis_mem_1_tvalid,
    output s_axis_mem_1_tready,
    input  s_axis_mem_1_tlast,
    
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_mem_2_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_mem_2_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_mem_2_tuser,
    input  s_axis_mem_2_tvalid,
    output s_axis_mem_2_tready,
    input  s_axis_mem_2_tlast,
    
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_mem_3_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_mem_3_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_mem_3_tuser,
    input  s_axis_mem_3_tvalid,
    output s_axis_mem_3_tready,
    input  s_axis_mem_3_tlast
);

localparam SRC_PORT_POS = 16;

wire [3:0] in_tvalid;
wire [3:0] in_ready;

wire [C_S_AXIS_DATA_WIDTH - 1:0] mem_in_tdata [3:0];
wire [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] mem_in_tkeep [3:0];
wire [C_S_AXIS_TUSER_WIDTH-1:0] mem_in_tuser [3:0];
wire [3:0] mem_in_tvalid;
wire [3:0] mem_in_tready;
wire [3:0] mem_in_tlast;

wire [C_S_AXIS_DATA_WIDTH - 1:0] mem_out_tdata [3:0];
wire [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] mem_out_tkeep [3:0];
wire [C_S_AXIS_TUSER_WIDTH-1:0] mem_out_tuser [3:0];
wire [3:0] mem_out_tvalid;
wire [3:0] mem_out_tready;
wire [3:0] mem_out_tlast;

assign in_tvalid = {4{s_axis_tvalid}} & s_axis_tuser[SRC_PORT_POS+3:SRC_PORT_POS];
assign s_axis_tready = |(in_ready & s_axis_tuser[SRC_PORT_POS+3:SRC_PORT_POS]);

assign mem_in_tdata[0] = s_axis_mem_0_tdata;
assign mem_in_tkeep[0] = s_axis_mem_0_tkeep;
assign mem_in_tuser[0] = s_axis_mem_0_tuser;
assign mem_in_tvalid[0] = s_axis_mem_0_tvalid;
assign s_axis_mem_0_tready = mem_in_tready[0];
assign mem_in_tlast[0] =  s_axis_mem_0_tlast;

assign mem_in_tdata[1] = s_axis_mem_1_tdata;
assign mem_in_tkeep[1] = s_axis_mem_1_tkeep;
assign mem_in_tuser[1] = s_axis_mem_1_tuser;
assign mem_in_tvalid[1] = s_axis_mem_1_tvalid;
assign s_axis_mem_1_tready = mem_in_tready[1];
assign mem_in_tlast[1] =  s_axis_mem_1_tlast;

assign mem_in_tdata[2] = s_axis_mem_2_tdata;
assign mem_in_tkeep[2] = s_axis_mem_2_tkeep;
assign mem_in_tuser[2] = s_axis_mem_2_tuser;
assign mem_in_tvalid[2] = s_axis_mem_2_tvalid;
assign s_axis_mem_2_tready = mem_in_tready[2];
assign mem_in_tlast[2] =  s_axis_mem_2_tlast;

assign mem_in_tdata[3] = s_axis_mem_3_tdata;
assign mem_in_tkeep[3] = s_axis_mem_3_tkeep;
assign mem_in_tuser[3] = s_axis_mem_3_tuser;
assign mem_in_tvalid[3] = s_axis_mem_3_tvalid;
assign s_axis_mem_3_tready = mem_in_tready[3];
assign mem_in_tlast[3] =  s_axis_mem_3_tlast;

  generate
  genvar i;
  for(i=0; i<4; i=i+1) begin: VOQs
    combiner_VOQ
    #( .C_M_AXIS_DATA_WIDTH(C_M_AXIS_DATA_WIDTH),
       .C_S_AXIS_DATA_WIDTH(C_M_AXIS_DATA_WIDTH),
       .C_M_AXIS_TUSER_WIDTH(C_M_AXIS_TUSER_WIDTH),
       .C_S_AXIS_TUSER_WIDTH(C_S_AXIS_TUSER_WIDTH))
    combiner_VOQs
    (
      .axis_aclk(axis_aclk), 
      .axis_resetn(axis_resetn), 
      .m_axis_tdata (mem_out_tdata[i]), 
      .m_axis_tkeep (mem_out_tkeep[i]), 
      .m_axis_tuser (mem_out_tuser[i]), 
      .m_axis_tvalid(mem_out_tvalid[i]), 
      .m_axis_tready(mem_out_tready[i]), 
      .m_axis_tlast (mem_out_tlast[i]),
      
      .s_axis_tdata (s_axis_tdata), 
      .s_axis_tkeep (s_axis_tkeep), 
      .s_axis_tuser (s_axis_tuser), 
      .s_axis_tvalid(in_tvalid[i]), 
      .s_axis_tready(in_ready[i]), 
      .s_axis_tlast (s_axis_tlast),
      
      .s_axis_mem_tdata (mem_in_tdata[i]), 
      .s_axis_mem_tkeep (mem_in_tkeep[i]), 
      .s_axis_mem_tuser (mem_in_tuser[i]), 
      .s_axis_mem_tvalid(mem_in_tvalid[i]), 
      .s_axis_mem_tready(mem_in_tready[i]), 
      .s_axis_mem_tlast (mem_in_tlast[i])
    );
  end
  endgenerate

  //Input Arbiter
  input_arbiter_ip  input_arbiter_v1_0 (
      .axis_aclk(axis_aclk), 
      .axis_resetn(axis_resetn), 
      .m_axis_tdata (m_axis_tdata), 
      .m_axis_tkeep ( m_axis_tkeep), 
      .m_axis_tuser (m_axis_tuser), 
      .m_axis_tvalid(m_axis_tvalid), 
      .m_axis_tready(m_axis_tready), 
      .m_axis_tlast (m_axis_tlast), 
      .s_axis_0_tdata (mem_out_tdata[0]), 
      .s_axis_0_tkeep (mem_out_tkeep[0]), 
      .s_axis_0_tuser (mem_out_tuser[0]), 
      .s_axis_0_tvalid(mem_out_tvalid[0]), 
      .s_axis_0_tready(mem_out_tready[0]), 
      .s_axis_0_tlast (mem_out_tlast[0]), 
      .s_axis_1_tdata (mem_out_tdata[1]), 
      .s_axis_1_tkeep (mem_out_tkeep[1]), 
      .s_axis_1_tuser (mem_out_tuser[1]), 
      .s_axis_1_tvalid(mem_out_tvalid[1]), 
      .s_axis_1_tready(mem_out_tready[1]), 
      .s_axis_1_tlast (mem_out_tlast[1]), 
      .s_axis_2_tdata (mem_out_tdata[2]), 
      .s_axis_2_tkeep (mem_out_tkeep[2]), 
      .s_axis_2_tuser (mem_out_tuser[2]), 
      .s_axis_2_tvalid(mem_out_tvalid[2]), 
      .s_axis_2_tready(mem_out_tready[2]), 
      .s_axis_2_tlast (mem_out_tlast[2]), 
      .s_axis_3_tdata (mem_out_tdata[3]), 
      .s_axis_3_tkeep (mem_out_tkeep[3]), 
      .s_axis_3_tuser (mem_out_tuser[3]), 
      .s_axis_3_tvalid(mem_out_tvalid[3]), 
      .s_axis_3_tready(mem_out_tready[3]), 
      .s_axis_3_tlast (mem_out_tlast[3]), 
      .S_AXI_AWADDR(), 
      .S_AXI_AWVALID(),
      .S_AXI_WDATA(),  
      .S_AXI_WSTRB(),  
      .S_AXI_WVALID(), 
      .S_AXI_BREADY(), 
      .S_AXI_ARADDR(), 
      .S_AXI_ARVALID(),
      .S_AXI_RREADY(), 
      .S_AXI_ARREADY(),
      .S_AXI_RDATA(),  
      .S_AXI_RRESP(),  
      .S_AXI_RVALID(), 
      .S_AXI_WREADY(), 
      .S_AXI_BRESP(),  
      .S_AXI_BVALID(), 
      .S_AXI_AWREADY(),
      .S_AXI_ACLK (), 
      .S_AXI_ARESETN()
    );

endmodule

