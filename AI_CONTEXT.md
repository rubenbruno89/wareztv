# ▶ COMECE AQUI — cole este prompt na sua IA

> Anexe o `.zip` (ou arraste a pasta descompactada) na sua ferramenta de IA favorita
> — Lovable, v0, Bolt, Cursor, Replit, Claude ou ChatGPT — e cole o texto abaixo.

---

Você é um engenheiro front-end sênior. Vou te entregar a **exportação estática de um site já existente** (arquivos HTML, CSS, JS e assets: imagens, fontes, ícones e mídia), gerada por uma extensão de clonagem. No pacote há um `AI_CONTEXT.md` com a stack, a paleta, a tipografia e a estrutura de seções da página.

- **Site de origem:** https://wareztvoficial.com.br/
- **Stack detectada na origem:** nao identificada
- **Paleta principal:** rgb(233, 240, 255), rgb(163, 178, 203), rgb(4, 16, 25), rgba(255, 255, 255, 0.06), rgba(4, 7, 15, 0.7), rgba(255, 255, 255, 0.04)
- **Tipografia:** Inter, Space Grotesk
- **Breakpoints:** 960px, 961px

**Objetivo:** reconstruir este site como um projeto limpo, editável e responsivo — fiel ao visual original, mas com código organizado que eu consiga evoluir.

Faça nesta ordem:
1. Leia o `AI_CONTEXT.md` e o `index.html` para entender layout, seções, paleta e fontes.
2. Recrie a página **seção por seção** (header, hero, conteúdo, rodapé) mantendo posição, proporções, espaçamentos, cores e tipografia o mais próximo possível do original.
3. Use os **assets do pacote** (`/assets`, `/css`, `/js`). Referencie as imagens, ícones, fontes e vídeos que vieram junto — não invente novos.
4. Estruture em **componentes reutilizáveis** (usando a stack que eu indicar, ou a padrão do seu ambiente). Priorize HTML semântico e acessibilidade: foco visível, `alt` nas imagens, bom contraste.
5. Deixe **responsivo**, respeitando os breakpoints acima.
6. **Mantenha os textos e o conteúdo reais** que estão no clone.
7. Onde houver formulário, login, busca ou dados que dependam de backend, deixe a interface pronta e marque com `TODO` — não invente backend.

Regras:
- Não adicione seções, páginas ou recursos que não existem no original.
- Na dúvida sobre algum detalhe, siga o que o `AI_CONTEXT.md` descreve.
- Entregue código limpo, com comentários onde ajudarem.

Depois de reconstruir fielmente, aplique as mudanças que eu quero:

```
[DESCREVA AQUI O QUE VOCÊ QUER MUDAR]
Exemplos:
- Trocar a paleta para as cores da minha marca (#______, #______).
- Reescrever o texto do hero para: "____________".
- Remover a seção de preços e adicionar uma seção de depoimentos.
- Adaptar o conteúdo para o meu produto: ____________.
```

Comece confirmando em 2-3 linhas o que você entendeu do site e da stack; depois mãos à obra.

---

# Briefing para reconstrucao por IA

Voce recebeu um clone **estatico** de uma pagina web. Use esta descricao como
REFERENCIA de layout e estilo para reconstruir a interface como componentes na
ferramenta/stack de sua preferencia. Nao trate os arquivos como import direto — o
objetivo e recriar fielmente o visual e a estrutura, com codigo limpo.

## Identidade da pagina
- **URL de origem:** https://wareztvoficial.com.br/
- **Titulo:** WAREZtv Oficial | App para Smart TV, TV Box e Android
- **Descricao:** Conheça o WAREZtv Oficial, app compatível com Smart TV, TV Box e Android, com suporte via WhatsApp, ativação rápida e orientação de instalação.
- **Idioma:** pt-BR
- **Viewport:** width=device-width, initial-scale=1.0

## Paleta de cores (mais frequentes)
- `rgb(233, 240, 255)`
- `rgb(163, 178, 203)`
- `rgb(4, 16, 25)`
- `rgba(255, 255, 255, 0.06)`
- `rgba(4, 7, 15, 0.7)`
- `rgba(255, 255, 255, 0.04)`

## Tipografia
- Inter
- Space Grotesk

## Breakpoints observados
960px, 961px

## Estrutura / secoes (na ordem do DOM)
1. <header> · 1 blocos filhos
2. <nav> · 1 blocos filhos
3. <main> — "Uma experiência de app mais simples e organizada" · 1 blocos filhos
4. <section> — "Uma experiência de app mais simples e organizada" · 3 blocos filhos
5. <section> — "Páginas rápidas para cada necessidade" · 2 blocos filhos
6. <section> — "Planos simples com suporte dedicado" · 3 blocos filhos
7. <section> — "Revenda WAREZtv Oficial" · 2 blocos filhos
8. <section> — "Dúvidas frequentes" · 2 blocos filhos
9. <footer> · 1 blocos filhos

## Outline de titulos
- H1: WAREZtv Oficial: app para Smart TV, TV Box e Android
- H3: Interface simples e organizada
- H2: Uma experiência de app mais simples e organizada
- H3: Qualidade de imagem
- H3: Estabilidade
- H3: Compatibilidade com dispositivos populares
- H3: Suporte próximo
- H3: Guia e funções extras
- H3: Configuração assistida
- H2: Páginas rápidas para cada necessidade
- H2: Planos simples com suporte dedicado
- H3: 1 Tela
- H3: 2 Telas
- H3: Família
- H2: Revenda WAREZtv Oficial
- H3: Para quem é a revenda?
- H3: Vantagens para o revendedor
- H3: Como funciona na prática?
- H2: Dúvidas frequentes
- H3: Pronto para testar a WAREZtv Oficial?

## Contagem de elementos
- Imagens: 6 · Links: 29 · Scripts: 6 · Formularios: 0

## Instrucao sugerida para a IA
> Reconstrua esta pagina como uma interface responsiva, seguindo a paleta, a
> tipografia e a ordem de secoes acima. Priorize semantica, acessibilidade e
> codigo limpo. Consulte os arquivos HTML/CSS do clone para detalhes visuais.
