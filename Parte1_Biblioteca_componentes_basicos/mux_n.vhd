entity mux_n is 
    generic (dataSize: natural := 64);
    port (
        in0  : in bit_vector(dataSize-1 downto 0);
        in1  : in bit_vector(dataSize-1 downto 0);
        sel  : in bit;
        dOut : out bit_vector(dataSize-1 downto 0)
    );
end entity mux_n;

architecture muxn_arch of mux_n is 
begin 
    dOut <= in0 when sel = '0' else in1;

end architecture muxn_arch;