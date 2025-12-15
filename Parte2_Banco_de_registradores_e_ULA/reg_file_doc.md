# :wrench: Implementação da testbench do Banco de Registradores

A testagem do banco de registradores envolve garantir o funcionamento de seus comportamentos básicos, tendo a certeza de que as especificações do projeto estão sendo seguidas. Isso envolve escrita, leitura e sobrescrita, além da verificação do funcionamento do XZR. A rotina de testes segue o seguinte roteiro:
- Reset global de todos os registradores;
- Escrever em dois registradores diferentes (nesse caso X1 e X2);
- Leitura dos dois registradores, garantindo a funcionalidade da leitura e que a escrita funcionou;
- Verificação os comportamentos do XZR, tentando escrever neste e depois lendo o seu valor;
- Testar sobrescrever sobre um registrador que já possuia um valor, garantindo que o novo dado será armazenado;

Com estes testes, será possível verificar a funcionalidade das principais funções do banco de registradores de armazenar dados síncronamente e ler assíncronamente, além do funcionamento correto do XZR, garantindo que este sempre retornará valor 0 e nunca podera ter nenhum valor escrito sobre ele.