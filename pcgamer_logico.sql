-- ================================================================
--  PROJETO LÓGICO DE BANCO DE DADOS — LOJA DE PC GAMER
--  Entidades: Clientes PF/PJ | Produtos | Fornecedores | Estoque
--             Vendedores | Pedidos | Pagamentos | Entregas | Montagem
-- ================================================================

-- ----------------------------------------------------------------
--  SCHEMA
-- ----------------------------------------------------------------

CREATE TABLE cliente (
    id_cliente    INT            NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(150)   NOT NULL,
    email         VARCHAR(150)   NOT NULL,
    telefone      VARCHAR(20),
    tipo          ENUM('PF','PJ') NOT NULL,
    data_cadastro DATETIME       NOT NULL DEFAULT NOW(),
    ativo         BOOLEAN        NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_cliente),
    UNIQUE KEY uq_cliente_email (email)
);

CREATE TABLE cliente_pf (
    id_cliente_pf   INT      NOT NULL AUTO_INCREMENT,
    id_cliente      INT      NOT NULL,
    cpf             CHAR(11) NOT NULL,
    data_nascimento DATE,
    PRIMARY KEY (id_cliente_pf),
    UNIQUE KEY uq_cpf        (cpf),
    UNIQUE KEY uq_pf_cliente (id_cliente),
    CONSTRAINT fk_pf_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE cliente_pj (
    id_cliente_pj INT          NOT NULL AUTO_INCREMENT,
    id_cliente    INT          NOT NULL,
    cnpj          CHAR(14)     NOT NULL,
    razao_social  VARCHAR(200) NOT NULL,
    nome_fantasia VARCHAR(200),
    PRIMARY KEY (id_cliente_pj),
    UNIQUE KEY uq_cnpj       (cnpj),
    UNIQUE KEY uq_pj_cliente (id_cliente),
    CONSTRAINT fk_pj_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE endereco (
    id_endereco   INT          NOT NULL AUTO_INCREMENT,
    id_cliente    INT          NOT NULL,
    logradouro    VARCHAR(250) NOT NULL,
    numero        VARCHAR(10),
    complemento   VARCHAR(100),
    bairro        VARCHAR(100),
    cidade        VARCHAR(100) NOT NULL,
    estado        CHAR(2)      NOT NULL,
    cep           CHAR(8)      NOT NULL,
    tipo_endereco ENUM('Residencial','Comercial','Entrega','Cobrança') NOT NULL DEFAULT 'Entrega',
    PRIMARY KEY (id_endereco),
    CONSTRAINT fk_end_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE categoria (
    id_categoria    INT          NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100) NOT NULL,
    tipo_categoria  ENUM('Componente','Periférico','Acessório','Mobiliário') NOT NULL,
    descricao       TEXT,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE produto (
    id_produto       INT            NOT NULL AUTO_INCREMENT,
    id_categoria     INT,
    nome             VARCHAR(200)   NOT NULL,
    descricao        TEXT,
    preco            DECIMAL(12, 2) NOT NULL,
    estoque_min      INT            NOT NULL DEFAULT 5,
    garantia_meses   TINYINT        NOT NULL DEFAULT 12,
    ativo            BOOLEAN        NOT NULL DEFAULT TRUE,
    data_cadastro    DATETIME       NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_produto),
    CONSTRAINT fk_prod_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE fornecedor (
    id_fornecedor INT          NOT NULL AUTO_INCREMENT,
    razao_social  VARCHAR(200) NOT NULL,
    cnpj          CHAR(14)     NOT NULL,
    contato       VARCHAR(100),
    telefone      VARCHAR(20),
    email         VARCHAR(150),
    pais_origem   VARCHAR(60)  NOT NULL DEFAULT 'Brasil',
    PRIMARY KEY (id_fornecedor),
    UNIQUE KEY uq_forn_cnpj (cnpj)
);

CREATE TABLE produto_fornecedor (
    id_produto         INT            NOT NULL,
    id_fornecedor      INT            NOT NULL,
    preco_custo        DECIMAL(12, 2) NOT NULL,
    prazo_entrega_dias TINYINT        NOT NULL DEFAULT 7,
    PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT fk_pf_produto
        FOREIGN KEY (id_produto)    REFERENCES produto    (id_produto)    ON DELETE CASCADE,
    CONSTRAINT fk_pf_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor) ON DELETE CASCADE
);

CREATE TABLE estoque (
    id_estoque  INT          NOT NULL AUTO_INCREMENT,
    local       VARCHAR(100) NOT NULL,
    responsavel VARCHAR(100),
    PRIMARY KEY (id_estoque)
);

CREATE TABLE produto_estoque (
    id_produto INT NOT NULL,
    id_estoque INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_produto, id_estoque),
    CONSTRAINT fk_pe_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto) ON DELETE CASCADE,
    CONSTRAINT fk_pe_estoque
        FOREIGN KEY (id_estoque) REFERENCES estoque (id_estoque) ON DELETE CASCADE
);

CREATE TABLE vendedor (
    id_vendedor   INT           NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(150)  NOT NULL,
    cpf           CHAR(11)      NOT NULL,
    email         VARCHAR(150)  NOT NULL,
    telefone      VARCHAR(20),
    taxa_comissao DECIMAL(5, 2) NOT NULL DEFAULT 5.00,
    PRIMARY KEY (id_vendedor),
    UNIQUE KEY uq_vendedor_cpf   (cpf),
    UNIQUE KEY uq_vendedor_email (email)
);

