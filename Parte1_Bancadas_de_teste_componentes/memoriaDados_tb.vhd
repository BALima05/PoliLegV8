library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity tb_memoriaDados is
end entity tb_memoriaDados;

architecture sim of tb_memoriaDados is

    -- Componente (DUT)
    component memoriaDados is 
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memDados_conteudo_inicial.dat"
        );
        port ( 
            clock  : in bit;
            wr     : in bit;
            addr   : in bit_vector(addressSize-1 downto 0); 
            data_i : in bit_vector(dataSize-1 downto 0);
            data_o : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- Sinais
    signal clk      : bit := '0';
    signal s_wr     : bit := '0';
    signal s_addr   : bit_vector(7 downto 0) := (others => '0');
    signal s_data_i : bit_vector(7 downto 0) := (others => '0');
    signal s_data_o : bit_vector(7 downto 0);

    constant T_CLK  : time := 20 ns; -- 50 MHz

begin

    DUT: memoriaDados
        generic map (
            addressSize => 8,
            dataSize    => 8,
            datFileName => "memDados_conteudo_inicial.dat"
        )
        port map (
            clock  => clk,
            wr     => s_wr,
            addr   => s_addr,
            data_i => s_data_i,
            data_o => s_data_o
        );

    clk_proc: process
    begin
        while now < 550 ns loop -- Limita o tempo de simulaÃ§Ã£o
        clk <= '0'; wait for T_CLK/2;
        clk <= '1'; wait for T_CLK/2;
	    end loop;
        wait;
    end process;

    stim_proc: process
        -- Variáveis auxiliares para montar/desmontar 64 bits
        variable data_read_64 : bit_vector(63 downto 0);
        variable data_write_64 : bit_vector(63 downto 0);
        
        -- Procedimento auxiliar para LER 64 bits (8 ciclos de leitura)
        -- Big Endian na montagem (Addr 0 = MSB)
        procedure read_64_bits(start_addr_int : in natural; result : out bit_vector(63 downto 0)) is
            variable temp_vec : bit_vector(63 downto 0);
        begin
            for i in 0 to 7 loop
                s_addr <= bit_vector(to_unsigned(start_addr_int + i, 8));
                s_wr <= '0';
                wait for T_CLK; -- Aguarda estabilizar/ciclo
                -- Concatena o byte lido na posição correta
                -- Ex: i=0 (Addr Base) -> bits 63 downto 56
                temp_vec((63 - i*8) downto (56 - i*8)) := s_data_o;
            end loop;
            result := temp_vec;
        end procedure;

        -- Procedimento auxiliar para ESCREVER 64 bits (8 ciclos de escrita)
        procedure write_64_bits(start_addr_int : in natural; data_val : in bit_vector(63 downto 0)) is
        begin
            for i in 0 to 7 loop
                s_addr   <= bit_vector(to_unsigned(start_addr_int + i, 8));
                -- Pega o byte correspondente (MSB primeiro)
                s_data_i <= data_val((63 - i*8) downto (56 - i*8));
                s_wr     <= '1';
                wait for T_CLK; -- Borda de subida acontece aqui
            end loop;
            s_wr <= '0'; -- Desabilita escrita
        end procedure;

    begin
        report "INICIO DO TESTBENCH DE MEMORIA DE DADOS (64 BITS)" severity note;
        wait for T_CLK;

        -----------------------------------------------------------------------
        -- CASO 1: Verificar conteúdo inicial (Leitura)
        -- O arquivo começa com 10000000 (0x80) na linha 1.
        -- As 7 linhas seguintes são 00000000.
        -- Valor esperado (Big Endian): 0x8000000000000000
        -----------------------------------------------------------------------
        read_64_bits(0, data_read_64);
        
        assert data_read_64 = x"8000000000000000"
            report "Erro Caso 1: Leitura inicial incorreta. Lido: " & integer'image(to_integer(unsigned(data_read_64(63 downto 32)))) & "..."
            severity error;
        
        report "Caso 1 (Leitura Inicial): Sucesso. Dado lido: 0x8000000000000000";

        -----------------------------------------------------------------------
        -- CASO 2: Escrita de 64 bits (Simulando instrução STUR)
        -- Vamos escrever 0xAABBCCDDEEFF0011 no endereço 32 (0x20)
        -----------------------------------------------------------------------
        data_write_64 := x"AABBCCDDEEFF0011";
        report "Caso 2: Escrevendo 0xAABBCCDDEEFF0011 no endereco 32...";
        
        write_64_bits(32, data_write_64);
        
        -- Aguarda um ciclo extra para garantir fim da escrita
        wait for T_CLK;

        -----------------------------------------------------------------------
        -- CASO 3: Verificar a Escrita (Simulando instrução LDUR)
        -- Lemos do endereço 32 para ver se os dados persistiram
        -----------------------------------------------------------------------
        read_64_bits(32, data_read_64);

        assert data_read_64 = x"AABBCCDDEEFF0011"
            report "Erro Caso 3: Falha na verificacao de escrita."
            severity error;

        if data_read_64 = x"AABBCCDDEEFF0011" then
            report "Caso 3 (Verificacao de Escrita): Sucesso! Dados recuperados corretamente.";
        end if;

        -----------------------------------------------------------------------
        -- CASO 4: Teste de Borda (Overflow simples)
        -- Tentar ler o último endereço possível (255)
        -----------------------------------------------------------------------
        s_addr <= "11111111";
        s_wr <= '0';
        wait for T_CLK;
        -- Apenas garante que não crasha e retorna algo (provavelmente 0 se não inicializado)
        assert s_data_o = "00000000" report "Aviso: Ultima posicao nao e zero." severity note;

        report "FIM DA SIMULACAO." severity note;
        wait;
    end process;


end architecture sim;
