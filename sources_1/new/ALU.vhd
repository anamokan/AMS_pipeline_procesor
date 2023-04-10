----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2023 09:51:08 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
GENERIC(
WIDTH : NATURAL := 32);
PORT(
a_i : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --prvi operand
b_i : in STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); --drugi operand
op_i : in STD_LOGIC_VECTOR(4 DOWNTO 0); --port za izbor operacije
res_o : out STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) --rezultat
);
end ALU;

architecture Behavioral of ALU is

begin

mux: process(op_i, a_i, b_i)
begin
 if(op_i = "00000") then
  res_o <= a_i and b_i;
 elsif(op_i = "00001") then
  res_o <= a_i or b_i;
 elsif(op_i = "00010") then
  res_o <= std_logic_vector(signed(a_i) + signed(b_i));   
 else 
  res_o <= std_logic_vector(signed(a_i) - signed(b_i));
 end if;
end process mux;

end Behavioral;