CREATE TABLE pedido (
    id_pedido     INT            NOT NULL AUTO_INCREMENT,
    id_cliente    INT            NOT NULL,
    id_vendedor   INT,
    tipo_pedido   ENUM('Produtos','Montagem','Misto') NOT NULL DEFAULT 'Produtos',
    status_pedido ENUM(
        'Aguardando Pagamento',
        'Pagamento Confirmado',
        'Em Separação',
        'Aguardando Montagem',
        'Em Montagem',
        'Pronto para Envio',
        'Enviado',
        'Entregue',
        'Cancelado'
    )                            NOT NULL DEFAULT 'Aguardando Pagamento',
    frete         DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    data_pedido   DATETIME       NOT NULL DEFAULT NOW(),
    observacoes   TEXT,
    PRIMARY KEY (id_pedido),
    CONSTRAINT fk_ped_cliente
        FOREIGN KEY (id_cliente)  REFERENCES cliente  (id_cliente)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ped_vendedor
        FOREIGN KEY (id_vendedor) REFERENCES vendedor (id_vendedor) ON DELETE SET NULL  ON UPDATE CASCADE
);

CREATE TABLE item_pedido (
    id_item        INT            NOT NULL AUTO_INCREMENT,
    id_pedido      INT            NOT NULL,
    id_produto     INT            NOT NULL,
    quantidade     INT            NOT NULL,
    preco_unitario DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (id_item),
    CONSTRAINT fk_ip_pedido
        FOREIGN KEY (id_pedido)  REFERENCES pedido  (id_pedido)  ON DELETE CASCADE,
    CONSTRAINT fk_ip_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto) ON DELETE RESTRICT
);

CREATE TABLE pagamento (
    id_pagamento     INT            NOT NULL AUTO_INCREMENT,
    id_pedido        INT            NOT NULL,
    forma_pagamento  ENUM('Cartão de Crédito','Cartão de Débito','PIX','Boleto','Financiamento') NOT NULL,
    valor            DECIMAL(12, 2) NOT NULL,
    status_pagamento ENUM('Pendente','Aprovado','Recusado','Estornado') NOT NULL DEFAULT 'Pendente',
    num_parcelas     TINYINT        NOT NULL DEFAULT 1,
    codigo_transacao VARCHAR(100),
    data_pagamento   DATETIME,
    PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pag_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE entrega (
    id_entrega      INT         NOT NULL AUTO_INCREMENT,
    id_pedido       INT         NOT NULL,
    id_endereco     INT         NOT NULL,
    status_entrega  ENUM(
        'Aguardando Postagem',
        'Postado',
        'Em Trânsito',
        'Saiu para Entrega',
        'Entregue',
        'Tentativa Falha',
        'Devolvido'
    )                           NOT NULL DEFAULT 'Aguardando Postagem',
    codigo_rastreio VARCHAR(50),
    transportadora  VARCHAR(100),
    prazo_estimado  DATE,
    data_envio      DATE,
    data_entrega    DATE,
    PRIMARY KEY (id_entrega),
    UNIQUE KEY uq_entrega_pedido (id_pedido),
    CONSTRAINT fk_ent_pedido
        FOREIGN KEY (id_pedido)   REFERENCES pedido   (id_pedido)   ON DELETE CASCADE,
    CONSTRAINT fk_ent_endereco
        FOREIGN KEY (id_endereco) REFERENCES endereco (id_endereco) ON DELETE RESTRICT
);

CREATE TABLE montagem (
    id_montagem      INT            NOT NULL AUTO_INCREMENT,
    id_pedido        INT            NOT NULL,
    id_vendedor_tec  INT,
    descricao        TEXT,
    valor_mao_obra   DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status_montagem  ENUM(
        'Aguardando Componentes',
        'Em Montagem',
        'Testes',
        'Concluída',
        'Cancelada'
    )                               NOT NULL DEFAULT 'Aguardando Componentes',
    data_inicio      DATE,
    data_conclusao   DATE,
    observacoes      TEXT,
    PRIMARY KEY (id_montagem),
    UNIQUE KEY uq_montagem_pedido (id_pedido),
    CONSTRAINT fk_mont_pedido
        FOREIGN KEY (id_pedido)       REFERENCES pedido   (id_pedido)   ON DELETE CASCADE,
    CONSTRAINT fk_mont_vendedor
        FOREIGN KEY (id_vendedor_tec) REFERENCES vendedor (id_vendedor) ON DELETE SET NULL
);

CREATE TABLE componente_montagem (
    id_comp_mont INT NOT NULL AUTO_INCREMENT,
    id_montagem  INT NOT NULL,
    id_produto   INT NOT NULL,
    quantidade   INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_comp_mont),
    CONSTRAINT fk_cm_montagem
        FOREIGN KEY (id_montagem) REFERENCES montagem (id_montagem) ON DELETE CASCADE,
    CONSTRAINT fk_cm_produto
        FOREIGN KEY (id_produto)  REFERENCES produto  (id_produto)  ON DELETE RESTRICT
);

CREATE TABLE garantia (
    id_garantia    INT         NOT NULL AUTO_INCREMENT,
    id_item        INT         NOT NULL,
    numero_serie   VARCHAR(60),
    data_inicio    DATE        NOT NULL,
    data_fim       DATE        NOT NULL,
    status_garantia ENUM('Ativa','Expirada','Acionada','Cancelada') NOT NULL DEFAULT 'Ativa',
    PRIMARY KEY (id_garantia),
    CONSTRAINT fk_gar_item
        FOREIGN KEY (id_item) REFERENCES item_pedido (id_item) ON DELETE CASCADE
);


-- ----------------------------------------------------------------
--  DADOS
-- ----------------------------------------------------------------

