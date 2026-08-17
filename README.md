# Título do Projeto: ClearMoney
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## Descrição: 
Aplicativo multiplataforma (Android, iOS e Web) focado no controle financeiro pessoal, permitindo o rastreamento de gastos mensais por categorias e a visualização de dashboards intuitivos.
---
### 1. Mapeamento de Usuários
Nesta seção, identificamos quem interagirá com o sistema:
- Usuário Comum (Cidadão/Estudante): Pessoa física que utiliza o aplicativo para registrar suas receitas e despesas diárias, criar categorias de gastos e acompanhar o impacto financeiro no seu mês através de painéis gráficos.
- Administrador do Sistema (Opcional para o futuro): Responsável por gerenciar categorias globais padrão, manter a segurança da plataforma e analisar métricas anonimizadas de uso.
---
### 2. Requisitos Técnicos
Conforme as bases tecnológicas definidas para o projeto:
- Frontend: Interface responsiva e fluida construída com Dart e Flutter, garantindo compilação nativa para Android, iOS e adaptação para Web.
- Backend & API REST: Servidor (*tecnologia a ser definida*) para processamento das regras de negócio, cálculo de métricas dos dashboards e exposição de endpoints.
- Persistência de Dados: Banco de dados (*a ser definido em conjunto com o backend*) para armazenar histórico de transações, categorias e perfis de usuários.
- Validação: Implementação de regras para impedir registros com valores negativos ou datas inconsistentes, garantindo a integridade dos cálculos financeiros.
- Configuração por Ambiente: Uso de variáveis de ambiente no Flutter (ex: flutter_dotenv) para separar as conexões de desenvolvimento e produção.
---
### 3. Backlog Inicial
Uma lista priorizada de funcionalidades para guiar o desenvolvimento incremental:
- Autenticação de Usuário: Cadastro e login para manter a privacidade dos dados financeiros.  
- CRUD de Categorias e Subcategorias: Criar, listar, atualizar e deletar categorias de gastos (ex: Alimentação > Supermercado, Transporte > Combustível).  
- Registro de Transações: Fluxo principal para entrada de despesas e receitas, vinculadas a datas, valores e categorias.Dashboards e Relatórios: Visualização gráfica (gráficos de pizza/barras) sumarizando com o que o usuário está gastando no mês atual.
- Filtros de Pesquisa: Capacidade de buscar transações antigas por data, categoria ou palavra-chave. 
---
### 4. Protótipos de Integração(Wireframes)

---
### 5. Estrutura de Banco de Dados

Mesmo sem o backend definido, já deixamos o formato de comunicação (JSON) padronizado.
Exemplo de Endpoint: Resumo de Transações do Mês.

**Coleção Principal**: `usuarios`
Cada usuário terá um documento cujo ID é o seu UID de autenticação gerado pelo Firebase Auth.

- Caminho: `usuarios/{uid}`
- Dados do Documento: 
```
{
  "nome": "Ademar Neto",
  "email": "ademar@email.com",
  "dataCriacao": "2026-08-17T16:00:00Z"
}
```
**Subcoleção**: `transacoes`
Para facilitar as consultas e garantir que um usuário só veja os próprios dados, as transações ficarão dentro do documento do usuário.

- Caminho: `usuarios/{uid}/transacoes/{transacaoId}`
- Dados do Documento (Exemplo de Inserção/Leitura):
```
{
  "categoriaId": "cat_alimentacao",
  "tipo": "DESPESA",
  "valor": 150.50,
  "data": "2026-08-17",
  "descricao": "Compra no supermercado",
  "mesAno": "08-2026" 
}
```
---
### 6. Documentação de Fluxo e Regras de Segurança (Firestore Rules)
Como não há um servidor backend intermediário, a validação de regras de negócio será feita através das Regras de Segurança do Firebase:  
- Autenticação Obrigatória: O usuário só pode ler, criar, editar ou excluir documentos que estejam dentro do seu próprio `uid`.
- Validação de Dados: As regras garantirão que o campo `valor`  seja um número positivo e que o campo `tipo` aceite apenas "RECEITA" ou "DESPESA".
- Comunicação: O Frontend em Flutter utilizará os pacotes oficiais `firebase_core`, `firebase_auth` e `cloud_firestore` para realizar o CRUD diretamente no banco.
---
### 7. Modelagem e Casos de Uso
**Modelagem de Requisitos Detalhada:**  
- RF01 - Registrar Transação: O sistema deve persistir a despesa ou receita como um documento no Firestore, vinculado ao UID do usuário autenticado.
- RNF01 - Persistência em Tempo Real: A aplicação deve utilizar a capacidade real-time do Firestore para que, ao adicionar uma despesa, o dashboard seja recalculado e atualizado na interface sem necessidade de recarregar a tela.

**Casos de Uso Técnicos**  
Caso de Uso: UC01 - Registrar Gasto Mensal
- Ator: Usuário Comum.  
- Pré-condição: Usuário autenticado via Firebase Auth.  
- Fluxo Principal:  
   1. O usuário preenche os dados da transação no Flutter.
   2. O frontend valida os campos obrigatórios localmente.
   3. O aplicativo chama o método `.add()`  da coleção `transacoes`  no Firestore.
   4. As Firestore Rules validam a operação na nuvem.
   5. O documento é criado com sucesso.
   6. O StreamBuilder do Flutter detecta a mudança e atualiza o gráfico no dashboard automaticamente.
---
