# :wrench: Testbench da memória de dados
A testagem da memória de dados envolve a testagem de partes fundamentais do seu comportamento, sendo necessário testar sua escrita síncrona, sua leitura assíncrona (combinacional), verificar a capacidade de guardar as entradas iniciais do .dat e a capacidade de apagar e sobrescrever dados, guardando seu resultado.
- Primeiro se verifica que os dados iniciais no .dat estão presentes na memória;
- Depois testa-se a escrita síncrona;
- Depois testa-se a tentativa de escrita com o write enable desativado, verificando se nenhuma escrita foi feita;
- Testa-se a leitura assíncrona;
- Testa-se a sobresscrição de um dado, escrevendo novo valor sobre um endereço antigo e verificando que guarda o novo valor eficazmente.