INSERT INTO categoria (nome, tipo_categoria, descricao) VALUES
    ('Processador',          'Componente', 'CPUs Intel e AMD'),
    ('Placa de Vídeo',       'Componente', 'GPUs NVIDIA e AMD'),
    ('Memória RAM',          'Componente', 'Módulos DDR4 e DDR5'),
    ('Armazenamento',        'Componente', 'SSDs NVMe, SATA e HDDs'),
    ('Placa-Mãe',            'Componente', 'Motherboards para todas as plataformas'),
    ('Fonte de Alimentação', 'Componente', 'Fontes certificadas 80 Plus'),
    ('Gabinete',             'Componente', 'Cases mid-tower e full-tower'),
    ('Cooler/Refrigeração',  'Componente', 'Air coolers e watercoolers'),
    ('Monitor',              'Periférico', 'Monitores gamer de alta taxa de atualização'),
    ('Teclado',              'Periférico', 'Teclados mecânicos e membrana'),
    ('Mouse',                'Periférico', 'Mouses com sensor óptico de alta precisão'),
    ('Headset',              'Periférico', 'Headsets com som surround'),
    ('Cadeira Gamer',        'Mobiliário', 'Cadeiras ergonômicas'),
    ('Mesa Gamer',           'Mobiliário', 'Mesas com suporte para periféricos');

INSERT INTO produto (id_categoria, nome, descricao, preco, estoque_min, garantia_meses) VALUES
    (1,  'AMD Ryzen 7 7700X',           '8 núcleos, 16 threads, até 5.4 GHz',        1899.90,  5, 36),
    (1,  'Intel Core i9-13900K',        '24 núcleos, 32 threads, até 5.8 GHz',        3299.90,  3, 36),
    (1,  'AMD Ryzen 5 7600',            '6 núcleos, 12 threads, até 5.1 GHz',          999.90,  8, 36),
    (2,  'NVIDIA RTX 4070 Ti 12GB',     'GDDR6X, ray tracing, DLSS 3',               4999.90,  3, 36),
    (2,  'AMD RX 7900 XT 20GB',         'GDDR6, ray tracing, FSR 3',                  4299.90,  3, 36),
    (2,  'NVIDIA RTX 4060 8GB',         'GDDR6, ótimo custo-benefício 1080p/1440p',   2199.90,  5, 36),
    (3,  'Kingston DDR5 32GB 5600MHz',  'Kit 2x16GB, latência CL36',                   699.90, 10, 36),
    (3,  'Corsair DDR4 16GB 3200MHz',   'Kit 2x8GB, RGB, latência CL16',               359.90, 10, 36),
    (4,  'Samsung 980 Pro 1TB NVMe',    'Leitura 7.000 MB/s, PCIe 4.0',               399.90,  8, 60),
    (4,  'Seagate Barracuda 2TB HDD',   '7200 RPM, cache 256MB',                       329.90, 10, 24),
    (5,  'ASUS ROG Strix B650E-F',      'AM5, DDR5, Wi-Fi 6E, PCIe 5.0',             1299.90,  4, 36),
    (5,  'MSI PRO Z790-A WiFi',         'LGA1700, DDR5, Wi-Fi 6E',                    1099.90,  4, 36),
    (6,  'Corsair RM850x 850W Gold',    '80 Plus Gold, modular, 10 anos garantia',     699.90,  5, 120),
    (7,  'Lian Li PC-O11 Dynamic EVO',  'Mid-tower, vidro temperado, 3 slots PCIe',    849.90,  4, 12),
    (8,  'Cooler Master MasterLiquid 240','Watercooler 240mm, RGB, 2 fans',             499.90,  5, 24),
    (9,  'LG UltraGear 27GP850 27"',    '2560x1440, 165Hz, 1ms, IPS, HDR400',        1899.90,  4, 36),
    (9,  'Samsung Odyssey G5 27"',      '2560x1440, 165Hz, 1ms, VA, curvo',           1299.90,  5, 36),
    (10, 'Keychron Q3 TKL Mecânico',    'Switch Gateron G Pro Red, PBT, alumínio',     699.90,  6, 12),
    (10, 'Redragon Kumara K552 RGB',    'Switch Outemu Blue, compacto',                 199.90, 10, 12),
    (11, 'Logitech G Pro X Superlight', 'Sensor HERO 25K, sem fio, 61g',               799.90,  5, 24),
    (11, 'Razer DeathAdder V3',         'Sensor Focus Pro 30K, ergonômico',             399.90,  8, 24),
    (12, 'HyperX Cloud Alpha Wireless', 'Som surround, bateria 300h, sem fio',          799.90,  5, 24),
    (12, 'Logitech G733 Wireless RGB',  'DTS 2.0, bateria 29h, RGB',                   649.90,  5, 24),
    (13, 'DXRacer Formula F11 PRO',     'Couro PU, suporte lombar, até 100kg',         1299.90,  3, 24),
    (13, 'ThunderX3 BC3 BOSS',          'Veludo, reclinável 180°, apoio de pés',       1499.90,  3, 24),
    (14, 'Mesa Gamer Rise Mode Z',      '136x60cm, fibra de carbono, porta-copo',       699.90,  3, 12);

