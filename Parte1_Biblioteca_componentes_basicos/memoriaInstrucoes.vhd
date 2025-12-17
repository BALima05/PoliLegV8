library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string  := "memInstr_conteudo.dat"
    );
    port (
        addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0) -- Saída de 8 bits
    );
end entity memoriaInstrucoes;

architecture arch_memInstr of memoriaInstrucoes is 
    constant mem_depth : natural := 2**addressSize;
    type mem_type is array (0 to mem_depth-1) of bit_vector(dataSize-1 downto 0);

    impure function init_mem(file_name : in string) return mem_type is
        file     f          : text open read_mode is file_name;
        variable l          : line;
        variable file_val   : bit_vector(dataSize-1 downto 0); -- Lê 8 bits
        variable tmp_mem    : mem_type;
        variable i          : natural := 0;
    begin 
        -- 1. Inicializa tudo com zero
        for j in tmp_mem'range loop
            tmp_mem(j) := (others => '0');
        end loop;

        -- 2. Lê o arquivo linha a linha (1 linha = 1 endereço)
        while not endfile(f) and i < mem_depth loop
            readline(f, l);
            read(l, file_val); 
            
            tmp_mem(i) := file_val; -- Armazenamento direto
            i := i + 1;
        end loop; 
        
        return tmp_mem;
    end function;

    constant mem_data : mem_type := init_mem(datFileName);

begin 
    data <= mem_data(to_integer(unsigned(addr)));
end arch_memInstr;