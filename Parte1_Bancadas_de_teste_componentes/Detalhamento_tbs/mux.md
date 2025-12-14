# :wrench: Implementação do MUX
Os testes do mux envolvem a verificação de comportamentos básicos de um MUX assíncrono, verificando o funcionamento do select e da passagem dos dados. Os casos testados são:
- Verificação da chave select:
  - Quando sel = 0, a saída deve ser = a in0;
  - Quando sel = 1, a saída deve ser = a in1;
- Mudar a entrada cuja chave está selecionada, a qual deve alterar a saída instantâneamente.
- Mudar a entradaque não está selecionada, o que não deve interferir com a saída.
- Alternar sel rapidamente para verificar as alternância na saída.