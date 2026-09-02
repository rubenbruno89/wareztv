# SiteCloner Pro — Clone de alta fidelidade

- **Origem:** https://wareztvoficial.com.br/
- **Gerado em:** 2026-09-02T05:58:39.139Z
- **Escopo:** site (profundidade 3)
- **Arquivos:** 30  •  **Tamanho (descompactado):** 1372.0 KB
- **Captura:** rede real + HTML original

## Estrutura
```
/index.html          pagina principal (HTML renderizado)
/css/                folhas de estilo
/js/                 scripts
/assets/img/         imagens, icones, SVGs
/assets/fonts/       fontes web
/assets/media/       video/audio
/assets/runtime/     WASM e runtimes binarios
/assets/data/        JSON, manifests e dados de animacao
/pages/              outras paginas (modo site inteiro)
/AI_CONTEXT.md       briefing para reconstrucao por IA
/RELATORIO-DE-CAPTURA.txt  o que veio e o que faltou (linguagem simples)
/VALIDACAO-DE-ANIMACOES.txt  verificacao de scripts e recursos dinamicos
```

## Como usar
1. No Windows, extraia o ZIP e de dois cliques em `ABRIR-SITE.cmd`.
   O launcher inicia o servidor local, escolhe uma porta disponivel e abre o
   navegador automaticamente. Nao e necessario instalar ou configurar nada.
   Nao abra `index.html` diretamente: o protocolo `file://` bloqueia fetch,
   WASM, workers, Rive, modulos JavaScript e varias animacoes modernas.
2. Para recriar numa IA, abra o `AI_CONTEXT.md`: o topo traz um **prompt pronto** para colar (com a stack e a paleta ja preenchidas). Anexe este .zip na sua ferramenta (Lovable, v0, Bolt, Cursor, Claude, ChatGPT etc.) e cole o prompt.
3. Se algum arquivo faltar, abra o `RELATORIO-DE-CAPTURA.txt`: ele explica, em linguagem simples, o que nao veio e por que.

## Limitacoes conhecidas
- Captura apenas o **front-end entregue ao navegador**. Backend, banco e APIs privadas nao sao acessiveis.
- Backend, banco, login privado, WebSocket e APIs autenticadas continuam pertencendo ao servidor original.
- DRM, streaming protegido e recursos que nem a pagina original conseguiu carregar nao podem ser incorporados.
- Consulte `VALIDACAO-DE-ANIMACOES.txt` antes de considerar o clone completo.
- Modulos JavaScript modernos precisam do `ABRIR-SITE.cmd`; o duplo clique no `index.html` usa `file://` e bloqueia recursos.

## Assets que falharam
Nenhum. Captura completa.
