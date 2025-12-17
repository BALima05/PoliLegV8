library ieee;
use ieee.numeric_bit.all;
use std_textio.all;

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
        file     f       : text open read_mode is file_name; 
        variable l       : line;
        variable tmp_bv  : bit_vector(dataSize-1 downto 0);
        variable tmp_mem : mem_type; 
		variable i 	 : natural := 0;
    
    begin 
        while not endfile(f) loop
            readline(f, l);
            read(l, tmp_bv);
            tmp_mem(i) := tmp_bv;
	    i := i + 1;
        end loop; 
        return tmp_mem;
    end; 

    constant mem_data : mem_type := init_mem(datFileName);

 begin 
     data <= mem_data(to_integer(unsigned(addr)));
 end arch_memInstr; 




