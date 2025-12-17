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
        addressSize : natural := 7;
        dataSize    : natural := 8;
        datFileName : string  := "memInstrPolilegv8.dat"
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
            outData     : out bit_vector (dataOSize-1 downto 0) -- dado de saida com tamanho dataOSize e sinal estendido 
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
            addressSize : natural := 7;
            dataSize    : natural := 8;
            datFileName : string := "memDadosInicialPolilegv8.dat"
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

    signal pc_reg_val  : bit_vector(6 downto 0);   -- Valor fisico de 7 bits do PC 
    signal pc_extend   : bit_vector(63 downto 0);  -- PC estendido para 64 bits 
    signal pc_next     : bit_vector(63 downto 0);   -- Proximo Program counter em 64 bits 
    signal s_instruction : bit_vector(31 downto 0);
    signal pc_sum4 : bit_vector(63 downto 0);
    signal pc_branch : bit_vector(63 downto 0);

    signal read_reg2 : bit_vector(4 downto 0);  -- Saída do MUX Reg2Loc (Vai para rr2)
    signal write_data : bit_vector(63 downto 0);
    signal reg_data1 : bit_vector(63 downto 0);
    signal reg_data2 : bit_vector(63 downto 0);
    
    signal s_sign_extend : bit_vector(63 downto 0);

    signal alu_inputB : bit_vector(63 downto 0);
    signal alu_result : bit_vector(63 downto 0);
    signal flag_zero : bit;

    signal data_memory_out : bit_vector(63 downto 0);
    signal data_mem_out8 : bit_vector(7 downto 0);

    signal pc_src : bit;

    signal c_four : bit_vector(63 downto 0);

    signal branch_offset : bit_vector(63 downto 0);

    -- Sinais auxiliares para o calculo de endereco de instrucao
    signal pc_idx : unsigned(7 downto 0);
    signal addr_instr_0, addr_instr_1, addr_instr_2, addr_instr_3 : bit_vector(7 downto 0);
    signal instr_b0, instr_b1, instr_b2, instr_b3 : bit_vector(7 downto 0);

    -- Sinais auxiliares para o calculo de endereco de dados
    signal alu_idx : unsigned(7 downto 0);
    signal addr_data_0, addr_data_1, addr_data_2, addr_data_3 : bit_vector(7 downto 0);
    signal addr_data_4, addr_data_5, addr_data_6, addr_data_7 : bit_vector(7 downto 0);

    -- Sinais de dados de leitura
    signal data_d0, data_d1, data_d2, data_d3, data_d4, data_d5, data_d6, data_d7 : bit_vector(7 downto 0);

