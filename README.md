# Projeto Lógico de Banco de Dados — Loja de PC Gamer

Modelagem lógica completa de um sistema para loja especializada em hardware, periféricos e montagem de PCs gamers. O projeto cobre desde o cadastro de clientes e produtos até o controle de montagens personalizadas, entregas e garantias.

## Contexto

A loja comercializa componentes (CPU, GPU, RAM, armazenamento, placas-mãe, fontes, gabinetes, coolers), periféricos (monitores, teclados, mouses, headsets) e mobiliário gamer (cadeiras e mesas). Além da venda de produtos avulsos, a loja oferece o serviço de montagem de PCs sob encomenda, onde o técnico seleciona e monta os componentes escolhidos pelo cliente. Cada pedido pode combinar produtos e serviço de montagem, ter múltiplas formas de pagamento e gerar uma entrega rastreável.

## Modelo

```
CLIENTE (tipo: PF | PJ)
    ├── CLIENTE_PF (cpf)
    ├── CLIENTE_PJ (cnpj, razao_social)
    ├── ENDERECO
    └── PEDIDO (tipo: Produtos | Montagem | Misto)
            ├── ITEM_PEDIDO ──► PRODUTO ──► CATEGORIA
            │                       ├── PRODUTO_FORNECEDOR ──► FORNECEDOR
            │                       └── PRODUTO_ESTOQUE    ──► ESTOQUE
            ├── PAGAMENTO (N por pedido)
            ├── ENTREGA (status + código de rastreio)
            ├── MONTAGEM ──► VENDEDOR (técnico)
            │       └── COMPONENTE_MONTAGEM ──► PRODUTO
            └── GARANTIA (por item_pedido)
```

## Tabelas

| Tabela | Descrição |
|---|---|
| `cliente` | Base com discriminador de tipo (PF/PJ) |
| `cliente_pf` | CPF e data de nascimento — vínculo 1:1 exclusivo |
| `cliente_pj` | CNPJ e razão social — vínculo 1:1 exclusivo |
| `endereco` | Endereços do cliente por finalidade |
| `categoria` | Tipo: Componente, Periférico, Acessório ou Mobiliário |
| `produto` | Catálogo com preço, estoque mínimo e garantia em meses |
| `fornecedor` | Fornecedores com país de origem |
| `produto_fornecedor` | N:N produto↔fornecedor com custo e prazo de entrega |
| `estoque` | Depósitos físicos da loja |
| `produto_estoque` | N:N produto↔estoque com quantidade disponível |
| `vendedor` | Equipe de vendas com taxa de comissão individual |
| `pedido` | Pedido com tipo (Produtos / Montagem / Misto) e status |
| `item_pedido` | Itens com preço histórico preservado |
| `pagamento` | Múltiplas formas de pagamento por pedido |
| `entrega` | Status de envio, transportadora e código de rastreio |
| `montagem` | Serviço de montagem vinculado ao pedido e ao técnico |
| `componente_montagem` | Componentes selecionados para cada build |
| `garantia` | Registro de garantia por item com número de série |

## Queries implementadas

| # | Cláusulas | Pergunta respondida |
|---|---|---|
| Q1 | SELECT, JOIN, WHERE, ORDER BY | Quais produtos estão ativos com sua categoria e garantia? |
| Q2 | WHERE, JOIN múltiplo | Quais produtos estão abaixo do estoque mínimo por depósito? |
| Q3 | Atributo derivado, Window Function | Valor por item, subtotal por pedido e margem sobre custo |
| Q4 | JOIN, GROUP BY, ORDER BY, atributo derivado | Ranking de produtos por margem bruta estimada |
| Q5 | JOIN, GROUP BY, HAVING | Categorias com receita de vendas acima de R$ 5.000 |
| Q6 | JOIN, GROUP BY, atributo derivado | Volume de pedidos, ticket médio e total gasto por cliente |
| Q7 | JOIN múltiplo, Window Function | Composição e custo total de cada build montado |
| Q8 | JOIN, GROUP BY, ORDER BY | Ranking de produtos mais vendidos em unidades |
| Q9 | JOIN, GROUP BY, HAVING, GROUP_CONCAT | Fornecedores com mais de 3 produtos e custo médio |
| Q10 | JOIN, atributo derivado, GROUP BY | Vendas e comissão a receber por vendedor |
| Q11 | JOIN, COALESCE, CASE, ORDER BY | Status completo das entregas com pontualidade |
| Q12 | Subquery, JOIN, HAVING | Clientes PF com gasto acima da média geral |

## Como executar

```bash
mysql -u root -p -e "CREATE DATABASE pcgamer;"
mysql -u root -p pcgamer < pcgamer_logico.sql
```

Para o diagrama EER no MySQL Workbench: **Database → Reverse Engineer** → schema `pcgamer`.

## Tecnologias

- MySQL 8+
- MySQL Workbench
