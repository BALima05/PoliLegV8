library ieee;
use ieee.numeric_bit.all;

entity adder_n is
    generic (dataSize : natural := 64);
    port (
        in0  : in  bit_vector(dataSize-1 downto 0);
        in1  : in  bit_vector(dataSize-1 downto 0);
        sum  : out bit_vector(dataSize-1 downto 0);
        cOut : out bit                             
    );
end entity adder_n;

architecture arch_adder of adder_n is
    signal res_ext : unsigned(dataSize downto 0);
begin
    -- Concatenamos '0' à esquerda para permitir o transbordo no bit extra
    res_ext <= unsigned('0' & in0) + unsigned('0' & in1);
    
    sum <= bit_vector(res_ext(dataSize-1 downto 0));
    
    -- O bit mais significativo do sinal estendido é o nosso cOut
    cOut <= res_ext(dataSize);
end architecture arch_adder;