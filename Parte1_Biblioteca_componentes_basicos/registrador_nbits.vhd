entity reg is 
    generic (dataSize: natural := 64);
    port (
        clock  : in bit;
        reset  : in bit;
        enable : in bit;
        d      : in bit_vector(dataSize-1 downto 0);
        q      : out bit_vector(dataSize-1 downto 0)
    );
end entity reg;

architecture reg_arch of reg is 
begin 
    process(clock, reset)
    begin 
        if reset = '1' then 
            q <= (others => '0'); 

        elsif (clock 'event and clock = '1') then 
            if enable = '1' then 
                q <= d; 
            end if;
        end if;
    end process;

end architecture reg_arch;
        
        

    