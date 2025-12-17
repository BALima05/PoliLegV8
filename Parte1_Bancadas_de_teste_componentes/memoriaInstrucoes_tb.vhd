library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity tb_memoriaInstrucoes is
end entity tb_memoriaInstrucoes;

architecture sim of tb_memoriaInstrucoes is

    component memoriaInstrucoes is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memInstr_conteudo.dat"
        );
        port (
            addr : in bit_vector(addressSize-1 downto 0);
            data : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    signal s_addr : bit_vector(7 downto 0) := (others => '0');
    signal s_data : bit_vector(7 downto 0); -- Saída agora é 8 bits
    
    constant T_ACCESS : time := 10 ns;

begin

    DUT: memoriaInstrucoes
        generic map (
            addressSize => 8,
            dataSize    => 8,
            datFileName => "memInstr_conteudo.dat"
        )
        port map (
            addr => s_addr,
            data => s_data
        );

    process
        variable byte0, byte1, byte2, byte3 : bit_vector(7 downto 0);
        variable instr_32 : bit_vector(31 downto 0);
        variable pc : integer := 0; -- Program Counter simulado
    begin
        report "Iniciando Teste: Leitura de Instrucoes de 4 Bytes (32 bits)" severity note;
        wait for T_ACCESS;

        -------------------------------------------------------------------
        -- TESTE 1: Buscar a Primeira Instrução (Endereços 0, 1, 2, 3)
        -- Arquivo:
        -- Linha 1 (End 0): 11111000 (F8)
        -- Linha 2 (End 1): 01000000 (40)
        -- Linha 3 (End 2): 00000011 (03)
        -- Linha 4 (End 3): 11100001 (E1)
        -------------------------------------------------------------------
        
        -- Passo 1: Ler Byte 0 (PC)
        s_addr <= bit_vector(to_unsigned(pc, 8));
        wait for T_ACCESS;
        byte0 := s_data; -- F8

        -- Passo 2: Ler Byte 1 (PC + 1)
        s_addr <= bit_vector(to_unsigned(pc + 1, 8));
        wait for T_ACCESS;
        byte1 := s_data; -- 40

        -- Passo 3: Ler Byte 2 (PC + 2)
        s_addr <= bit_vector(to_unsigned(pc + 2, 8));
        wait for T_ACCESS;
        byte2 := s_data; -- 03

        -- Passo 4: Ler Byte 3 (PC + 3)
        s_addr <= bit_vector(to_unsigned(pc + 3, 8));
        wait for T_ACCESS;
        byte3 := s_data; -- E1

        -- Montar a instrução (Assumindo Big Endian para leitura visual direta)
        instr_32 := byte0 & byte1 & byte2 & byte3;

        -- Verificar
        assert instr_32 = x"F84003E1"
            report "Erro na Instrucao 0. Recebido: " & integer'image(to_integer(unsigned(instr_32)))
            severity error;
            
        report "Instrucao 0 reconstruida com sucesso: " & "F84003E1";

        -------------------------------------------------------------------
        -- TESTE 2: Próxima Instrução (PC incrementa em 4 -> Endereços 4, 5, 6, 7)
        -------------------------------------------------------------------
        pc := 4; 
        
        -- Ler os 4 bytes sequenciais novamente
        s_addr <= bit_vector(to_unsigned(pc, 8));     wait for T_ACCESS; byte0 := s_data;
        s_addr <= bit_vector(to_unsigned(pc+1, 8));   wait for T_ACCESS; byte1 := s_data;
        s_addr <= bit_vector(to_unsigned(pc+2, 8));   wait for T_ACCESS; byte2 := s_data;
        s_addr <= bit_vector(to_unsigned(pc+3, 8));   wait for T_ACCESS; byte3 := s_data;
        
        instr_32 := byte0 & byte1 & byte2 & byte3;

        -- Arquivo linhas 5-8:
        -- 11111000 (F8)
        -- 01000000 (40)
        -- 10000011 (83)
        -- 11100010 (E2) -> Hex esperado: F84083E2
        
        assert instr_32 = x"F84083E2"
            report "Erro na Instrucao 1 (PC=4)."
            severity error;
            
        report "Instrucao 1 reconstruida com sucesso: " & "F84083E2";

        -------------------------------------------------------------------
        -- TESTE 3: Caso de Borda (Memória Vazia)
        -------------------------------------------------------------------
        -- Ler endereço distante (200) onde deve haver zeros
        s_addr <= bit_vector(to_unsigned(200, 8));
        wait for T_ACCESS;
        assert s_data = "00000000" report "Erro: Memoria nao inicializada corretamente com zeros" severity error;

        report "Fim do Teste." severity note;
        wait;
    end process;

end architecture sim;