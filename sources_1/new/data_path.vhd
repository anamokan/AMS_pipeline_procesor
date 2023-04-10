----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 12:21:04 PM
-- Design Name: 
-- Module Name: data_path - Behavioral
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

entity data_path is
Port(
-- sinhronizacioni signali
clk : in std_logic;
reset : in std_logic;
-- interfejs ka memoriji za instrukcije
instr_mem_address_o : out std_logic_vector (31 downto 0);
instr_mem_read_i : in std_logic_vector(31 downto 0);
instruction_o : out std_logic_vector(31 downto 0);  -- ovo je ka control path, a ne ka instr memory
-- interfejs ka memoriji za podatke
data_mem_address_o : out std_logic_vector(31 downto 0);
data_mem_write_o : out std_logic_vector(31 downto 0);
data_mem_read_i : in std_logic_vector (31 downto 0);
-- kontrolni signali
mem_to_reg_i : in std_logic;
alu_op_i : in std_logic_vector (4 downto 0);
alu_src_b_i : in std_logic;
pc_next_sel_i : in std_logic;
rd_we_i : in std_logic;
branch_condition_o : out std_logic;
-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
alu_forward_a_i : in std_logic_vector (1 downto 0);
alu_forward_b_i : in std_logic_vector (1 downto 0);
branch_forward_a_i : in std_logic;
branch_forward_b_i : in std_logic;
-- kontrolni signal za resetovanje if/id registra
if_id_flush_i : in std_logic;
-- kontrolni signali za zaustavljanje protocne obrade
pc_en_i : in std_logic;
if_id_en_i : in std_logic
);
end data_path;

architecture Behavioral of data_path is
-- signali za PC
 signal pc_out : std_logic_vector(31 downto 0);
 signal pc_in, pc_adder_out : std_logic_vector(31 downto 0);  

 signal a, b, result : std_logic_vector(31 downto 0);   -- ulazni i izlazni signali za ALU
 signal b_pom : std_logic_vector(31 downto 0);    -- signal za 2.mux pred ALU
 signal imm_extended : std_logic_vector(31 downto 0);          --  izlazni signali za imm, instr je izaslo iz IDIF
 signal rd_reg_data, rs1_reg_data, rs2_reg_data : std_logic_vector(31 downto 0);  -- data signali za reg bank
 signal eq_a, eq_b : std_logic_vector(31 downto 0);    -- signali za muxeve pred komparator
 signal add_exit : std_logic_vector(31 downto 0);  -- signali za adder

-- izlazni signali IFID registra
 signal instr_IFID, pc_out_IFID : std_logic_vector(31 downto 0);
 --add_exit_IFID : std_logic_vector(31 downto 0);
 
 -- izlazni signali IDEX registra
 signal rs1_data_IDEX, rs2_data_IDEX, data_i_IDEX : std_logic_vector(31 downto 0);  
 signal imm_extended_IDEX : std_logic_vector(31 downto 0);
 signal rd_address_IDEX : std_logic_vector(4 downto 0);
 -- izlazni signali EXMEM registra
 signal alu_result_EXMEM : std_logic_vector(31 downto 0);
 signal rd_address_EXMEM : std_logic_vector(4 downto 0);
 -- izlazni signali MEMWB registra
 signal alu_result_MEMWB, data_o_MEMWB : std_logic_vector(31 downto 0);
 signal rd_address_MEMWB : std_logic_vector(4 downto 0);


begin

PC: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '0') then   
     pc_out <= (others => '0');
  else               
     if(pc_en_i = '1') then
     pc_out <= pc_in;  
     end if; 
  end if; 
 end if;
end process PC;

instr_mem_address_o <= pc_out;

PC_adder: pc_adder_out <= std_logic_vector(unsigned(pc_out)+4);


pc_mux: pc_in <= pc_adder_out when pc_next_sel_i = '0' else
                 add_exit;

