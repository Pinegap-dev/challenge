# Desafio Técnico 02

Esse é um desafio feito para conhecer um pouco mais de cada candidato, não se trata de um teste objetivo, capaz de gerar uma nota ou uma taxa de acerto, mas sim de um estudo de caso com o propósito de conhecer os seus conhecimentos, experiências e modo de trabalhar. Sinta-se livre para desenvolver a sua solução para o problema proposto.

## Descrição

Para esse desafio nós vamos assumir que você trabalha em uma empresa fictícia do ramo da bioinformática. Seu time está planejando o desenvolvimento de uma nova aplicação web que realiza análises de dados de espectrometria de massa para caracterização de proteínas. A aplicação em questão deverá permitir que o usuário faça o upload de diversos arquivos por amostra (um arquivo por proteína na amostra) a partir do navegador web. Múltiplos usuários poderão realizar a análise de diferentes amostras ao mesmo tempo. Espera-se que a aplicação suporta grande quantidade de usuários conectados ao mesmo tempo e que possua alta disponibilidade. A solução deve seguir as boas práticas de DevOps para ambientes de produção.

Seu objetivo neste desafio é propor uma arquitetura que abranja todos os recursos necessários para o provisionamento desta aplicação em um ambiente cloud, utilizando, em todas as etapas, ferramentas e serviços presentes na AWS. Abaixo temos mais informações sobre a aplicação e entregas esperadas ao final do desafio.

## Detalhes da Aplicação

Abaixo listamos os requisitos que a sua solução deve comportar para o ambiente da aplicação apresentada anteriormente. Detalhes adicionais da problemática também serão fornecidos a seguir.

- A aplicação em questão será separada em um front-end desenvolvido utilizando o framework Django do Python e uma API controladora do serviço desenvolvida utilizando o framework FastAPI, também do Python. O servidor da API e eventuais outros serviços que são gerenciados pela aplicação deverão ser implantados utilizando Kubernetes. As informações de usuários e análises realizadas deverão ser mantidas em um banco de dados relacional.
- Os arquivos de entrada deverão ficar disponíveis durante um ano, depois podem ser apagados.
- A parte da análise de espectrometria de massa será realizada de forma automatizada utilizando os serviços AWS Step Functions (Orquestração) e AWS Batch (Execução). Os arquivos finais devem ser armazenados no AWS S3. Os recursos serão invocados pela aplicação. O fluxo de análise será submetido por demanda de acordo com as solicitações realizadas na aplicação.
- Os arquivos de resultados das análises deverão estar disponíveis para consulta por 5 anos.

## Entrega

1. O documento deverá conter diagrama(s) da infraestrutura de forma a exemplificar a solução proposta. Deve também conter a descrição passo a passo do provisionamento da solução, bem como a descrição de possíveis soluções para mitigação de problemas que ferem as boas práticas de segurança e DevOps na nuvem.
2. Nós iremos agendar uma reunião com no máximo 1 hora de duração para que você apresente a arquitetura proposta (duração máxima da apresentação de 20 minutos). A apresentação deverá ser audiovisual (slides). Após a apresentação será feita uma sessão de perguntas e respostas.
3. Esteja preparado para perguntas relacionados a SRE como:

- Como você resolveria um problema em que a aplicação não está conseguindo acessar seu respectivo banco de dados?
- Como você faria o debug desse problema?
- Se achasse uma solução, como evitaria que isso acontecesse de novo?
- Como definir um SLO que faça sentido? Qual SLIs você usaria, e porque? Como você acompanharia o SLO?

Boa sorte!

**NÃO É NECESSÁRIO SUBIR O RECURSOS EM ALGUM CONTA AWS PRÓPRIA, SOMENTE A DESCRIÇÃO DOS PASSOS É NECESSÁRIA!**