begin

    c_four <= (2 => '1', others => '0');    -- Constante 4
    opcode <= s_instruction(31 downto 21);  -- Opcode
     
    U_PC: reg 
        generic map (dataSize => 7)
        port map (
            clock  => clock,
            reset  => reset,
            enable => '1',
            d      => pc_next(6 downto 0), -- Truncamento (pega apenas os 7 bits menos significativos do proximo PC)
            q      => pc_reg_val
        );
    
    pc_idx <= unsigned(pc_out(7 downto 0));
    
    addr_instr_0 <= bit_vector(pc_idx);
    addr_instr_1 <= bit_vector(pc_idx + 1);
    addr_instr_2 <= bit_vector(pc_idx + 2);
    addr_instr_3 <= bit_vector(pc_idx + 3);

    -- Instanciação usando os sinais pre-calculados
    MEMI_B0: memoriaInstrucoes port map (addr => addr_instr_0, data => instr_b0);
    MEMI_B1: memoriaInstrucoes port map (addr => addr_instr_1, data => instr_b1);
    MEMI_B2: memoriaInstrucoes port map (addr => addr_instr_2, data => instr_b2);
    MEMI_B3: memoriaInstrucoes port map (addr => addr_instr_3, data => instr_b3);

    instruction <= instr_b0 & instr_b1 & instr_b2 & instr_b3;

    U_IMEM: memoriaInstrucoes
        generic map ( 
            addressSize => 7,
            dataSize    => 32
        )
        port map ( 
            addr => pc_reg_val,
            data => s_instruction 
        );

    U_RegFile : regfile 
        port map (
            clock     => clock, 
            reset     => reset,  
            regWrite  => regWrite,
            rr1       => s_instruction(9 downto 5),
            rr2       => read_reg2,
            wr        => s_instruction(4 downto 0),
            d         => write_data,
            q1        => reg_data1,
            q2        => reg_data2
        );
    
    U_SignExt : sign_extend 
        port map (
            inData       => s_instruction,
            inDataStart  => extendMSB,
            inDataEnd    => extendLSB,
            outData      => s_sign_extend
        );

    U_ULA : ula 
        port map ( 
            A  => reg_data1,
            B  => alu_inputB,
            S  => alu_control,
            F  => alu_result,
            Z  => flag_zero,
            Ov => open,
            Co => open
        );

    U_MUX_Reg2Loc : mux_n 
        generic map (dataSize => 5)
        port map (
            in0  => s_instruction(20 downto 16),
            in1  => s_instruction(4 downto 0),
            sel  => reg2Loc,
            dOut => read_reg2
        );
    
    U_MUX_ALUSrc : mux_n 
        generic map (dataSize => 64)
        port map (
            in0  => reg_data2,
            in1  => s_sign_extend,
            sel  => aluSrc,
            dOut => alu_inputB
        );
    
    U_MUX_MemToReg : mux_n 
        generic map (dataSize => 64)
        port map ( 
            in0  => alu_result,
            in1  => data_memory_out,
            sel  => memToReg,
            dOut => write_data
        );
    pc_src <= uncondBranch or (branch and flag_zero);

    U_MUX_PC : mux_n 
        generic map (dataSize => 64)
        port map (
            in0  => pc_sum4,
            in1  => pc_branch,
            sel  => pc_src,
            dOut => pc_next
        );
    
    U_MEMD: memoriaDados
        generic map (
            addressSize => 7,  
            dataSize    => 8,  
            datFileName => "memDadosInicialPolilegv8.dat"
        )
        port map ( 
            clock   => clock,
            wr      => memWrite,
            addr    => alu_result(6 downto 0),
            data_i  => reg_data2(7 downto 0), 
            data_o  => data_mem_out8
        );
    
    alu_idx <= unsigned(alu_result(7 downto 0));

    addr_data_0 <= bit_vector(alu_idx);
    addr_data_1 <= bit_vector(alu_idx + 1);
    addr_data_2 <= bit_vector(alu_idx + 2);
    addr_data_3 <= bit_vector(alu_idx + 3);
    addr_data_4 <= bit_vector(alu_idx + 4);
    addr_data_5 <= bit_vector(alu_idx + 5);
    addr_data_6 <= bit_vector(alu_idx + 6);
    addr_data_7 <= bit_vector(alu_idx + 7);

    -- Instanciação dos 8 bancos usando os sinais de endereço
    MEMD_B0: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_0, data_i => reg_data2(63 downto 56), data_o => data_d0);
    MEMD_B1: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_1, data_i => reg_data2(55 downto 48), data_o => data_d1);
    MEMD_B2: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_2, data_i => reg_data2(47 downto 40), data_o => data_d2);
    MEMD_B3: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_3, data_i => reg_data2(39 downto 32), data_o => data_d3);
    MEMD_B4: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_4, data_i => reg_data2(31 downto 24), data_o => data_d4);
    MEMD_B5: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_5, data_i => reg_data2(23 downto 16), data_o => data_d5);
    MEMD_B6: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_6, data_i => reg_data2(15 downto  8), data_o => data_d6);
    MEMD_B7: memoriaDados port map (clock => clock, wr => memWrite, addr => addr_data_7, data_i => reg_data2( 7 downto  0), data_o => data_d7);

    -- Reconstrói a palavra de 64 bits
    data_memory_out <= data_d0 & data_d1 & data_d2 & data_d3 & data_d4 & data_d5 & data_d6 & data_d7;

    U_ADD_PC4: adder_n 
        generic map (dataSize => 64)
        port map (
            in0 => pc_extend,
            in1 => c_four,
            sum => pc_sum4,
            cOut => open 
        );
    
    U_ADD_Branch: adder_n 
        generic map (dataSize => 64)
        port map (
            in0 => pc_extend,
            in1 => branch_offset,
            sum => pc_branch,
            cOut => open 
        );
    
    U_SHIFT : two_left_shifts
        port map (
            input  => s_sign_extend,
            output => branch_offset
        );
    
end architecture structure_fluxoDados;
    
    