INSERT INTO fornecedor (razao_social, cnpj, contato, telefone, email, pais_origem) VALUES
    ('AMD Distribuidora Brasil LTDA', '11111111000111', 'Rafael Torres',   '11987650001', 'vendas@amd-br.com',       'Brasil'),
    ('Intel Brasil Distribuidora',    '22222222000122', 'Carla Menezes',   '11987650002', 'vendas@intel-br.com',     'Brasil'),
    ('NVIDIA Corporation Brasil',     '33333333000133', 'Bruno Salave',    '11987650003', 'distribuidora@nvbr.com',  'Brasil'),
    ('Kingston Technology Brasil',    '44444444000144', 'Fernanda Lima',   '11987650004', 'vendas@kingston-br.com',  'Brasil'),
    ('Samsung Semicondutores BR',     '55555555000155', 'André Yamamoto',  '11987650005', 'pedidos@samsung-br.com',  'Brasil'),
    ('Corsair Components Brasil',     '66666666000166', 'Patrícia Rocha',  '11987650006', 'vendas@corsair-br.com',   'Brasil'),
    ('Logitech do Brasil LTDA',       '77777777000177', 'Marcos Alves',    '11987650007', 'vendas@logitech-br.com',  'Brasil'),
    ('DXRacer Brasil Importadora',    '88888888000188', 'Tânia Corrêa',    '11987650008', 'contato@dxracer-br.com',  'Brasil'),
    ('Redragon Importadora BR',       '99999999000199', 'Lucas Freitas',   '11987650009', 'vendas@redragon-br.com',  'Brasil');

INSERT INTO produto_fornecedor (id_produto, id_fornecedor, preco_custo, prazo_entrega_dias) VALUES
    (1,  1, 1350.00,  5), (2,  2, 2400.00,  5), (3,  1,  720.00,  5),
    (4,  3, 3700.00,  7), (5,  1, 3200.00,  7), (6,  3, 1600.00,  7),
    (7,  4,  480.00,  5), (7,  5,  460.00,  6),
    (8,  6,  240.00,  5),
    (9,  5,  260.00,  5),
    (10, 5,  210.00,  7),
    (11, 1,  900.00,  5), (12, 2,  760.00,  5),
    (13, 6,  480.00,  7),
    (14, 6,  580.00,  7),
    (15, 6,  320.00,  5),
    (16, 5, 1300.00,  7), (17, 5,  900.00,  7),
    (18, 7,  460.00,  5), (19, 9,  110.00,  7),
    (20, 7,  560.00,  5), (21, 7,  260.00,  5),
    (22, 7,  560.00,  5), (23, 7,  440.00,  5),
    (24, 8,  880.00, 10), (25, 8, 1020.00, 10),
    (26, 8,  450.00, 10);

INSERT INTO cliente (nome, email, telefone, tipo) VALUES
    ('Lucas Almeida',        'lucas@email.com',      '48991110001', 'PF'),
    ('GameTech LTDA',        'compras@gametech.com', '48332220002', 'PJ'),
    ('Fernanda Castro',      'fernanda@email.com',   '48993330003', 'PF'),
    ('Rafael Souza',         'rafael@email.com',     '48994440004', 'PF'),
    ('Cyber Arena LTDA',     'ti@cyberarena.com',    '48335550005', 'PJ'),
    ('Bruno Mendes',         'bruno@email.com',      '48996660006', 'PF'),
    ('Julia Pires',          'julia@email.com',      '48997770007', 'PF');

INSERT INTO cliente_pf (id_cliente, cpf, data_nascimento) VALUES
    (1, '11122233344', '1998-04-12'),
    (3, '55566677788', '1995-09-22'),
    (4, '99988877766', '2000-01-30'),
    (6, '33322211100', '1992-07-15'),
    (7, '44433322211', '2001-11-05');

INSERT INTO cliente_pj (id_cliente, cnpj, razao_social, nome_fantasia) VALUES
    (2, '12345678000199', 'GameTech Equipamentos LTDA', 'GameTech'),
    (5, '98765432000188', 'Cyber Arena Entretenimento LTDA', 'Cyber Arena');

INSERT INTO endereco (id_cliente, logradouro, numero, bairro, cidade, estado, cep, tipo_endereco) VALUES
    (1, 'Rua dos Games',      '42',  'Centro',      'Criciúma',      'SC', '88800000', 'Entrega'),
    (2, 'Av. Tecnologia',     '800', 'Industrial',  'Florianópolis', 'SC', '88010000', 'Comercial'),
    (3, 'Rua Pixel',          '17',  'Centro',      'Joinville',     'SC', '89200000', 'Entrega'),
    (4, 'Av. das Consolas',   '330', 'Jardim',      'Blumenau',      'SC', '89010000', 'Entrega'),
    (5, 'Rua do Server',      '500', 'Bela Vista',  'São Paulo',     'SP', '01310000', 'Comercial'),
    (6, 'Rua FPS',            '99',  'Vila Nova',   'Curitiba',      'PR', '80010000', 'Entrega'),
    (7, 'Rua do RPG',         '7',   'Centro',      'Porto Alegre',  'RS', '90010000', 'Entrega');

INSERT INTO estoque (local, responsavel) VALUES
    ('Depósito Central — Criciúma',    'Diego Henrique'),
    ('Depósito SC Norte — Joinville',  'Amanda Reis'),
    ('Depósito SP — São Paulo',        'Carlos Eduardo');

INSERT INTO produto_estoque (id_produto, id_estoque, quantidade) VALUES
    (1, 1, 12), (1, 3, 5),
    (2, 1,  6), (2, 3, 3),
    (3, 1, 18), (3, 2, 10),
    (4, 1,  5), (4, 3, 4),
    (5, 1,  4), (5, 3, 3),
    (6, 1, 10), (6, 2,  8),
    (7, 1, 20), (7, 2, 15),
    (8, 1, 25), (8, 2, 18),
    (9, 1, 15), (9, 3, 12),
   (10, 1, 20),
   (11, 1,  8), (11, 3, 4),
   (12, 1,  7), (12, 3, 5),
   (13, 1, 12), (13, 3, 8),
   (14, 1,  6),
   (15, 1,  9), (15, 2, 7),
   (16, 1,  5), (16, 3, 3),
   (17, 1,  8), (17, 2, 5),
   (18, 1,  9),
   (19, 1, 22), (19, 2, 15),
   (20, 1,  7), (20, 3, 4),
   (21, 1, 10), (21, 2, 8),
   (22, 1,  6), (22, 3, 4),
   (23, 1,  8),
   (24, 1,  4), (24, 3, 2),
   (25, 1,  3), (25, 3, 2),
   (26, 1,  5);

