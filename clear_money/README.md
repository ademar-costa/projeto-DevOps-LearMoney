# Título do Projeto: ClearMoney
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white) ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## Descrição 
Aplicativo multiplataforma (Android, iOS e Web) focado no controle financeiro pessoal, permitindo o rastreamento de gastos mensais por categorias e a visualização de dashboards intuitivos.
---
### Mapeamento de Usuários
Nesta seção, identificamos quem interagirá com o sistema:
- Usuário Comum (Cidadão/Estudante): Pessoa física que utiliza o aplicativo para registrar suas receitas e despesas diárias, criar categorias de gastos e acompanhar o impacto financeiro no seu mês através de painéis gráficos.
- Administrador do Sistema (Opcional para o futuro): Responsável por gerenciar categorias globais padrão, manter a segurança da plataforma e analisar métricas anonimizadas de uso.
---
### Requisitos Técnicos
Conforme as bases tecnológicas definidas para o projeto:
- Frontend: Interface responsiva e fluida construída com Dart e Flutter, garantindo compilação nativa para Android, iOS e adaptação para Web.
- Backend & API REST: Servidor (*tecnologia a ser definida*) para processamento das regras de negócio, cálculo de métricas dos dashboards e exposição de endpoints.
- Persistência de Dados: Banco de dados (*a ser definido em conjunto com o backend*) para armazenar histórico de transações, categorias e perfis de usuários.
- Validação: Implementação de regras para impedir registros com valores negativos ou datas inconsistentes, garantindo a integridade dos cálculos financeiros.
- Configuração por Ambiente: Uso de variáveis de ambiente no Flutter (ex: flutter_dotenv) para separar as conexões de desenvolvimento e produção.
---
### Backlog Inicial
Uma lista priorizada de funcionalidades para guiar o desenvolvimento incremental:
- Autenticação de Usuário: Cadastro e login para manter a privacidade dos dados financeiros.  
- CRUD de Categorias e Subcategorias: Criar, listar, atualizar e deletar categorias de gastos (ex: Alimentação > Supermercado, Transporte > Combustível).  
- Registro de Transações: Fluxo principal para entrada de despesas e receitas, vinculadas a datas, valores e categorias.Dashboards e Relatórios: Visualização gráfica (gráficos de pizza/barras) sumarizando com o que o usuário está gastando no mês atual.
- Filtros de Pesquisa: Capacidade de buscar transações antigas por data, categoria ou palavra-chave. 
---
### Protótipos de Integração(Wireframes)

---
### Estrutura de Banco de Dados

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
### Documentação de Fluxo e Regras de Segurança (Firestore Rules)
Como não há um servidor backend intermediário, a validação de regras de negócio será feita através das Regras de Segurança do Firebase:  
- Autenticação Obrigatória: O usuário só pode ler, criar, editar ou excluir documentos que estejam dentro do seu próprio `uid`.
- Validação de Dados: As regras garantirão que o campo `valor`  seja um número positivo e que o campo `tipo` aceite apenas "RECEITA" ou "DESPESA".
- Comunicação: O Frontend em Flutter utilizará os pacotes oficiais `firebase_core`, `firebase_auth`  e `cloud_firestore` para realizar o CRUD diretamente no banco.
---
### Modelagem e Casos de Uso
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
### Arquitetura
O sistema seguirá uma arquitetura **baseada em BaaS (Backend as a Service)**, utilizando serviços gerenciados em nuvem para descentralizar a lógica do servidor tradicional.

- Padrão Arquitetural no Frontend: Utilizaremos uma arquitetura baseada em Features (Módulos) ou Clean Architecture adaptada para o Flutter, separando claramente a Interface de Usuário (UI), a Gerência de Estado e a Camada de Dados (Integração com Firebase).
---
### Stack Tecnológica
- Frontend: Desenvolvido em Dart com o framework Flutter, garantindo a criação de uma interface responsiva, com compilação nativa para Android, iOS e Web a partir de um único código-fonte.
- Backend / BaaS: Utilização da plataforma Firebase.
  - Autenticação: Firebase Authentication (Login por e-mail/senha e Google).
  - Persistência de Dados: Cloud Firestore (Banco de dados NoSQL orientado a documentos).
- Gerenciamento de Estado: (Sugestão: `Provider`, `Riverpod` ou `BLoC`) para gerenciar a reatividade do aplicativo quando os dados financeiros forem atualizados.
---
### Organização do Repositório
O repositório do aplicativo será organizado para facilitar a manutenção e escalabilidade do código fonte. O diretório principal `/lib`  do Flutter seguirá a seguinte divisão:
- `/lib/models`: Classes de dados que representam as entidades (ex: `transacao_model.dart`, `categoria_model.dart`).
- `/lib/screens`: Telas e componentes visuais de interface do usuário (ex: `dashboard_screen.dart`).
- `/lib/services`: Classes responsáveis por comunicar com o Firebase (ex: `firestore_service.dart`).
- `/lib/utils`: Funções auxiliares, como formatação de moeda (R$) e datas.
- `/docs`: Documentação técnica do projeto, incluindo este README e os protótipos de tela.
---
### Estratégia de Persistência e Integração
- Camada de Dados: Uso de pacotes oficiais (SDKs) do Firebase para Dart (`cloud_firestore`) para realizar a comunicação direta e segura com o banco NoSQL. Não haverá a necessidade de um ORM tradicional, pois os dados serão convertidos de/para JSON diretamente através de métodos como `fromJson`  e `toJson`  nos modelos.
- Variáveis de Ambiente: O projeto usará o arquivo `.env` para gerenciar chaves de API e configurações de ambiente, garantindo que credenciais sensíveis não fiquem expostas no código público.
---
### Defesa de Decisões Técnicas
- Por que Flutter e Dart? A escolha de um framework híbrido de alta performance elimina a necessidade de criar três projetos separados (um para web, um para Android e outro para iOS). Isso permite construir e distribuir a aplicação de forma rápida e otimizada.
- Por que Firebase (Firestore)? A adoção de um banco NoSQL em tempo real justifica-se pela necessidade de refletir instantaneamente as transações financeiras nos dashboards do usuário. Além disso, essa stack reduz os custos com infraestrutura inicial, permitindo o desenvolvimento de tecnologias que realmente façam a diferença na sociedade, com foco total no impacto e acessibilidade, sem depender de arquiteturas comerciais complexas e custosas logo na primeira versão do sistema.
---