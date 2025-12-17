library ieee;
use ieee.numeric_bit.all;

entity polilegv8 is 
    port ( 
       clock : in bit; 
       reset : in bit
     ); 
end entity polilegv8; 

architecture arch_polilegv8 of polilegv8 is 

    -- 1. Declaracao dos Componentes
    component unidadeControle is 
        port (
            opcode       : in bit_vector (10 downto 0);
            extendMSB    : out bit_vector (4 downto 0);
            extendLSB    : out bit_vector (4 downto 0);
            reg2Loc      : out bit;
            regWrite     : out bit;
            aluSrc       : out bit;
            alu_control  : out bit_vector (3 downto 0);
            branch       : out bit;
            uncondBranch : out bit;
            memRead      : out bit;
            memWrite     : out bit;
            memToReg     : out bit
        );
    end component;

    component fluxoDados is
        port (
            clock        : in bit;
            reset        : in bit;
            extendMSB    : in bit_vector (4 downto 0);
            extendLSB    : in bit_vector (4 downto 0);
            reg2Loc      : in bit;
            regWrite     : in bit;
            aluSrc       : in bit;
            alu_control  : in bit_vector (3 downto 0);
            branch       : in bit;
            uncondBranch : in bit; 
            memRead      : in bit; 
            memWrite     : in bit; 
            memToReg     : in bit; 
            opcode       : out bit_vector (10 downto 0)
        );
        end component;

    -- 2. Sinais Internos (Fios de conexão)
    signal s_opcode       : bit_vector(10 downto 0);
    signal s_extendMSB    : bit_vector(4 downto 0);
    signal s_extendLSB    : bit_vector(4 downto 0);
    signal s_reg2Loc      : bit;
    signal s_regWrite     : bit;
    signal s_aluSrc       : bit;
    signal s_alu_control  : bit_vector(3 downto 0);
    signal s_branch       : bit;
    signal s_uncondBranch : bit;
    signal s_memRead      : bit;
    signal s_memWrite     : bit;
    signal s_memToReg     : bit;

begin 

    -- 3. Instanciação
    UC: unidadeControle 
        port map (
            opcode       => s_opcode,       
            extendMSB    => s_extendMSB,    
            extendLSB    => s_extendLSB,
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg
        );
    
    FD: fluxoDados 
        port map (
            clock        => clock,          
            reset        => reset,          
            reg2Loc      => s_reg2Loc,
            regWrite     => s_regWrite,
            aluSrc       => s_aluSrc,
            alu_control  => s_alu_control,
            branch       => s_branch,
            uncondBranch => s_uncondBranch,
            memRead      => s_memRead,
            memWrite     => s_memWrite,
            memToReg     => s_memToReg,
            extendMSB    => s_extendMSB,
            extendLSB    => s_extendLSB,
            opcode       => s_opcode
        );

end architecture arch_polilegv8;