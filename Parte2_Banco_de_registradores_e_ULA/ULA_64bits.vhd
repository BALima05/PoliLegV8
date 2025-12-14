entity ula is
    port (
        A  : in bit_vector(63 downto 0);   -- entrada A
        B  : in bit_vector(63 downto 0);   -- entrada B
        S  : in bit_vector(3 downto 0);    -- seleciona operacao
        F  : out bit_vector(63 downto 0);  -- saida 
        Z  : out bit;                      -- flag zero
        Ov : out bit;                      -- flag overflow 
        Co : out bit                       -- flag carry out 
    );
end entity ula; 

architecture structure_ula of ula is 
    component ula1bit is 
        port (
            a         : in bit;
            b         : in bit;
            cin       : in  bit;
            ainvert   : in  bit;
            binvert   : in  bit;
            operation : in  bit_vector(1 downto 0);
            result    : out bit;
            cout      : out bit;
            overflow  : out bit
         );
    end component; 
