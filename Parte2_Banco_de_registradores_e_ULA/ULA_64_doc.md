# :wrench: Implementação da testbench da ULA de 64 bits

A implemetação da testbench da ULA de 64 bits envolve a testagem do funcionamento adequado de suas operações e de casos extraóridinários, além de testar se as flags (sinalizadores de estado) estão funcionando corretamente, garantindo seu funcionamento adequado e evitando problemas em situações específicas. Dessa maneira, a rotina de testes segue os seguintes casos:
- Caso 1 - Teste da operação AND:
  - A entrada A é colocada toda em '1', portanto a saída deverá ser uma cópia da entrada B. Assim, colocamos a B com metade superior dos bits igual a '0', enquanto que a outra metade é '1', e esperamos que a saída retorne a mesma coisa.
  - Verifica-se também se a flag de zero permanece em '0', já que a saída não é zero.
- Caso 2 - Teste da operação OR:
  - Colocamos A com um padrão alternado "1010..." e B com um padrão alternado inverso "0101...". Dessa forma, todos os bits da saída devem estar em '1'.
  - Isso garante que nenhum bit está preso em zero e que o OR está funcionando corretamente para todos os bits;
- Caso 3 - Teste da operação ADD:
  - Primeiro testamos o somador completo de forma simples, sem nennuma complicação, para garantir que o fullader está funcionando corretamente através dos 64 bits;
- Caso 4 - ADD com overflow:
  - Testamos a flag overflow e assim a detecção de erros em números com sinais (complemento de 2);
  - Colocamos em A o maior número possível em 64 bits, ou seja, "011111...". Em B, colocamos o número 1. A soma dos dois deve retornar "1000..." que é um número negativo, impossível para o nosso caso. Assim, a flag de overflow deve ficar em '1'.
- Caso 5 - SUB:
  - Aqui, testaremos a subtração e a flag de zero conjuntamente, colocando como entradas em ambos A e B como 15 e escolhendo a operação subtração. De tal maneira, o resultado esperado deve ser zero.
  - A flag de zero deve se tornar '1', acusando o resultado zero.
- Caso 6 - SUB com resultados negativos:
  - É crucial que durante a subtração, pela possibilidade de resultados negativos, o resultado em complemento de 2 seja exibido corretamente. Portanto, fazemos 10 - 20 e conferimos se o resultado condiz exatamente com a assinatura de -10 ("FFFFFFFFFFFFFFF6").
- Caso 7 - Pass B:
  - Passamos para A "000..." e para B qualquer valor, verificando se a saída é exatamente igual a B, ignorando a entrada A;
- Caso 8 - Operação NOR:
  - Enviamos ambas as entradas A e B como todas '0' ("00000..."). Assim, a saída deve ser todos os bits '1' ("11111..."). Isso testa se todos os sinais de inversão de entrada (ainvert e binvert) estão sendo ativados corretamente;

Se todos esses testes passarem, isso significa que as conexões bit-a-bit em príncipio estão corretas, o carry está sendo propagado corretamente desde o bit 0 ao 63, a lógica de inversão está funcionando e as flags de status estão operacionais, garantindo que os comportamentos fundamentais da ULA de 64 bits estão funcionais.