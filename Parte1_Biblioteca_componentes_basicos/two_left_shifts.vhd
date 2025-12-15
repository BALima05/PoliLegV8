library ieee;
use ieee.numeric_bit.all;

entity two_left_shifts is 
    generic (
        dataSize : natural := 64
    );
    port (
        input  : in bit_vector (dataSize-1 downto 0);
        output : out bit_vector (dataSize-1 downto 0)
    );
end entity two_left_shifts;

architecture arch_leftShifts of two_left_shifts is 
begin
    output <= input(dataSize-3 downto 0) & "00";

end architecture arch_leftShifts;


