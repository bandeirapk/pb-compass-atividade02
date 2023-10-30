# Atividade 02 - Trilha de DevSecOps

![Logo Horizontal da Compass Uol](./assets/image.png)

> Atividade sobre Docker que pertence a trilha de DevSecOps do Programa de bolsas da Compass UOL.

## Descrição da atividade

![Cenário da atividade](./assets/infraestrutura.png)

> Requisitos da atividade:

- instalação e configuração do DOCKER ou CONTAINERD no host EC2;
  - Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh).
- Efetuar Deploy de uma aplicação Wordpress com:
  - container de aplicação RDS
  - database Mysql.
- Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;
- Configuração do serviço de Load Balancer AWS para a aplicação Wordpress;

## Execução da atividade

> ### Passo 1: Criação e configuração da VPC

- No console da AWS, busque por `VPC` ![Procura pela VPC](./assets/searchVPC.png)
- Em seguida, clique em `Criar VPC`
- Na tela de criação da VPC, preencha os campos conforme é necessário, lembre-se de fazer a criação das subnets e da tabela de rota.
- Após a criação da VPC, vá até o menu de `NAT Gateways` e crie um NAT Gateway para a VPC criada.
- ATENÇÃO: Não esqueça de colocar o NAT em uma subnet pública;
- Após a criação do NAT, vá até o menu de `Route Tables` e crie uma tabela de rotas para as subnets privadas para o NAT Gateway criado. ![Rota para o NAT](./assets/routeToNAT.png)
- Para verificar se sua VPC está correta, vá em `Suas VPCS` e selecione a VPC criada e verifique o resource map, como na imagem a seguir: ![Resource map AWS](./assets/resourcemap.png)

> ### Passo 2: Criação e configuração do Security Groups

- No menu EC2 procure por `Security groups` na barra de navegação à esquerda.

- Acesse e clique em `Criar novo grupo de segurança`, e crie os grupos de segurança a seguir

#### SG-ALB

| Type | Protocol | Port Range | Source Type | Source    |
| ---- | -------- | ---------- | ----------- | --------- |
| SSH  | TCP      | 22         | Anywhere    | 0.0.0.0/0 |
| HTTP | TCP      | 80         | Anywhere    | 0.0.0.0/0 |
| ICMP | ICMP     | ALL        | Anywhere    | 0.0.0.0/0 |

#### SG-EC2

| Type | Protocol | Port Range | Source Type | Source |
| ---- | -------- | ---------- | ----------- | ------ |
| SSH  | TCP      | 22         | Anywhere    | SG-ALB |
| HTTP | TCP      | 80         | Custom      | SG-ALB |

#### SG-EFS

| Type | Protocol | Port Range | Source Type | Source |
| ---- | -------- | ---------- | ----------- | ------ |
| NFS  | TCP      | 2049       | Anywhere    | SG-ALB |

#### SG-RDS

| Type         | Protocol | Port Range | Source Type | Source |
| ------------ | -------- | ---------- | ----------- | ------ |
| MYSQL/Aurora | TCP      | 3306       | Anywhere    | SG-ALB |

> ### Passo 3: Criando o EFS

- Busque por `EFS` na Amazon AWS o serviço de arquivos de NFS escalável da AWS.

- Na Página de EFS clique em `Criar sistema de arquivos`.

![Create File System](./assets/efs.png)

- Clique em personalizar.

![EFS Personalizar](./assets/efsCustomize.png)

- Selecione o SG criado para o EFS e finalize a criação.

![EFS SG](./assets/sgEFS.png)

> ### Passo 4: Criando o RDS

- Busque por RDS na Amazon AWS.

- Na página de RDS clique em `Create database`.

- Escolha o método de criação

![Criando o RDS](./assets/createRDS.png)

- Em `Engine options` selecione **MySQL**

![Selecionando o SGBD](./assets/mysqlVersion.png)

- Em `Templates` selecione **Free tier**

![Tipo de template](./assets/templateType.png)

- Em `Settings` dê um nome identificador para o **DB**.
- Escolha um `username`.
- Escolha uma `senha`.

![Configurações do RDS](./assets/settingsDB.png)

- Determine o tipo da instância e o tamanho do armazenamento em `Storage`.

![Configurações do RDS](./assets/instanceConfiguration.png)

- Selecione a VPC criada.
- Deixe o acesso publico como **NO**
- Selecione o **SG-RDS**.

![Configurações de Network do RDS](./assets/networkConfiguration.png)

- Vá em `Configurações Adicionais` e crie uma database inicial.

![Criação de uma Database inicial](./assets/createInitialDB.png)

> ### Passo 5: Criando o template do EC2

- Na AWS busque por EC2
- No menu de EC2 clique em Modelos de Execução.
- Vá em `Criar modelo de execução`.
- Configure o template com forme solicitado.
- No campo advanced details vá até o quadro do User data copie e cole o user_data.sh.

![Detalhes Avançados](./assets/details.png)

> ### Passo 6: Criando o Target group

- No menu EC2 procure por `Grupos de destino` na barra de navegação à esquerda.
- Acesse e clique em `Criar grupo de destino`.

- Em `Escolha um tipo de destino` clique em `Instâncias`.
- Nomeie o grupo de destino.
- Em `Protocolo` mantenha `HTTP` e em `Porta` mantenha a porta `80`.
- Como `VPC` selecione a VPC criada anteriormente.
- Mantenha a `Versão do protocolo` como `HTTP1`.
- A seguir clique em `Próximo`.
- Na página de `Registrar destinos` não selecione nenhuma instância.
- Selecione `Criar grupo de destino`.
