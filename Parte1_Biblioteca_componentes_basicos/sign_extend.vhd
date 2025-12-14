library ieee;
use ieee.numeric_bit.all;

entity sign_extend is 
    generic (
        dataISize       : natural := 32;
        dataOSIze       : natural := 64;
        dataMaxPosition : natural := 5 -- sempre fazer log2(dataISize)
    );
    port ( 
        inData      : in bit_vector (dataISize-1 downto 0);
        inDataStart : in bit_vector (dataMaxPosition-1 downto 0); -- posicao do bit mais significativo do valor util na entrada (bit de sinal)
        inDataEnd   : in bit_vector (dataMaxPosition-1 downto 0); -- posicao do bit menos significativo do valor util na entrada
        outData     : out bit_vector (dataOSize-1 downto 0); -- dado de saida com tamanho dataOSize e sinal estendido 
    );
end entity sign_extend; 

architecture arch_signExtend of sign_extend is 
begin
    process(inData, inDataStart, inDataEnd)
        variable msb_i  : integer; -- Indice do bit de sinal (start)
        variable lsb_i  : integer; -- Indice do bit final (end)
        variable size   : integer; -- Tamanho do offset 
        
    begin 
        msb_i := to_integer(unsigned(inDataStart));  -- Converte as entradas de posicao (bit_vector) para inteiros
        lsb_i := to_integer(unsigned(inDataEnd));

        size := msb_i - lsb_i + 1; -- Calcula o tamanho do offset

        for k in 0 to dataOSize-1 loop 
            if k <= size then 
                outData(k) <= inData(lsb_i + k); -- Copia os bits originais do campo escolhido 
            else 
                outData(k) <= inData(msb_i);  -- Copia o bit de sinal (posicao msb_i da entrada)
            end if;
        end loop;
    end process;

end architecture arch_signExtend;

    