INSERT INTO vendedor (nome, cpf, email, telefone, taxa_comissao) VALUES
    ('Diego Henrique',  '10020030044', 'diego@pcgamer.com',    '48991200001', 7.00),
    ('Amanda Reis',     '20030040055', 'amanda@pcgamer.com',   '48991200002', 6.50),
    ('Carlos Eduardo',  '30040050066', 'carlos@pcgamer.com',   '48991200003', 6.00),
    ('Patrícia Santos', '40050060077', 'patricia@pcgamer.com', '48991200004', 5.50);

INSERT INTO pedido (id_cliente, id_vendedor, tipo_pedido, status_pedido, frete, data_pedido, observacoes) VALUES
    (1, 1, 'Misto',    'Entregue',            35.00, '2026-04-10 10:00:00', 'PC gamer completo com montagem'),
    (3, 2, 'Produtos', 'Entregue',            25.00, '2026-04-15 14:00:00', 'Upgrade de memória e SSD'),
    (4, 1, 'Produtos', 'Enviado',             20.00, '2026-05-02 09:00:00', 'Periféricos gamer'),
    (2, 3, 'Misto',    'Em Montagem',         80.00, '2026-05-20 08:00:00', 'Setup para LAN House — 5 PCs'),
    (5, 4, 'Produtos', 'Pagamento Confirmado',60.00, '2026-06-01 11:00:00', 'Cadeiras e mesas — Cyber Arena'),
    (6, 2, 'Misto',    'Entregue',            30.00, '2026-03-22 13:00:00', 'Build mid-range'),
    (7, 3, 'Produtos', 'Cancelado',            0.00, '2026-05-18 16:00:00', 'Desistência do cliente'),
    (1, 1, 'Produtos', 'Entregue',            15.00, '2026-03-05 10:00:00', 'Mouse e headset'),
    (4, 4, 'Misto',    'Pronto para Envio',   25.00, '2026-06-08 09:30:00', 'Build high-end'),
    (3, 2, 'Produtos', 'Aguardando Pagamento', 0.00, '2026-06-20 15:00:00', 'Monitor novo');

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
    (1,  1,  1, 1899.90), (1,  4,  1, 4999.90), (1,  7,  1,  699.90),
    (1,  9,  1,  399.90), (1, 11,  1, 1299.90), (1, 13,  1,  699.90),
    (1, 14,  1,  849.90), (1, 15,  1,  499.90),
    (2,  7,  1,  699.90), (2,  9,  1,  399.90),
    (3, 18,  1,  699.90), (3, 20,  1,  799.90), (3, 22,  1,  799.90),
    (4,  3,  5,  999.90), (4,  6,  5, 2199.90), (4,  8,  5,  359.90),
    (4,  9,  5,  399.90), (4, 12,  5, 1099.90), (4, 13,  5,  699.90),
    (4, 14,  5,  849.90), (4, 15,  5,  499.90),
    (5, 24,  8, 1299.90), (5, 25,  2, 1499.90), (5, 26,  8,  699.90),
    (6,  3,  1,  999.90), (6,  6,  1, 2199.90), (6,  8,  1,  359.90),
    (6,  9,  1,  399.90), (6, 12,  1, 1099.90), (6, 13,  1,  699.90),
    (6, 14,  1,  849.90), (6, 15,  1,  499.90),
    (7, 16,  1, 1899.90),
    (8, 20,  1,  799.90), (8, 22,  1,  799.90),
    (9,  2,  1, 3299.90), (9,  4,  1, 4999.90), (9,  7,  1,  699.90),
    (9,  9,  1,  399.90), (9, 11,  1, 1299.90), (9, 13,  1,  699.90),
    (9, 14,  1,  849.90), (9, 15,  1,  499.90),
   (10, 16,  1, 1899.90);

INSERT INTO pagamento (id_pedido, forma_pagamento, valor, status_pagamento, num_parcelas, codigo_transacao, data_pagamento) VALUES
    (1,  'Cartão de Crédito', 11383.10, 'Aprovado', 12, 'TXN-CC-2001', '2026-04-10 10:05:00'),
    (2,  'PIX',                1099.80, 'Aprovado',  1, 'TXN-PIX-2002','2026-04-15 14:03:00'),
    (3,  'Cartão de Débito',   2298.70, 'Aprovado',  1, 'TXN-CD-2003', '2026-05-02 09:04:00'),
    (4,  'Financiamento',     28297.00, 'Aprovado', 24, 'TXN-FIN-2004','2026-05-21 10:00:00'),
    (4,  'Cartão de Crédito',  5000.00, 'Aprovado',  6, 'TXN-CC-2005', '2026-05-21 10:02:00'),
    (5,  'Boleto',            15192.00, 'Aprovado',  1, 'TXN-BOL-2006','2026-06-02 09:00:00'),
    (6,  'Cartão de Crédito',  7106.10, 'Aprovado',  6, 'TXN-CC-2007', '2026-03-22 13:05:00'),
    (7,  'PIX',                1899.90, 'Estornado', 1, 'TXN-PIX-2008','2026-05-18 16:03:00'),
    (8,  'Cartão de Crédito',  1614.80, 'Aprovado',  3, 'TXN-CC-2009', '2026-03-05 10:02:00'),
    (9,  'Financiamento',     12746.30, 'Aprovado', 18, 'TXN-FIN-2010','2026-06-08 09:35:00'),
    (10, 'PIX',                1899.90, 'Pendente',  1,  NULL,           NULL);

