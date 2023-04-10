----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2023 10:46:22 PM
-- Design Name: 
-- Module Name: control_path - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_path is
Port (
-- sinhronizacija
clk : in std_logic;
reset : in std_logic;
-- instrukcija dolazi iz datapah-a
instruction_i : in std_logic_vector (31 downto 0);
-- Statusni signaln iz datapath celine
branch_condition_i : in std_logic;
-- kontrolni signali koji se prosledjiuju u datapath
mem_to_reg_o : out std_logic;
alu_op_o : out std_logic_vector(4 downto 0);
alu_src_b_o : out std_logic;
rd_we_o : out std_logic;
pc_next_sel_o : out std_logic;
data_mem_we_o : out std_logic_vector(3 downto 0);
-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
alu_forward_a_o : out std_logic_vector (1 downto 0);
alu_forward_b_o : out std_logic_vector (1 downto 0);
branch_forward_a_o : out std_logic; -- mux a
branch_forward_b_o : out std_logic; -- mux b
-- kontrolni signal za resetovanje if/id registra
if_id_flush_o : out std_logic;
-- kontrolni signali za zaustavljanje protocne obrade
pc_en_o : out std_logic;
if_id_en_o : out std_logic
);
end control_path;

architecture Behavioral of control_path is
-- signali ID faza
 signal mem_to_reg_id_s, rd_we_id_s, alu_src_b_id_s : std_logic;
 signal branch_id_s, rs1_in_use_id_s, rs2_in_use_id_s, control_pass : std_logic;
 signal alu_2bit_op_id_s, data_mem_we_id_s : std_logic_vector(1 downto 0);
 -- signali EX faza
 signal funct3_ex_s : std_logic_vector(2 downto 0);
 signal funct7_ex_s : std_logic_vector(6 downto 0);
 signal alu_2bit_op_ex_s, data_mem_we_ex_s : std_logic_vector(1 downto 0);
 signal mem_to_reg_ex_s, rd_we_ex_s : std_logic;
 signal rs1_address_ex_s, rs2_address_ex_s, rd_address_ex_s : std_logic_vector(4 downto 0);
 -- signali MEM faza
 signal rd_we_mem_s : std_logic; 
 signal rd_address_mem_s : std_logic_vector(4 downto 0);
 signal mem_to_reg_mem_s : std_logic;
 signal data_mem_we_mem_s : std_logic_vector(1 downto 0);
 -- signali WB faza
 signal rd_we_wb_s : std_logic; 
 signal rd_address_wb_s : std_logic_vector(4 downto 0);
 

  
begin

ctrl_dec: entity work.ctrl_decoder
Port map(
opcode_i => instruction_i(6 downto 0),
funct3_i => instruction_i(14 downto 12),
branch_o => branch_id_s,
mem_to_reg_o => mem_to_reg_id_s,
data_mem_we_o => data_mem_we_id_s,
alu_src_b_o  => alu_src_b_id_s,
rd_we_o  => rd_we_id_s,
rs1_in_use_o => rs1_in_use_id_s,        
rs2_in_use_o => rs2_in_use_id_s,        
alu_2bit_op_o => alu_2bit_op_id_s
);

alu_dec: entity work.ALU_decoder
Port map(
alu_2bit_op_i => alu_2bit_op_ex_s,
funct3_i => funct3_ex_s,
funct7_i => funct7_ex_s,
alu_op_o => alu_op_o
);

forward: entity work.forwarding_unit
Port map(
rs1_address_id_i => instruction_i(19 downto 15),
rs2_address_id_i => instruction_i(24 downto 20),
rs1_address_ex_i => rs1_address_ex_s,
rs2_address_ex_i => rs2_address_ex_s,
rd_we_mem_i => rd_we_mem_s,
rd_address_mem_i => rd_address_mem_s,
rd_we_wb_i => rd_we_wb_s,
rd_address_wb_i => rd_address_wb_s,
alu_forward_a_o => alu_forward_a_o,
alu_forward_b_o => alu_forward_b_o,
branch_forward_a_o => branch_forward_a_o,
branch_forward_b_o => branch_forward_b_o
);

