library ieee;
use ieee.numeric_bit.all;
use std_textio.all;

entity memoriaDados is 
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string := "memDados_conteudo_inicial.dat"
    );
    port ( 
        clock  : in bit;
        wr     : in bit;
        addr   : in bit_vector(addressSize-1 downto 0); 
        data_i : in bit_vector(dataSize-1 downto 0);
        data_o : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaDados; 

architecture arch_memDados of memoriaDados is 
    constant depth : natural := 2**addressSize; 
    type mem_type is array (0 to depth-1) of bit_vector(dataSize-1 downto 0);

    impure function init_mem(file_name : in string) return mem_type is 
        file f : text open read_mode is file_name;
        variable l : line; 
        variable tmp_bv : bit_vector(dataSize-1 downto 0); 
        variable tmp_mem : mem_type; 
    
    begin 
        for i in mem_type'range loop 
            tmp_mem(i) := (others => '0');
        end loop;

        for i in mem_type'range loop 
            readline(f, l);
            read(l, tmp_bv);
            tmp_mem(i) := tmp_bv; 
        end loop; 
        return tmp_mem; 
    end;

    signal mem : mem_type := init_mem(datFileName);

begin 
    wrt: process(clock)
    begin 
        if (clock='1' and clock'event) then 
            if (wr='1') then 
                mem(to_integer(unsigned(addr))) <= data_i;
            end if;
        end if;
    end process;
    data_o <= mem(to_integer(unsigned(addr)));

end arch_memDados; 
    