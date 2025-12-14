entity reg_tb is
end entity reg_tb;

architecture behavior of reg_tb is
    -- Constante para definir o tamanho do registrador nos testes
    constant N : natural := 8; 
    constant clock_period : time := 10 ns;

    -- Sinais internos para conectar ao componente
    signal clk_tb    : bit := '0';
    signal reset_tb  : bit := '0';
    signal enable_tb : bit := '0';
    signal d_tb      : bit_vector(N-1 downto 0) := (others => '0');
    signal q_tb      : bit_vector(N-1 downto 0);

begin
    -- Instanciação da Unidade Sob Teste (DUT)
    dut: entity work.reg
        generic map (dataSize => N) -- [cite: 1]
        port map (
            clock  => clk_tb,    -- [cite: 2]
            reset  => reset_tb,  -- [cite: 2]
            enable => enable_tb, -- [cite: 2]
            d      => d_tb,      -- [cite: 2]
            q      => q_tb       -- [cite: 2]
        );

    -- Processo de Geração de Clock
    clk_process : process
    begin
        while now < 200 ns loop -- Limita o tempo de simulação
            clk_tb <= '0';
            wait for clock_period/2;
            clk_tb <= '1';
            wait for clock_period/2;
        end loop;
        wait;
    end process;

    -- Processo de Estímulos (Testes)
    stim_proc: process
    begin
        -- Caso 1: Teste de Reset Assíncrono
        reset_tb <= '1';
        wait for 15 ns; 
        assert (q_tb = (q_tb'range => '0')) report "Erro: Reset falhou" severity error;
        reset_tb <= '0';
        wait for 10 ns;

        -- Caso 2: Tentativa de escrita com Enable em '0'
        d_tb <= "10101010";
        enable_tb <= '0';
        wait until clk_tb = '1'; -- Espera borda de subida 
        wait for 2 ns; -- Pequeno atraso para estabilização
        assert (q_tb /= d_tb) report "Erro: Registrador escreveu com enable desativado" severity error;

        -- Caso 3: Escrita bem-sucedida (Enable = '1')
        enable_tb <= '1';
        wait until clk_tb = '1'; -- 
        wait for 2 ns;
        assert (q_tb = "10101010") report "Erro: Falha na escrita do dado" severity error;

        -- Caso 4: Verificação de Retenção de Dado
        enable_tb <= '0';
        d_tb <= "11110000"; -- Muda a entrada, mas enable está desligado
        wait until clk_tb = '1';
        wait for 2 ns;
        assert (q_tb = "10101010") report "Erro: Dado mudou sem enable" severity error;

        -- Caso 5: Reset durante operação (Assíncrono)
        wait for 5 ns;
        reset_tb <= '1';
        wait for 2 ns; -- Reset deve agir imediatamente, sem esperar clock
        assert (q_tb = (q_tb'range => '0')) report "Erro: Reset assíncrono falhou no meio da operação" severity error;
        reset_tb <= '0';

        report "Simulação concluída com sucesso!";
        wait;
    end process;

end architecture behavior;
