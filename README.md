# DE Case | Projeto de Alertas do CEMADEN (Centro Nacional de Monitoramento e Alertas de Desastres Naturais)

## Objetivo

O objetivo deste projeto é criar um *mockup* de um sistema de alertas de desastres naturais utilizando dados do CEMADEN (Centro Nacional de Monitoramento e Alertas de Desastres Naturais) e de outras fontes de dados.

## Descrição

Neste projeto iremos explorar alguns conceitos de Engenharia de Dados como ingestão, transformação e visualização de dados. O projeto será dividido em 3 etapas principais:

## 1. Ingestão de Dados

Nesta etapa, o objetivo é coletar dados de pluviometria de diversas estações meteorológicas fornecidos pelo CEMADEN. Utilizamos uma função Lambda para realizar a ingestão dos dados, que são obtidos através de uma requisição HTTP para a API do CEMADEN. Os dados são então processados e armazenados em um banco de dados DuckDB.

### Detalhes da Implementação

- **Função Lambda**: A função Lambda é responsável por fazer a requisição HTTP para a API do CEMADEN, processar os dados recebidos e armazená-los no DuckDB.
- **Decoração de Funções**: Utilizamos um decorador `timeit` para medir o tempo de execução das funções principais (`get_data`, `insert_data`, `create_table` e `main`).
- **Processamento de Dados**: Os dados recebidos são convertidos para um DataFrame do Pandas, onde são realizadas algumas transformações, como a substituição de valores nulos e a conversão de timestamps.
- **Armazenamento de Dados**: Os dados processados são então inseridos em uma tabela DuckDB chamada `pluviometria`.

### Fluxo de Trabalho

1. **Conexão ao DuckDB**: A função Lambda se conecta a um banco de dados DuckDB, que pode ser em memória ou baseado em arquivo.
2. **Criação da Tabela**: Se a tabela `pluviometria` não existir, ela é criada.
3. **Coleta de Dados**: Para cada unidade federativa (UF) do Brasil, a função Lambda faz uma requisição à API do CEMADEN para obter os dados de pluviometria.
4. **Inserção de Dados**: Os dados coletados são inseridos na tabela `pluviometria`.
5. **Consulta de Dados**: Após a inserção, é possível realizar consultas na tabela para visualizar os dados ou identificar eventos de interesse, como chuvas intensas.

### Exemplo de Uso

A função Lambda pode ser configurada para ser executada periodicamente, garantindo que os dados de pluviometria estejam sempre atualizados. Além disso, a função pode ser integrada a um sistema de alertas que notifica quando certos critérios são atendidos, como um acumulado de chuva superior a 80mm em 24 horas.