IF_ID_reg: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '1') then
   if(if_id_flush_i = '0') then
    if(if_id_en_i = '1') then
     instruction_o <= instr_mem_read_i;
     instr_IFID <= instr_mem_read_i;
     pc_out_IFID <= pc_out;
    end if;
   else
    instruction_o <= (others => '0');
    instr_IFID <= (others => '0');
    pc_out_IFID <= (others => '0');
   end if; 
  else
   instruction_o <= (others => '0');
   instr_IFID <= (others => '0');
   pc_out_IFID <= (others => '0');
   end if; 
 end if;
end process IF_ID_reg;



regbank: entity work.reg_bank
Port map(
clk => clk,
reset => reset,
rs1_address_i => instr_IFID(19 downto 15),
rs2_address_i => instr_IFID(24 downto 20),
rd_we_i => rd_we_i,
rd_address_i => rd_address_MEMWB,
rd_data_i => rd_reg_data,
rs1_data_o => rs1_reg_data,
rs2_data_o => rs2_reg_data
);

eq_mux1: eq_a <= rs1_reg_data when branch_forward_a_i = '0' else
                 alu_result_EXMEM;
 
eq_mux2: eq_b <= rs2_reg_data when branch_forward_b_i = '0' else
                 alu_result_EXMEM;

eq: branch_condition_o <= '1' when eq_a = eq_b else
                          '0';

imm: entity work.immediate
Port map(
instruction_i => instr_IFID,
immediate_extended_o => imm_extended
);


imm_adder: add_exit <= std_logic_vector(unsigned(pc_out_IFID) + shift_left(unsigned(imm_extended), 1));

ID_EX_reg: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '1') then
   rs1_data_IDEX <= rs1_reg_data;
   rs2_data_IDEX <= rs2_reg_data;
   imm_extended_IDEX <= imm_extended;
   data_i_IDEX <= rs2_reg_data;
   rd_address_IDEX <= instr_IFID(11 downto 7);
  else
   rs1_data_IDEX <= (others => '0');
   rs2_data_IDEX <= (others => '0');
   imm_extended_IDEX <= (others => '0');
   data_i_IDEX <= (others => '0');
   rd_address_IDEX <= (others => '0');
  end if;
 end if; 
end process ID_EX_reg;


mux_a: a <= rd_reg_data when alu_forward_a_i = "01" else
            alu_result_EXMEM when alu_forward_a_i = "10" else
            rs1_data_IDEX;


mux_b: b_pom <= rd_reg_data when alu_forward_b_i = "01" else
                alu_result_EXMEM when alu_forward_b_i = "10" else
                rs2_data_IDEX;


mux_b2: b <= b_pom when alu_src_b_i = '0' else
             imm_extended_IDEX;


ALU: entity work.ALU 
Port map(
a_i => a,
b_i => b,
op_i => alu_op_i,
res_o => result
);


EX_MEM_reg: process(clk)
begin
if(rising_edge(clk)) then
 if(reset = '1') then
  alu_result_EXMEM <= result;
  data_mem_address_o <= result;
  data_mem_write_o <= data_i_IDEX;
  rd_address_EXMEM <= rd_address_IDEX;
 else
  alu_result_EXMEM <=(others => '0');
  data_mem_address_o <= (others => '0');
  data_mem_write_o <= (others => '0');
  rd_address_EXMEM <= (others => '0');
 end if;
end if;
end process EX_MEM_reg;



MEM_WB_reg: process(clk)
begin
 if(rising_edge(clk)) then
  if(reset = '1') then
   alu_result_MEMWB <= alu_result_EXMEM;
   data_o_MEMWB <= data_mem_read_i;
   rd_address_MEMWB <= rd_address_EXMEM;
  else
   alu_result_MEMWB <= (others => '0');
   data_o_MEMWB <= (others => '0');
   rd_address_MEMWB <= (others => '0');
  end if; 
 end if;
end process MEM_WB_reg; 


WB_mux: rd_reg_data <= alu_result_MEMWB when mem_to_reg_i = '0' else
                       data_o_MEMWB;


end Behavioral;
