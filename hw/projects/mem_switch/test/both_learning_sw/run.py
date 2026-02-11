#!/usr/bin/env python3

#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Neelakandan Manihatty Bojan, Georgina Kalogeridou
# All rights reserved.
#
# This software was developed by Stanford University and the University of Cambridge Computer Laboratory 
# under National Science Foundation under Grant No. CNS-0855268,
# the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
# by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"), 
# as part of the DARPA MRC research programme,
# and by the University of Cambridge Computer Laboratory under EPSRC EARL Project
# EP/P025374/1 alongside support from Xilinx Inc.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#
# Author:
#        Modified by Neelakandan Manihatty Bojan, Georgina Kalogeridou

import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

from NFTest import *
import sys
import os
from scapy.layers.all import Ether, IP, TCP
from reg_defines_mem_switch import *

phy2loop0 = ('../connections/conn', [])
nftest_init(sim_loop = [], hw_config = [phy2loop0])


if isHW():
   # Clearing the LUT_HIT and LUT_MISS by asserting the reset_counters
   nftest_regwrite(NFPLUS_INPUT_ARBITER_0_RESET(), 0x1)
   nftest_regwrite(NFPLUS_OUTPUT_PORT_LOOKUP_0_RESET(), 0x101)
   nftest_regwrite(NFPLUS_OUTPUT_QUEUES_0_RESET(), 0x1)

   # Reset the switch table lookup counters (value is reset every time is read)
   nftest_regread(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTHIT())
   nftest_regread(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTMISS())

nftest_start()


routerMAC = []
routerIP = []
for i in range(4):
    routerMAC.append("00:0a:35:03:00:0%d"%(i+1))
    routerIP.append("192.168.%s.40"%i)

num_broadcast = 10

pkts0 = []
pkts1 = []
pkts2 = []
pkts3 = []
pkts0e = []
pkts1e = []
pkts2e = []
pkts3e = []
pktsa = []
pktsb = []
pktsc = []
pktsd = []

for i in range(num_broadcast):
    pkt0 = make_IP_pkt(src_MAC=routerMAC[0], dst_MAC="aa:bb:cc:dd:ee:ff",
                      src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=128)

    pkt0.time = 2e-6
    pkts0.append(pkt0)
    pkts1e.append(pkt0)
    pkts2e.append(pkt0)
    pkts3e.append(pkt0)

for i in range(num_broadcast):
    pkt1 = make_IP_pkt(src_MAC=routerMAC[1], dst_MAC="aa:bb:cc:dd:ee:ff",
                      src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=512)

    pkt1.time = ((5e-7) + (2e-6))
    pkts1.append(pkt1)
    pkts0e.append(pkt1)
    pkts2e.append(pkt1)
    pkts3e.append(pkt1)

for i in range(num_broadcast):
    pkt2 = make_IP_pkt(src_MAC=routerMAC[2], dst_MAC="aa:bb:cc:dd:ee:ff",
                      src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=1024)

    pkt2.time = ((10e-7) + (2e-6))
    pkts2.append(pkt2)
    pkts0e.append(pkt2)
    pkts1e.append(pkt2)
    pkts3e.append(pkt2)

for i in range(num_broadcast):
    pkt3 = make_IP_pkt(src_MAC=routerMAC[3], dst_MAC="aa:bb:cc:dd:ee:ff",
                      src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=256)

    pkt3.time = ((15e-7) + (2e-6))
    pkts3.append(pkt3)
    pkts0e.append(pkt3)
    pkts1e.append(pkt3)
    pkts2e.append(pkt3)

if not isHW():
    nftest_send_phy('nf0', pkts0)
    nftest_send_phy('nf1', pkts1)
    nftest_send_phy('nf2', pkts2)
    nftest_send_phy('nf3', pkts3)
    nftest_expect_phy('nf0', pkts0e)
    nftest_expect_phy('nf1', pkts1e)
    nftest_expect_phy('nf2', pkts2e)
    nftest_expect_phy('nf3', pkts3e)

#nftest_barrier()


num_normal = 50

for i in range(num_normal):
    pkta = make_IP_pkt(src_MAC=routerMAC[0], dst_MAC=routerMAC[1],
                     src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=512)
    pkta.time = ((25e-7) + (2e-6))
    pktsa.append(pkta)

    pktb = make_IP_pkt(src_MAC=routerMAC[1], dst_MAC=routerMAC[2],
                     src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=512)
    pktb.time = ((25e-7) + (2e-6))
    pktsb.append(pktb)

    pktc = make_IP_pkt(src_MAC=routerMAC[2], dst_MAC=routerMAC[3],
                     src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=512)
    pktc.time = ((25e-7) + (2e-6))
    pktsc.append(pktc)

    pktd = make_IP_pkt(src_MAC=routerMAC[3], dst_MAC=routerMAC[0],
                     src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=512)
    pktd.time = ((25e-7) + (2e-6))
    pktsd.append(pktd)

if not isHW():
    nftest_send_phy('nf0', pktsa)
    nftest_send_phy('nf1', pktsb)
    nftest_send_phy('nf2', pktsc)
    nftest_send_phy('nf3', pktsd)
    nftest_expect_phy('nf0', pktsd)
    nftest_expect_phy('nf1', pktsa)
    nftest_expect_phy('nf2', pktsb)
    nftest_expect_phy('nf3', pktsc)

nftest_barrier()

if isHW():
    # Now we expect to see the lut_hit and lut_miss registers incremented and we
    # verify this by doing a regread_expect
    rres1= nftest_regread_expect(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTHIT(), num_normal)
    rres2= nftest_regread_expect(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTMISS(), num_broadcast)
    # List containing the return values of the reg_reads
    mres=[rres1,rres2]
else:
    nftest_regread_expect(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTHIT(), num_normal) # lut_hit
    nftest_regread_expect(NFPLUS_OUTPUT_PORT_LOOKUP_0_LUTMISS(), num_broadcast) # lut_miss
    mres=[]

nftest_finish(mres)