INSERT INTO entrega (id_pedido, id_endereco, status_entrega, codigo_rastreio, transportadora, prazo_estimado, data_envio, data_entrega) VALUES
    (1, 1, 'Entregue',           'BR200001SC', 'Jadlog',         '2026-04-14', '2026-04-11', '2026-04-13'),
    (2, 3, 'Entregue',           'BR200002SC', 'Correios SEDEX', '2026-04-19', '2026-04-16', '2026-04-18'),
    (3, 4, 'Em Trânsito',        'BR200003SC', 'Total Express',  '2026-05-07', '2026-05-03',  NULL),
    (4, 2, 'Aguardando Postagem', NULL,         'Transportadora Própria', '2026-06-01', NULL, NULL),
    (5, 5, 'Postado',            'BR200004SP', 'Correios PAC',   '2026-06-10', '2026-06-04',  NULL),
    (6, 6, 'Entregue',           'BR200005PR', 'Jadlog',         '2026-03-26', '2026-03-23', '2026-03-25'),
    (8, 1, 'Entregue',           'BR200006SC', 'Correios SEDEX', '2026-03-08', '2026-03-06', '2026-03-07'),
    (9, 4, 'Aguardando Postagem', NULL,         'Jadlog',         '2026-06-13',  NULL,         NULL);

INSERT INTO montagem (id_pedido, id_vendedor_tec, descricao, valor_mao_obra, status_montagem, data_inicio, data_conclusao) VALUES
    (1, 3, 'PC Gamer high-end: Ryzen 7 + RTX 4070 Ti + 32GB DDR5', 350.00, 'Concluída',  '2026-04-10', '2026-04-11'),
    (4, 3, 'LAN House — 5x PC mid-range: Ryzen 5 + RTX 4060',      1500.00,'Em Montagem','2026-05-22',  NULL),
    (6, 1, 'PC Gamer mid-range: Ryzen 5 + RTX 4060 + 16GB DDR4',   300.00, 'Concluída',  '2026-03-22', '2026-03-23'),
    (9, 3, 'PC Gamer top: i9-13900K + RTX 4070 Ti + 32GB DDR5',    400.00, 'Concluída',  '2026-06-08', '2026-06-09');

INSERT INTO componente_montagem (id_montagem, id_produto, quantidade) VALUES
    (1, 1, 1), (1, 4, 1), (1, 7, 1), (1,  9, 1), (1, 11, 1), (1, 13, 1), (1, 14, 1), (1, 15, 1),
    (2, 3, 5), (2, 6, 5), (2, 8, 5), (2,  9, 5), (2, 12, 5), (2, 13, 5), (2, 14, 5), (2, 15, 5),
    (3, 3, 1), (3, 6, 1), (3, 8, 1), (3,  9, 1), (3, 12, 1), (3, 13, 1), (3, 14, 1), (3, 15, 1),
    (4, 2, 1), (4, 4, 1), (4, 7, 1), (4,  9, 1), (4, 11, 1), (4, 13, 1), (4, 14, 1), (4, 15, 1);

INSERT INTO garantia (id_item, numero_serie, data_inicio, data_fim, status_garantia) VALUES
    (1,  'RZ7-7700X-001', '2026-04-13', '2029-04-13', 'Ativa'),
    (2,  'RTX4070-001',   '2026-04-13', '2029-04-13', 'Ativa'),
    (9,  'SAM980-001',    '2026-04-18', '2031-04-18', 'Ativa'),
    (34, 'RZ5-7600-001',  '2026-03-25', '2029-03-25', 'Ativa'),
    (35, 'RTX4060-001',   '2026-03-25', '2029-03-25', 'Ativa'),
    (36, 'LPX16-001',     '2026-03-25', '2029-03-25', 'Ativa');


-- ================================================================
--  QUERIES
-- ================================================================

-- ----------------------------------------------------------------
-- Q1 — SELECT simples
-- Pergunta: Quais produtos estão ativos, suas categorias
--           e prazo de garantia?
-- ----------------------------------------------------------------
SELECT
    p.id_produto,
    c.nome                   AS categoria,
    c.tipo_categoria,
    p.nome                   AS produto,
    p.preco,
    p.garantia_meses
FROM produto p
LEFT JOIN categoria c ON c.id_categoria = p.id_categoria
WHERE p.ativo = TRUE
ORDER BY c.tipo_categoria, p.preco DESC;


-- ----------------------------------------------------------------
-- Q2 — WHERE com múltiplas condições
-- Pergunta: Quais produtos componentes estão abaixo do
--           estoque mínimo em algum depósito?
-- ----------------------------------------------------------------
SELECT
    p.nome                   AS produto,
    c.nome                   AS categoria,
    e.local                  AS deposito,
    pe.quantidade            AS qtd_atual,
    p.estoque_min            AS estoque_minimo
FROM produto p
JOIN categoria      c  ON c.id_categoria = p.id_categoria
JOIN produto_estoque pe ON pe.id_produto = p.id_produto
JOIN estoque        e  ON e.id_estoque   = pe.id_estoque
WHERE pe.quantidade < p.estoque_min
  AND p.ativo = TRUE
ORDER BY (pe.quantidade - p.estoque_min), p.nome;


