library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string  := "memInstrPolilegv8.dat"
    );
    port (
        addr : in bit_vector( addressSize-1 downto 0);
        data : out bit_vector( dataSize-1 downto 0)
    );
end entity memoriaInstrucoes;

architecture arch_memInstr of memoriaInstrucoes is 
    constant mem_depht : natural := 2**addressSize;
    type mem_type is array (0 to mem_depht-1) of bit_vector (dataSize-1 downto 0);

    impure function init_mem(file_name : in string) return mem_type is
        file     f          : text open read_mode is file_name; 
        variable l          : line;
        variable tmp_bv     : bit_vector(dataSize-1 downto 0); -- Vetor final (32 bits)
        variable file_val   : bit_vector(7 downto 0);          -- O que realmente existe no ficheiro (8 bits)
        variable tmp_mem    : mem_type; 
        variable i          : natural := 0;
    
    begin 
        -- Inicializa a memória com zeros para evitar lixo
        for j in tmp_mem'range loop
            tmp_mem(j) := (others => '0');
        end loop;

        while not endfile(f) loop
            readline(f, l);
            -- Lemos apenas 8 bits do ficheiro
            read(l, file_val);
            
            -- Nota: (dataSize - 8 - 1) assume que dataSize é 32. 
            -- Se for genérico, a lógica é: (others => '0') & file_val
            if dataSize > 8 then
                tmp_bv := (others => '0'); -- Limpa tudo primeiro
                tmp_bv(7 downto 0) := file_val; -- Coloca os 8 bits na parte baixa (LSB)
                -- OU, se preferir concatenar explicitamente:
                -- tmp_bv := bit_vector'(X"000000") & file_val; 
            else
                tmp_bv := file_val;
            end if;

            tmp_mem(i) := tmp_bv;
            i := i + 1;
        end loop; 
        return tmp_mem;
    end function;

    constant mem_data : mem_type := init_mem(datFileName);

 begin 
     data <= mem_data(to_integer(unsigned(addr)));
 end arch_memInstr; 





