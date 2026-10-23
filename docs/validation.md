# Validação executada

Validação local em 23/10/2026, Linux x86_64, Python 3.12.14, CPU, PyTorch 2.5.1+cpu,
Orange3 3.40.0, Z3 4.16.0 e Lean 4.19.0. Os resultados descrevem esta instância;
publicação e restauração em uma nova tarefa são etapas independentes.

| Verificação | Resultado observado |
|---|---|
| `bash scripts/setup.sh` | Instalação repetida com sucesso, versões fixadas e `pip check` aprovado |
| `bash scripts/test.sh -q` | **86 testes aprovados**, 10 subtestes aprovados, 1 teste CUDA/Triton ignorado por ausência de GPU |
| Cobertura | **92%** das linhas de código executável; relatório completo em `artifacts/coverage.json` |
| Ruff | Lint e formatação aprovados |
| CLI `nextorch demo --lean` | Síntese, treinamento GFlowNet, busca latente, replay certificado, treino conjunto e prova Lean concluídos |
| Barreira dupla | Ciclo real com `require_lean=True`, certificado Z3+Lean e restauração de checkpoint aprovados |
| Contratos formais | Deduções verdadeiras, falsas, premissas inconsistentes e unknown tratados; replay adulterado rejeitado |
| Expansão Net2Wider | Saídas e gradientes de entrada preservados para quatro ativações, com e sem bias |
| Orange/Qt offscreen | Três widgets conectados, cancelamento, recuperação de erro, remoção de entrada e sinais validados |
| Projeções | PCA 2D/3D, t-SNE e UMAP executados com coordenadas finitas |
| Workflow `.ows` | Descoberta dos widgets, seis nós e seis conexões carregados pelo Orange |
| Inductor CPU | Forward equivalente ao eager e backward com gradientes não nulos |
| Build | Wheel e sdist gerados; wheel instalado em diretório separado, importado fora do checkout e usado para verificar transitividade |
| Galeria | Três capturas reais dos widgets em `artifacts/gallery/` |
| Git upstream Orange | Clone em `/workspace/orange3`, commit `db6ea81d9babb0a392c4fac714337aa7882246c6`, sem alterações |

O experimento Iris usa 105 amostras de treino e 45 de teste, split estratificado e
seed 42. Normalização e seleção da arquitetura usam apenas o treino. Após 200 passos:

- acurácia no teste: **91,1% (41/45)**;
- perda conjunta no treino: **1,1739 → 0,00432**;
- dimensão intrínseca estimada: 2;
- features SAE exportadas: 128.

Esse experimento demonstra funcionamento no dataset e seed escolhidos. Não é uma
estimativa abrangente de generalização. O relatório está em `artifacts/iris/report.json`,
a tabela em `iris_features.tab` e o modelo restaurável em `iris_model.pt`.

O teste CUDA/Triton permanece sem execução neste ambiente. A CI foi configurada,
mas não foi executada no GitHub nesta tarefa. A instalação por wheel do Orange
valida o add-on; o clone de desenvolvimento do upstream não foi compilado.

A execução da suíte apresenta avisos de depreciação da localização do Orange e
de paralelismo determinístico do UMAP. Nenhum deles corresponde a um teste falho.