hazard: entity work.hazard_unit
Port map(
rs1_address_id_i => instruction_i(19 downto 15),
rs2_address_id_i => instruction_i(24 downto 20),
rs1_in_use_i => rs1_in_use_id_s,
rs2_in_use_i => rs2_in_use_id_s,
branch_id_i => branch_id_s,
rd_address_ex_i => rd_address_ex_s,
mem_to_reg_ex_i => mem_to_reg_ex_s,
rd_we_ex_i => rd_we_ex_s,
rd_address_mem_i => rd_address_mem_s,
mem_to_reg_mem_i => mem_to_reg_mem_s,
pc_en_o => pc_en_o,
if_id_en_o => if_id_en_o,
control_pass_o => control_pass
);

EX: process(clk)
begin
 if(rising_edge(clk)) then
 if(reset = '1') then
  if(control_pass = '0') then 
   mem_to_reg_ex_s <= '0';
   data_mem_we_ex_s <= "00";
   rd_we_ex_s <= '0';
   alu_src_b_o <= '0';
   alu_2bit_op_ex_s <= "00";
   funct3_ex_s <= "000";
   funct7_ex_s <= "0000000";
   rd_address_ex_s <= "00000";
   rs1_address_ex_s <= "00000";
   rs2_address_ex_s <= "00000";
  else
   mem_to_reg_ex_s <= mem_to_reg_id_s;
   data_mem_we_ex_s <= data_mem_we_id_s;
   rd_we_ex_s <= rd_we_id_s;
   alu_src_b_o <= alu_src_b_id_s;
   alu_2bit_op_ex_s <= alu_2bit_op_id_s;
   funct3_ex_s <= instruction_i(14 downto 12);
   funct7_ex_s <= instruction_i(31 downto 25);
   rd_address_ex_s <= instruction_i(11 downto 7);
   rs1_address_ex_s <= instruction_i(19 downto 15);
   rs2_address_ex_s <= instruction_i(24 downto 20);
  end if;
 else
   mem_to_reg_ex_s <= '0';
   data_mem_we_ex_s <= "00";
   rd_we_ex_s <= '0';
   alu_src_b_o <= '0';
   alu_2bit_op_ex_s <= "00";
   funct3_ex_s <= "000";
   funct7_ex_s <= "0000000";
   rd_address_ex_s <= "00000";
   rs1_address_ex_s <= "00000";
   rs2_address_ex_s <= "00000";
 end if; 
 end if; 
end process EX;

MEM: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '1') then
   mem_to_reg_mem_s <= mem_to_reg_ex_s;
   data_mem_we_mem_s <= data_mem_we_ex_s;
   rd_we_mem_s <= rd_we_ex_s;
   rd_address_mem_s <= rd_address_ex_s;
  else
   mem_to_reg_mem_s <= '0';
   data_mem_we_mem_s <= (others => '0');
   rd_we_mem_s <= '0';
   rd_address_mem_s <= (others => '0');  
  end if; 
 end if; 
end process MEM;

WB: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '1') then
   mem_to_reg_o <= mem_to_reg_mem_s;
   rd_we_wb_s <= rd_we_mem_s;
   rd_we_o <= rd_we_mem_s;
   rd_address_wb_s <= rd_address_mem_s;
  else
   mem_to_reg_o <= '0';
   rd_we_wb_s <= '0';
   rd_we_o <= '0';
   rd_address_wb_s <= (others => '0'); 
  end if; 
 end if; 
end process WB;

mem_we_mux: data_mem_we_o <= "0001" when data_mem_we_mem_s = "01" else
                             "0011" when data_mem_we_mem_s = "10" else
                             "1111" when data_mem_we_mem_s = "11" else
                             "0000";

branch_and:  if_id_flush_o <= branch_id_s and branch_condition_i;
             pc_next_sel_o <= branch_id_s and branch_condition_i;
             
             
end Behavioral;