-- ----------------------------------------------------------------
-- Q3 — Atributos derivados
-- Pergunta: Qual o valor total de cada item, o subtotal
--           por pedido e a margem gerada sobre o custo médio?
-- ----------------------------------------------------------------
SELECT
    ip.id_pedido,
    pr.nome                                              AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ROUND(AVG(pf.preco_custo), 2)                        AS custo_medio,
    (ip.quantidade * ip.preco_unitario)                  AS valor_item,
    ROUND((ip.preco_unitario - AVG(pf.preco_custo))
          / ip.preco_unitario * 100, 1)                  AS margem_pct,
    SUM(ip.quantidade * ip.preco_unitario)
        OVER (PARTITION BY ip.id_pedido)                 AS subtotal_pedido
FROM item_pedido ip
JOIN produto             pr ON pr.id_produto    = ip.id_produto
LEFT JOIN produto_fornecedor pf ON pf.id_produto = ip.id_produto
GROUP BY ip.id_item, ip.id_pedido, pr.nome, ip.quantidade, ip.preco_unitario
ORDER BY ip.id_pedido, valor_item DESC;


-- ----------------------------------------------------------------
-- Q4 — ORDER BY: Ranking de margem bruta por produto
-- Pergunta: Quais produtos têm maior margem bruta estimada
--           em relação ao custo médio de aquisição?
-- ----------------------------------------------------------------
SELECT
    p.nome                                               AS produto,
    cat.nome                                             AS categoria,
    p.preco                                              AS preco_venda,
    ROUND(AVG(pf.preco_custo), 2)                        AS custo_medio,
    ROUND(p.preco - AVG(pf.preco_custo), 2)              AS margem_bruta,
    ROUND((p.preco - AVG(pf.preco_custo))
          / p.preco * 100, 1)                            AS margem_pct
FROM produto p
JOIN produto_fornecedor pf  ON pf.id_produto   = p.id_produto
JOIN categoria          cat ON cat.id_categoria = p.id_categoria
GROUP BY p.id_produto, p.nome, cat.nome, p.preco
ORDER BY margem_pct DESC;


-- ----------------------------------------------------------------
-- Q5 — HAVING
-- Pergunta: Quais categorias geraram mais de R$ 5.000 em
--           vendas aprovadas?
-- ----------------------------------------------------------------
SELECT
    cat.nome                                             AS categoria,
    cat.tipo_categoria,
    COUNT(DISTINCT ip.id_pedido)                         AS pedidos_envolvidos,
    SUM(ip.quantidade)                                   AS unidades_vendidas,
    SUM(ip.quantidade * ip.preco_unitario)               AS receita_total
FROM categoria cat
JOIN produto       p  ON p.id_categoria  = cat.id_categoria
JOIN item_pedido   ip ON ip.id_produto   = p.id_produto
JOIN pedido        pd ON pd.id_pedido    = ip.id_pedido
WHERE pd.status_pedido NOT IN ('Cancelado')
GROUP BY cat.id_categoria, cat.nome, cat.tipo_categoria
HAVING SUM(ip.quantidade * ip.preco_unitario) > 5000
ORDER BY receita_total DESC;


-- ----------------------------------------------------------------
-- Q6 — JOIN: Quantos pedidos e qual o gasto total por cliente?
-- Pergunta: Qual é o volume de pedidos, ticket médio e
--           total investido por cada cliente?
-- ----------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome                                               AS cliente,
    c.tipo,
    COUNT(DISTINCT p.id_pedido)                          AS total_pedidos,
    SUM(pg.valor)                                        AS total_gasto,
    ROUND(AVG(pg.valor), 2)                              AS ticket_medio,
    MAX(pg.valor)                                        AS maior_pedido
FROM cliente c
LEFT JOIN pedido    p  ON p.id_cliente = c.id_cliente
                      AND p.status_pedido NOT IN ('Cancelado')
LEFT JOIN pagamento pg ON pg.id_pedido = p.id_pedido
                      AND pg.status_pagamento = 'Aprovado'
GROUP BY c.id_cliente, c.nome, c.tipo
ORDER BY total_gasto DESC;


-- ----------------------------------------------------------------
-- Q7 — JOIN: Builds montadas — componentes e valor total
-- Pergunta: Qual a composição e o custo total de cada
--           montagem de PC realizada?
-- ----------------------------------------------------------------
SELECT
    m.id_montagem,
    c.nome                                               AS cliente,
    pd.data_pedido,
    m.status_montagem,
    v.nome                                               AS tecnico_responsavel,
    pr.nome                                              AS componente,
    cat.nome                                             AS categoria,
    cm.quantidade,
    ip.preco_unitario,
    (cm.quantidade * ip.preco_unitario)                  AS valor_componente,
    m.valor_mao_obra,
    SUM(cm.quantidade * ip.preco_unitario)
        OVER (PARTITION BY m.id_montagem)
      + m.valor_mao_obra                                 AS custo_total_build
FROM montagem m
JOIN pedido               pd  ON pd.id_pedido      = m.id_pedido
JOIN cliente               c  ON c.id_cliente      = pd.id_cliente
LEFT JOIN vendedor         v  ON v.id_vendedor      = m.id_vendedor_tec
JOIN componente_montagem   cm ON cm.id_montagem     = m.id_montagem
JOIN produto               pr ON pr.id_produto      = cm.id_produto
JOIN categoria            cat ON cat.id_categoria   = pr.id_categoria
JOIN item_pedido           ip ON ip.id_pedido       = pd.id_pedido
                              AND ip.id_produto      = cm.id_produto
ORDER BY m.id_montagem, cat.tipo_categoria, pr.nome;


-- ----------------------------------------------------------------
-- Q8 — JOIN: Produtos mais vendidos por quantidade
-- Pergunta: Quais produtos foram mais vendidos em unidades
--           (excluindo pedidos cancelados)?
-- ----------------------------------------------------------------
SELECT
    pr.nome                                              AS produto,
    cat.nome                                             AS categoria,
    cat.tipo_categoria,
    SUM(ip.quantidade)                                   AS unidades_vendidas,
    SUM(ip.quantidade * ip.preco_unitario)               AS receita_gerada,
    COUNT(DISTINCT ip.id_pedido)                         AS aparece_em_pedidos
