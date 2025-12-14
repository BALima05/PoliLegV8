library ieee;
use ieee.numeric_bit.all;
use std_textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string  := "memInstr_conteudo.dat"
    );
    port (
        addr : in bit_vector( addressSize-1 downto 0);
        data : out bit_vector( dataSize-1 downto 0)
    );
end entity memoriaInstrucoes;

architecture arch_memInstr of memoriaInstrucoes is 
    constant mem : natural := 2**addressSize;
    type mem_type is array (0 to mem-1) of bit_vector (dataSize-1 downto 0);

    impure function init_mem(file_name : in string) return mem_type is
        file     f       : text open read_mode is file_name; 
        variable l       : line;
        variable tmp_bv  : bit_vector(dataSize-1 downto 0);
        variable tmp_mem : mem_type; 
    
    begin 
        for i in mem_type'range loop
            readline(f, l);
            read(l, tmp_bv);
            tmp_mem(i) := tmp_bv;
        end loop; 
        return tmp_mem; 
    end; 

    constant mem : mem_type := init_mem(data_file_name);

 begin 
     data <= mem(to_integer(unsigned(addr)));
 end arch_memInstr; 


