<task>
  [Nome curto da funcionalidade]
</task>

<goal>
  [Uma ou duas frases descrevendo o resultado para o usuário.]
</goal>

<requirements>
  Negócio:
  - [Capacidade principal 1]
  - [Capacidade principal 2]
  - [Capacidade principal 3]

  Arquitetura:
  - [Onde a funcionalidade deve ser implementada]
  - [Qual camada é dona de cada responsabilidade]
  - [Regra de integração, fluxo de dados ou fronteira de dependência]

  UI/UX:
  - [Tela/estado importante 1]
  - [Tela/estado importante 2]
  - [Interação ou feedback importante]
</requirements>

<api_contracts>
  APIs externas:
  - [Nome do serviço externo]&#58; [endpoint ou capacidade]

  APIs de backend:
  - [MÉTODO] [caminho]: [propósito]
  - Resposta de sucesso: [formato ou fonte]
  - Respostas de erro: [status codes e significado]
</api_contracts>

<acceptance_criteria>
  - Dado [estado/contexto], quando [ação], então [resultado esperado].
  - Dado [estado/contexto], quando [ação], então [resultado esperado].
  - Dado [erro/caso de borda], quando [ação], então [feedback esperado].
</acceptance_criteria>

<constraints>
  - FAÇA: [decisão técnica ou de produto obrigatória]
  - NÃO FAÇA: [comportamento explicitamente proibido]
  - NUNCA: [fronteira crítica que não pode ser violada]
</constraints>
