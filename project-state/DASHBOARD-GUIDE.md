# 🎨 Dashboard - Guia Rápido

## ✅ Dashboard Standalone - Pronto para Usar!

O dashboard agora funciona **diretamente no navegador** sem precisar de servidor HTTP!

### 🚀 Como Usar

#### Opção 1: Usar com Dados de Exemplo (Imediato)

1. **Abra o arquivo** `dashboard.html` diretamente no seu navegador
2. Pronto! O dashboard já vai mostrar dados de exemplo

#### Opção 2: Usar com Seus Dados Reais

1. **Abra** `dashboard.html` no navegador
2. **Clique** em "🔧 Atualizar Dados (Opcional)"
3. **Cole** o conteúdo dos seus arquivos:
   - `current-sprint.json` (obrigatório)
   - `task-log.jsonl` (opcional)
4. **Clique** em "✅ Atualizar Dashboard"
5. Pronto! Seus dados serão exibidos

### 📊 O Que o Dashboard Mostra

- **Header**: Nome do projeto e data de atualização
- **Sprint Info**: Número, período, objetivo e % de progresso
- **Métricas**: 4 cards com totais (tasks, concluídas, em progresso, story points)
- **Gráficos**:
  - Pizza: Distribuição de tasks por status
  - Barras: Velocity por agente
- **Kanban Board**: 4 colunas visuais (TODO, IN_PROGRESS, DONE, BLOCKED)
- **Team View**: Cards por agente com progresso e velocity
- **Activity Log**: Últimos 15 eventos do projeto

### 🎨 Recursos Visuais

- ✅ Design moderno com Tailwind CSS
- ✅ Responsivo (funciona em mobile)
- ✅ Cores por prioridade (P0=vermelho, P1=amarelo, P2=azul)
- ✅ Gráficos interativos com Chart.js
- ✅ Animações suaves

### 🔄 Atualizar Dashboard

**Método 1: Cole Novos Dados**
- Use o botão "🔧 Atualizar Dados" e cole JSONs atualizados

**Método 2: Com Servidor HTTP (para auto-refresh)**
```bash
# No diretório project-state
python -m http.server 8000

# Acesse: http://localhost:8000/dashboard.html
```

Neste caso, o dashboard vai carregar os arquivos JSON automaticamente e você pode editá-los que o dashboard recarrega ao dar F5.

### ❓ Solução de Problemas

**Dashboard sem formatação:**
- Certifique-se de ter internet (Tailwind CSS é carregado de CDN)
- Tente em outro navegador (Chrome, Firefox, Edge)

**Erro ao atualizar dados:**
- Verifique se o JSON está válido
- Use um validador online: https://jsonlint.com
- Certifique-se de colar o conteúdo COMPLETO dos arquivos

**Gráficos não aparecem:**
- Verifique conexão com internet (Chart.js é carregado de CDN)
- Limpe cache do navegador (Ctrl+F5)

### 💡 Dicas

- O dashboard mantém os dados em memória - se fechar a aba, precisa colar novamente
- Para apresentações, tire screenshot ou grave a tela
- Para relatórios, use "Imprimir" no navegador (Ctrl+P)
- Os dados de exemplo são do Sprint 12 do projeto HandBI

### 🎯 Próximos Passos

1. Abra o `dashboard.html` agora para ver os dados de exemplo
2. Quando tiver seus dados reais, cole-os usando o botão de atualização
3. Compartilhe o dashboard com sua equipe!

---

**Dúvidas?** Consulte o `README.md` para documentação completa do sistema de gestão.
