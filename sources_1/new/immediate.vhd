----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2023 09:01:15 PM
-- Design Name: 
-- Module Name: immediate - Behavioral
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

entity immediate is 
    Port (
          instruction_i : in std_logic_vector (31 downto 0);
          immediate_extended_o : out std_logic_vector (31 downto 0)
          );
end immediate;

architecture Behavioral of immediate is
 signal dopuna : std_logic_vector(19 downto 0);
 
begin

L1: process(instruction_i, dopuna)
begin

if(instruction_i(31) = '1') then
 dopuna <= (others => '1');
else
 dopuna <= (others => '0');
end if; 


if (instruction_i(6 downto 0) = "0000011") then   -- I-type LW
 immediate_extended_o <= dopuna & instruction_i(31 downto 20);
elsif (instruction_i(6 downto 0) = "0010011") then  -- I-type ADDI 
 immediate_extended_o <= dopuna & instruction_i(31 downto 20);
elsif(instruction_i(6 downto 0) = "1100011") then   -- B-type BEQ 
 immediate_extended_o <= dopuna & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8);
 else
  immediate_extended_o <= dopuna & instruction_i(31 downto 25) & instruction_i(11 downto 7);   -- S-type
end if;

end process;


end Behavioral;
