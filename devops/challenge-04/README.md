# Desafio Técnico DevOps

Este é um desafio criado para conhecermos um pouco mais sobre cada candidato. Não se trata de um teste objetivo, capaz de gerar uma nota ou taxa de acerto, mas sim de um estudo de caso com o propósito de avaliar seus conhecimentos, experiências e modo de trabalhar. Sinta-se à vontade para desenvolver sua solução para o problema proposto.

## Descrição do desafio

Para esse desafio nós vamos assumir que você trabalha em uma empresa fictícia do ramo da bioinformática, neste contexto, denominada por biotech-X. Seu time está planejando o desenvolvimento de uma nova aplicação web que realiza filtro, classificação e análises de dados de espectrometria de massa para caracterização de proteínas. A aplicação em questão deverá permitir que o usuário faça o upload de diversos arquivos por amostra (um arquivo por proteína na amostra) a partir do navegador web. Múltiplos usuários poderão realizar a o filtro, classificação e análise de diferentes amostras ao mesmo tempo. Espera-se que a aplicação seja projetada para suportar grande quantidade de usuários conectados ao mesmo tempo, possua alta disponibilidade, com seus custos otimizados e boas práticas de segurança aplicadas.

Como premissa, considere que a aplicação é composta por: front-end desenvolvido com o framework Next.js (JavaScript), back-end com uma API controladora do serviço desenvolvida em FastAPI (Python). O servidor da API e eventuais outros serviços gerenciados pela aplicação deverão ser implantados utilizando Kubernetes. As informações de usuários e análises realizadas serão mantidas em um banco de dados relacional.

A política de retenção de arquivos da biotech-X determina que os dados devem estar disponíveis com acesso imediato durante 365 dias, podendo ser excluídos após 365 dias. A análise de espectrometria de massa será realizada de forma automatizada utilizando AWS Step Functions (orquestração) e AWS Batch (execução). Os arquivos finais devem ser armazenados no AWS S3, invocados pela aplicação. O fluxo de análise será submetido sob demanda, conforme as solicitações na aplicação. Os arquivos de resultados das análises deverão estar disponíveis para consulta por 5 anos.

Seu objetivo é propor uma arquitetura completa para o provisionamento da aplicação em ambiente cloud, priorizando serviços e ferramentas AWS em todas as etapas, com ênfase em boas práticas DevOps. Isso inclui:
* Criação de diagrama(s) ilustrativo(s) da infraestrutura proposta;
* Descrição passo a passo do provisionamento;
* Soluções para mitigar problemas de segurança e DevOps na nuvem.

Adicionalmente, você deve:

* Elaborar e reforçar o fluxo de desenvolvimento do repositório, consolidando boas práticas via ferramentas de análise estática, hooks de pré-commit e similares (a seu critério);
* Codificar em único arquivo Terraform a definição dos recursos essenciais (sem módulos personalizados, desconsiderando serviços sem módulos públicos disponíveis);
* Construir pipelines de CI/CD com GitHub Actions para deploy em homologação e produção, integrados ao fluxo de desenvolvimento;
* Documentar integralmente o processo, as pipelines e o fluxo do repositório, hospedando tudo em uma página do GitHub Pages, com sustentação via IaC e automação de workflows

## O que iremos avaliar

1. **Completude**: A solução proposta atende a todos os requisitos do desafio?
2. **Simplicidade**: A solução proposta é simples e direta? É fácil de entender e trabalhar?
3. **Organização**: A solução proposta é organizada e bem documentada? É fácil de navegar e encontrar o que se procura?
4. **Criatividade**: A solução proposta é criativa? Apresenta uma abordagem inovadora para o problema proposto?
5. **Boas práticas**: A solução proposta segue boas práticas de Python, Git, Docker, etc.?

## Atenção

1. Entrega: Realize um fork deste repositório e envie o link do seu repositório até a data limite estipulada no e-mail recebido.
2. Agendaremos uma reunião de no máximo 1 hora para que você apresente a arquitetura proposta (duração máxima da apresentação: 20 minutos). A apresentação deverá ser audiovisual (slides). Após ela, haverá uma sessão de perguntas e respostas.
3. Esteja preparado para perguntas relacionadas a SRE, como:
   * Como você resolveria um problema em que a aplicação não consegue acessar seu banco de dados?
   * Como faria o debug desse problema?
   * Se encontrasse uma solução, como evitaria que isso acontecesse novamente?
   * Como definiria um SLO que faça sentido? Quais SLIs usaria e por quê? Como acompanharia o SLO?

## Dúvidas?

Entre em contato diretamente com o e-mail:

**NÃO É NECESSÁRIO PROVISIONAR OS RECURSOS EM CONTA AWS PRÓPRIA. NECESSÁRIO APENAS OS ARQUIVOS PRESENTES NO SEU REPOSITÓRIO.**
