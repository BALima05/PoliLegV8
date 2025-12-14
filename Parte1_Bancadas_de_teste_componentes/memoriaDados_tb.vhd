library ieee;
use ieee.numeric_bit.all;

entity memoriaDados_tb is
end entity memoriaDados_tb;

architecture behavior of memoriaDados_tb is
    constant ADDR_W : natural := 8;
    constant DATA_W : natural := 8;
    constant CLK_PERIOD : time := 10 ns;

    signal clk_tb  : bit := '0';
    signal wr_tb   : bit := '0';
    signal addr_tb : bit_vector(ADDR_W-1 downto 0) := (others => '0');
    signal d_in_tb : bit_vector(DATA_W-1 downto 0) := (others => '0');
    signal d_out_tb: bit_vector(DATA_W-1 downto 0);

begin
    dut: entity work.memoriaDados
        generic map (
            addressSize => ADDR_W,
            dataSize    => DATA_W,
            datFileName => "memDados_conteudo_inicial.dat"
        )
        port map (
            clock  => clk_tb,
            wr     => wr_tb,
            addr   => addr_tb,
            data_i => d_in_tb,
            data_o => d_out_tb
        );

    clk_process : process
    begin
        while now < 500 ns loop
            clk_tb <= '0'; wait for CLK_PERIOD/2;
            clk_tb <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- CASO 1: Verificação da Inicialização (ROM mode)
        -- Endereço 0 no ficheiro .dat: 10000000
        addr_tb <= "00000000";
        wait for 2 ns; -- Tempo para leitura assíncrona
        assert (d_out_tb = "10000000") 
            report "Erro: Inicializacao do endereco 0 falhou" severity error;

        -- Endereço 15 (0Fh) no ficheiro .dat: 00001001
        addr_tb <= "00001111";
        wait for 2 ns;
        assert (d_out_tb = "00001001") 
            report "Erro: Inicializacao do endereco 15 falhou" severity error;

        -- CASO 2: Escrita Síncrona
        wait until clk_tb = '0'; -- Prepara sinais na borda de descida
        addr_tb <= "00000001";   -- Endereço 1
        d_in_tb <= "11001100";
        wr_tb   <= '1';          -- Habilita escrita
        
        wait until clk_tb = '1'; -- Escrita ocorre aqui
        wait for 2 ns;
        assert (d_out_tb = "11001100") 
            report "Erro: Escrita falhou no endereco 1" severity error;
        wr_tb <= '0';

        -- CASO 3: Tentativa de Escrita Incorreta (Write Enable = 0)
        wait until clk_tb = '0';
        addr_tb <= "00000001";
        d_in_tb <= "00000000";   -- Tenta zerar, mas wr=0
        wr_tb   <= '0';
        
        wait until clk_tb = '1';
        wait for 2 ns;
        assert (d_out_tb = "11001100") 
            report "Erro: Memoria escreveu com wr='0'" severity error;

        -- CASO 4: Leitura Assíncrona (Mudar endereço sem clock)
        addr_tb <= "00000000"; -- Volta para o endereço 0
        wait for 1 ns;         -- A resposta deve ser quase imediata
        assert (d_out_tb = "10000000") 
            report "Erro: Leitura assincrona falhou" severity error;

        -- CASO 5: Sobrescrita de Dado Existente
        wait until clk_tb = '0';
        addr_tb <= "00001111"; -- Endereço que tinha 00001001
        d_in_tb <= "11111111";
        wr_tb   <= '1';
        wait until clk_tb = '1';
        wait for 2 ns;
        assert (d_out_tb = "11111111") 
            report "Erro: Sobrescrita falhou" severity error;
        wr_tb <= '0';

        report "Teste da Memória de Dados concluído com sucesso!";
        wait;
    end process;

end architecture behavior;