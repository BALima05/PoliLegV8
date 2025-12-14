library ieee;
use ieee.numeric_bit.all;

entity fluxoDados is 
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
end entity fluxoDados; 

architecture structure_fluxoDados of fluxoDados is 

    -- 1. Declaracao dos componentes 

    -- Registrador generic (usado para o PC)
    component reg is 
        generic (dataSize: natural := 64);
        port (
            clock  : in bit;
            reset  : in bit;
            enable : in bit;
            d      : in bit_vector(dataSize-1 downto 0);
            q      : out bit_vector(dataSize-1 downto 0)
        );
    end component; 

    -- Memoria de instrcoes 
    component memoriaInstrucoes is 
        generic (
        addressSize : natural := 8;
        dataSize    : natural := 8;
        datFileName : string  := "memInstr_conteudo.dat"
        );
        port (
            addr : in bit_vector( addressSize-1 downto 0);
            data : out bit_vector( dataSize-1 downto 0)
        );
    end component; 

    -- Banco de registradores 
    component regfile is 
        port (
            clock    : in bit;                       -- entrada de clock
            reset    : in bit;                       -- entrada de reset
            regWrite : in bit;                       -- entrada de carga do registrador wr
            rr1      : in bit_vector(4 downto 0);    -- entrada define registrador 1 
            rr2      : in bit_vector (4 downto 0);   -- entrada define registrador 2 
            wr       : in bit_vector(4 downto 0);    -- entrada define registrador de escrita 
            d        : in bit_vector(63 downto 0);   -- entrada de dado para carga paralela 
            q1       : out bit_vector(63 downto 0);  -- saida do registrador rr1
            q2       : out bit_vector(63 downto 0)   -- saida do registrador rr2
        );
    end component; 

    -- ULA de 64 bits 
    component ula is 
        port (
            A  : in bit_vector(63 downto 0);   -- entrada A
            B  : in bit_vector(63 downto 0);   -- entrada B
            S  : in bit_vector(3 downto 0);    -- seleciona operacao
            F  : out bit_vector(63 downto 0);  -- saida 
            Z  : out bit;                      -- flag zero
            Ov : out bit;                      -- flag overflow 
            Co : out bit                       -- flag carry out 
        );
    end component; 

    -- Sign Extend 
    component sign_extend is 
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
    end component; 

    -- MUX generic 
    component mux_n is 
        generic (dataSize: natural := 64);
        port (
            in0  : in bit_vector(dataSize-1 downto 0);
            in1  : in bit_vector(dataSize-1 downto 0);
            sel  : in bit;
            dOut : out bit_vector(dataSize-1 downto 0)
        );
    end component; 

    -- Memoria de dados 
    component memoriaDados is 
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
    end component; 

    -- Somador generic 
    component adder_n is 
        generic (dataSize : natural := 64);
        port (
            in0  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cOut : out bit                             
        );
    end component; 

    -- Shift left 2 
    component two_left_shifts is 
        generic (
            dataSize : natural := 64
        );
        port (
            input  : in bit_vector (dataSize-1 downto 0);
            output : out bit_vector (dataSize-1 downto 0)
        );
    end component; 

    -- 2. Sinais internos 
    
    

