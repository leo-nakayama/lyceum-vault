# Methodology: The Reflective Karakuri Loop

!!! tip "How this page fits the Vault"
    This *Methodology* page belongs to the **Artifacts → Reflective Karakuri** thread.
    It shows how a CFP-style inquiry becomes a **structured Observation Report** through a
    DSL pipeline in **Lyceum Workbench**, and how the resulting artifact is reintegrated
    into future inquiries.

```mermaid
flowchart TD
  A[Inquiry / CFP<br/>(Data string)] --> B[DSL Inference Engine<br/>(Lyceum Workbench)]
  subgraph D[Module Chain]
    D1[AristotleFourCauses<br/>O_decompose · O_tracechain · O_rebalance · O_agent_network]
    D2[TradeoffLens<br/>O_surfaceAxes · O_mapFrontier · O_shiftKnob]
    D3[Synthetic Naikan<br/>N_capture · N_appraise · N_gratitude · N_responsibility · N_counterfactual · N_telos_check · N_commit · N_score]
    D1 --> D2 --> D3
  end
  B --> D --> C[Observation Report<br/>(structured, no chain-of-thought)]
  C --> E{Telos / Guardrails<br/>(FinalCause + Safety)}
  E -- passes --> F[Artifact Packaging<br/>CFP · Report · Methodology]
  F --> G[Publish to Leo's Lyceum Vault]
  G --> H[Reintegration<br/>refine Data, adjust modules/knobs]
  H --> A
  E -- fails --> I[Rebalance / Re-run]
  I --> B
  classDef soft fill:#f7f9fc,stroke:#ccd7ea,color:#0b2545;
  class A,B,C,D,E,F,G,H,I soft
```


  
