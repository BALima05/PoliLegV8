library ieee;
use ieee.numeric_bit.all;

entity tb_polilegv8 is
end entity tb_polilegv8;

architecture simulation of tb_polilegv8 is

    -- Declaração do componente a ser testado (DUT)
    component polilegv8 is 
        port ( 
           clock : in bit; 
           reset : in bit
           -- Se você adicionou portas de debug, declare-as aqui também
         );
    end component; 

    -- Sinais de teste
    signal s_clock : bit := '0';
    signal s_reset : bit := '0';

    -- Constantes de simulação
    constant CLK_PERIOD : time := 10 ns; -- Clock de 100 MHz
    
begin

    -- Instanciação do Processador (DUT)
    uut: polilegv8 
        port map (
            clock => s_clock,
            reset => s_reset
        );

    -- Processo de geração de Clock
    p_clock: process
    begin
        s_clock <= '0';
        wait for CLK_PERIOD / 2;
        s_clock <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulo (Reset e Execução)
    p_stimulus: process
    begin
        report "Inicio da Simulacao do Processador LEGv8";

        -- 1. Reset inicial para garantir estado conhecido (PC = 0)
        s_reset <= '1';
        wait for CLK_PERIOD * 2; 
        
        -- 2. Solta o reset e deixa o processador rodar
        s_reset <= '0';
        report "Reset liberado. Executando programa da memoria de instrucoes...";

        -- O programa da imagem tem cerca de 12 instruções até o loop final.
        -- Vamos rodar por tempo suficiente para cobrir todas as instruções e o desvio.
        -- LDURs (4) + ARIT (5) + CBZ + STURs + Loops
        wait for CLK_PERIOD * 30; 

        -- 3. Fim da simulação
        report "Fim do tempo de execucao programado.";
        
        wait;
    end process;

end architecture simulation;