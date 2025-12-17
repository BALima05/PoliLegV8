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

    -- 1. Declaração dos Componentes

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

    -- Memória de Instruções (Agora dataSize = 8)
    component memoriaInstrucoes is
        generic (
            addressSize : natural := 7;
            dataSize    : natural := 8; -- Ajustado para 8 bits
            datFileName : string  := "memInstrPolilegv8.dat"
        );
        port (
            addr : in bit_vector( addressSize-1 downto 0);
            data : out bit_vector( dataSize-1 downto 0)
        );
    end component;

    -- Memória de Dados (Agora dataSize = 8)
    component memoriaDados is 
        generic (
            addressSize : natural := 7;
            dataSize    : natural := 8; -- Ajustado para 8 bits
            datFileName : string  := "memDadosInicialPolilegv8.dat"
        );
        port ( 
            clock  : in bit;
            wr     : in bit;
            addr   : in bit_vector(addressSize-1 downto 0); 
            data_i : in bit_vector(dataSize-1 downto 0);
            data_o : out bit_vector(dataSize-1 downto 0)
        );
    end component; 

    component ula is 
        generic (dataSize: natural := 64);
        port (
            A, B : in bit_vector (dataSize-1 downto 0);
            ctrl : in bit_vector (3 downto 0);
            result : out bit_vector (dataSize-1 downto 0);
            zero, ovf : out bit
        );
    end component;

    component mux_2 is 
        generic (dataSize: natural := 64);
        port (
            in0, in1 : in bit_vector (dataSize-1 downto 0);
            sel : in bit;
            dOut : out bit_vector (dataSize-1 downto 0)
        );
    end component; 

    component signExtend is 
        port (
            dIn : in bit_vector (31 downto 0);
            extendMSB : in bit_vector (4 downto 0);
            extendLSB : in bit_vector (4 downto 0);
            dOut : out bit_vector (63 downto 0)
        );
    end component;

    component adder_n is 
        generic (dataSize: natural := 64);
        port (
            in0, in1 : in bit_vector(dataSize-1 downto 0);
            sum : out bit_vector(dataSize-1 downto 0);
            cOut : out bit
        );
    end component;

    component shift_left is 
        generic (
            dataSizeIn: natural := 64;
            dataSizeOut: natural := 64;
            shift: natural := 1
        );
        port (
            dIn : in bit_vector(dataSizeIn-1 downto 0);
            dOut : out bit_vector(dataSizeOut-1 downto 0)
        );
    end component;

    component bancoRegistradores is 
        generic (
            regSize : natural := 5;
            dataSize : natural := 64
        );
        port ( 
            clock        : in bit;
            regWrite     : in bit;
            read_reg1    : in bit_vector(regSize-1 downto 0);
            read_reg2    : in bit_vector(regSize-1 downto 0);
            write_reg    : in bit_vector(regSize-1 downto 0);
            write_data   : in bit_vector(dataSize-1 downto 0);
            read_data1   : out bit_vector(dataSize-1 downto 0);
            read_data2   : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- 2. Declaração dos sinais internos
    
    -- PC e Instrução
    signal pc_out, pc_next : bit_vector(63 downto 0);
    signal pc_sum4, pc_branch : bit_vector(63 downto 0);
    signal instruction : bit_vector(31 downto 0);
    
    -- Sinais auxiliares para leitura de instrução (4 bytes)
    signal pc_idx : unsigned(7 downto 0);
    signal instr_b0, instr_b1, instr_b2, instr_b3 : bit_vector(7 downto 0);

    -- Banco de Registradores
    signal reg_read_addr2 : bit_vector(4 downto 0);
    signal reg_data1, reg_data2 : bit_vector(63 downto 0);
    signal write_data : bit_vector(63 downto 0);

    -- ULA e Extensão
    signal imm_extended : bit_vector(63 downto 0);
    signal imm_shifted : bit_vector(63 downto 0);
    signal alu_in_B : bit_vector(63 downto 0);
    signal alu_result : bit_vector(63 downto 0);
    signal flag_zero : bit;

    -- Memória de Dados (8 Bytes)
    signal data_memory_out : bit_vector(63 downto 0);
    signal alu_idx : unsigned(7 downto 0);
    -- Sinais para cada byte lido da memória de dados
    signal data_d0, data_d1, data_d2, data_d3, data_d4, data_d5, data_d6, data_d7 : bit_vector(7 downto 0);

    -- Controle
    signal pc_src : bit;
    signal c_four : bit_vector(63 downto 0);

begin 

    c_four <= x"0000000000000004";
    opcode <= instruction(31 downto 21);

    -- =======================================================================
    -- ESTÁGIO 1: Instruction Fetch (Busca de Instrução com 4 Bancos)
    -- =======================================================================
    
    U_PC : reg 
        generic map (dataSize => 64)
        port map (clock => clock, reset => reset, enable => '1', d => pc_next, q => pc_out);

    -- Cálculo do endereço base para os bancos de memória (truncado para 8 bits)
    pc_idx <= unsigned(pc_out(7 downto 0));

    -- Instanciação de 4 memórias em paralelo para ler 32 bits de uma vez
    -- Assumindo Big Endian: Endereço PC = Byte Mais Significativo (Bits 31-24)
    MEMI_B0: memoriaInstrucoes port map (addr => bit_vector(pc_idx + 0), data => instr_b0);
    MEMI_B1: memoriaInstrucoes port map (addr => bit_vector(pc_idx + 1), data => instr_b1);
    MEMI_B2: memoriaInstrucoes port map (addr => bit_vector(pc_idx + 2), data => instr_b2);
    MEMI_B3: memoriaInstrucoes port map (addr => bit_vector(pc_idx + 3), data => instr_b3);

    -- Concatena os 4 bytes para formar a instrução
    instruction <= instr_b0 & instr_b1 & instr_b2 & instr_b3;

    U_ADD_PC4: adder_n 
        generic map (dataSize => 64)
        port map (in0 => pc_out, in1 => c_four, sum => pc_sum4, cOut => open);

    -- =======================================================================
    -- ESTÁGIO 2: Decode / Register Read
    -- =======================================================================

    U_MUX_REG2 : mux_2 
        generic map (dataSize => 5)
        port map (in0 => instruction(20 downto 16), in1 => instruction(4 downto 0), sel => reg2Loc, dOut => reg_read_addr2);

    U_BANCO_REG : bancoRegistradores 
        port map (
            clock        => clock,
            regWrite     => regWrite,
            read_reg1    => instruction(9 downto 5),
            read_reg2    => reg_read_addr2,
            write_reg    => instruction(4 downto 0),
            write_data   => write_data,
            read_data1   => reg_data1,
            read_data2   => reg_data2
        );

    U_SIGN_EXT : signExtend 
        port map (dIn => instruction, extendMSB => extendMSB, extendLSB => extendLSB, dOut => imm_extended);

    -- =======================================================================
    -- ESTÁGIO 3: Execute (ULA e Branch)
    -- =======================================================================

    U_MUX_ALU : mux_2 
        generic map (dataSize => 64)
        port map (in0 => reg_data2, in1 => imm_extended, sel => aluSrc, dOut => alu_in_B);

    U_ULA : ula 
        generic map (dataSize => 64)
        port map (A => reg_data1, B => alu_in_B, ctrl => alu_control, result => alu_result, zero => flag_zero, ovf => open);

    U_SHIFT : shift_left 
        generic map (dataSizeIn => 64, dataSizeOut => 64, shift => 2) -- Shift branch offset by 2
        port map (dIn => imm_extended, dOut => imm_shifted);

    U_ADD_BRANCH : adder_n 
        generic map (dataSize => 64)
        port map (in0 => pc_out, in1 => imm_shifted, sum => pc_branch, cOut => open);

    -- =======================================================================
    -- ESTÁGIO 4: Memory Access (Dados de 64 bits com 8 Bancos)
    -- =======================================================================
    
    -- Endereço base da ULA (truncado)
    alu_idx <= unsigned(alu_result(7 downto 0));

    -- Instanciação de 8 memórias para leitura/escrita de 64 bits (Big Endian)
    -- Byte 0 (MSB) no endereço base, Byte 7 (LSB) no endereço base + 7
    
    MEMD_B0: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 0), data_i => reg_data2(63 downto 56), data_o => data_d0);
    MEMD_B1: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 1), data_i => reg_data2(55 downto 48), data_o => data_d1);
    MEMD_B2: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 2), data_i => reg_data2(47 downto 40), data_o => data_d2);
    MEMD_B3: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 3), data_i => reg_data2(39 downto 32), data_o => data_d3);
    MEMD_B4: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 4), data_i => reg_data2(31 downto 24), data_o => data_d4);
    MEMD_B5: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 5), data_i => reg_data2(23 downto 16), data_o => data_d5);
    MEMD_B6: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 6), data_i => reg_data2(15 downto  8), data_o => data_d6);
    MEMD_B7: memoriaDados port map (clock => clock, wr => memWrite, addr => bit_vector(alu_idx + 7), data_i => reg_data2( 7 downto  0), data_o => data_d7);

    -- Reconstrói a palavra de 64 bits lida
    data_memory_out <= data_d0 & data_d1 & data_d2 & data_d3 & data_d4 & data_d5 & data_d6 & data_d7;

    -- =======================================================================
    -- ESTÁGIO 5: Write Back e Atualização do PC
    -- =======================================================================

    U_MUX_MEMREG : mux_2 
        generic map (dataSize => 64)
        port map (in0 => alu_result, in1 => data_memory_out, sel => memToReg, dOut => write_data);

    pc_src <= uncondBranch or (branch and flag_zero);

    U_MUX_PC : mux_2 -- Corrigido de mux_n para mux_2 para consistência
        generic map (dataSize => 64)
        port map (in0 => pc_sum4, in1 => pc_branch, sel => pc_src, dOut => pc_next);

end structure_fluxoDados;