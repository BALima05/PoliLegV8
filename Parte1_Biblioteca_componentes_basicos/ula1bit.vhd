entity ula1bit is
    port (
        a         : in  bit;
        b         : in  bit;
        cin       : in  bit;
        ainvert   : in  bit;
        binvert   : in  bit;
        operation : in  bit_vector(1 downto 0);
        result    : out bit;
        cout      : out bit;
        overflow  : out bit
    );
end entity ula1bit;

architecture arch_ula1bit of ula1bit is
    signal a_final, b_final : bit;
    signal res_and, res_or, res_add, res_passb : bit;
    signal cout_int : bit;
begin
    -- Lógica de inversão das entradas
    a_final <= a when ainvert = '0' else not a;
    b_final <= b when binvert = '0' else not b;

    -- Operações básicas
    res_and   <= a_final and b_final; -- operacao 00
    res_or    <= a_final or b_final;  -- operacao 01
    res_passb <= b_final;             -- operacao 11 (Pass B)

    -- Instanciação do fulladder para a operação ADD (10) 
    adder: entity work.fulladder
        port map (
            a    => a_final,
            b    => b_final,
            cin  => cin,
            s    => res_add,
            cout => cout_int
        );

    -- Mux do resultado
    with operation select
        result <= res_and    when "00",
                  res_or     when "01",
                  res_add    when "10",
                  res_passb  when "11",
                  '0'        when others;

    cout <= cout_int;
    -- Overflow é cin XOR cout
    overflow <= cin xor cout_int;

end architecture arch_ula1bit;