FROM produto     pr
JOIN categoria    cat ON cat.id_categoria = pr.id_categoria
JOIN item_pedido  ip  ON ip.id_produto    = pr.id_produto
JOIN pedido       pd  ON pd.id_pedido     = ip.id_pedido
WHERE pd.status_pedido NOT IN ('Cancelado')
GROUP BY pr.id_produto, pr.nome, cat.nome, cat.tipo_categoria
ORDER BY unidades_vendidas DESC
LIMIT 15;


-- ----------------------------------------------------------------
-- Q9 — JOIN + HAVING: Fornecedores com maior portfólio
-- Pergunta: Quais fornecedores abastecem mais de 3 produtos
--           e qual o custo médio de aquisição deles?
-- ----------------------------------------------------------------
SELECT
    f.razao_social                                       AS fornecedor,
    f.pais_origem,
    COUNT(pf.id_produto)                                 AS qtd_produtos,
    ROUND(AVG(pf.preco_custo), 2)                        AS custo_medio_aquisicao,
    GROUP_CONCAT(p.nome ORDER BY p.nome SEPARATOR ' | ') AS produtos
FROM fornecedor f
JOIN produto_fornecedor pf ON pf.id_fornecedor = f.id_fornecedor
JOIN produto            p  ON p.id_produto     = pf.id_produto
GROUP BY f.id_fornecedor, f.razao_social, f.pais_origem
HAVING COUNT(pf.id_produto) > 3
ORDER BY qtd_produtos DESC;


-- ----------------------------------------------------------------
-- Q10 — JOIN: Comissão dos vendedores sobre vendas aprovadas
-- Pergunta: Quanto cada vendedor gerou em vendas e qual a
--           comissão a receber no período?
-- ----------------------------------------------------------------
SELECT
    v.nome                                               AS vendedor,
    v.taxa_comissao,
    COUNT(DISTINCT p.id_pedido)                          AS pedidos_realizados,
    SUM(pg.valor)                                        AS total_vendido,
    ROUND(SUM(pg.valor) * v.taxa_comissao / 100, 2)     AS comissao_devida,
    COUNT(DISTINCT m.id_montagem)                        AS montagens_realizadas
FROM vendedor v
LEFT JOIN pedido    p  ON p.id_vendedor  = v.id_vendedor
                      AND p.status_pedido NOT IN ('Cancelado')
LEFT JOIN pagamento pg ON pg.id_pedido   = p.id_pedido
                      AND pg.status_pagamento = 'Aprovado'
LEFT JOIN montagem  m  ON m.id_vendedor_tec = v.id_vendedor
GROUP BY v.id_vendedor, v.nome, v.taxa_comissao
ORDER BY total_vendido DESC;


-- ----------------------------------------------------------------
-- Q11 — JOIN: Situação completa das entregas
-- Pergunta: Qual o status de cada entrega, o rastreio e
--           se foi entregue dentro do prazo?
-- ----------------------------------------------------------------
SELECT
    pd.id_pedido,
    c.nome                                               AS cliente,
    pd.tipo_pedido,
    e.status_entrega,
    COALESCE(e.codigo_rastreio, '(aguardando)')          AS rastreio,
    e.transportadora,
    e.prazo_estimado,
    e.data_envio,
    e.data_entrega,
    CASE
        WHEN e.data_entrega IS NOT NULL
         AND e.data_entrega > e.prazo_estimado           THEN 'Atrasada'
        WHEN e.data_entrega IS NOT NULL                  THEN 'No prazo'
        WHEN e.data_envio   IS NOT NULL                  THEN 'Em rota'
        ELSE                                                  'Não enviado'
    END                                                  AS pontualidade
FROM pedido pd
JOIN cliente c ON c.id_cliente = pd.id_cliente
LEFT JOIN entrega e ON e.id_pedido = pd.id_pedido
WHERE pd.status_pedido <> 'Cancelado'
ORDER BY pd.data_pedido DESC;


-- ----------------------------------------------------------------
-- Q12 — Subquery + JOIN: Clientes PF com gasto acima da média
-- Pergunta: Quais clientes pessoa física gastaram acima da
--           média geral de compras aprovadas?
-- ----------------------------------------------------------------
SELECT
    c.nome                                               AS cliente,
    cpf.cpf,
    SUM(pg.valor)                                        AS total_gasto,
    ROUND(SUM(pg.valor) - (
        SELECT AVG(sub.total)
        FROM (
            SELECT SUM(pg2.valor) AS total
            FROM pagamento pg2
            WHERE pg2.status_pagamento = 'Aprovado'
            GROUP BY pg2.id_pedido
        ) sub
    ), 2)                                                AS diferenca_da_media
FROM cliente c
JOIN cliente_pf  cpf ON cpf.id_cliente = c.id_cliente
JOIN pedido      p   ON p.id_cliente   = c.id_cliente
JOIN pagamento   pg  ON pg.id_pedido   = p.id_pedido
                     AND pg.status_pagamento = 'Aprovado'
GROUP BY c.id_cliente, c.nome, cpf.cpf
HAVING SUM(pg.valor) > (
    SELECT AVG(sub.total)
    FROM (
        SELECT SUM(pg2.valor) AS total
        FROM pagamento pg2
        WHERE pg2.status_pagamento = 'Aprovado'
        GROUP BY pg2.id_pedido
    ) sub
)
ORDER BY total_gasto DESC;
