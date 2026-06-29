-- =========================================================
-- SQP - Schema de exemplo para o MCP read-only
-- Tabelas no estilo ERP de manufatura (ordens de produção,
-- notas fiscais, equipamentos, operações, centros de trabalho,
-- recursos, clientes e produtos).
-- =========================================================

BEGIN;

-- ---------- Tipos / enums ----------
CREATE TYPE ordem_status AS ENUM ('ABERTA','EM_PRODUCAO','PAUSADA','CONCLUIDA','CANCELADA');
CREATE TYPE nota_status  AS ENUM ('EMITIDA','CANCELADA','RECEBIDA');
CREATE TYPE nota_tipo    AS ENUM ('SAIDA','ENTRADA');
CREATE TYPE op_status    AS ENUM ('PENDENTE','EM_EXECUCAO','CONCLUIDA','RETRABALHO','CANCELADA');

-- ---------- clientes ----------
CREATE TABLE clientes (
    id          BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(15)  UNIQUE NOT NULL,
    nome         VARCHAR(120) NOT NULL,
    documento    VARCHAR(18)  NOT NULL,
    cidade       VARCHAR(60),
    uf           VARCHAR(2),
    criado_em    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------- produtos ----------
CREATE TABLE produtos (
    id           BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(20) UNIQUE NOT NULL,
    descricao    VARCHAR(200) NOT NULL,
    unidade      VARCHAR(3) NOT NULL DEFAULT 'UN',
    estoque     NUMERIC(14,3) NOT NULL DEFAULT 0,
    custo_padrao NUMERIC(14,4) NOT NULL DEFAULT 0,
    e_ativo      BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------- centros_trabalho ----------
CREATE TABLE centros_trabalho (
    id          BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(10) UNIQUE NOT NULL,
    nome        VARCHAR(60) NOT NULL,
    turno_padrao VARCHAR(10) NOT NULL DEFAULT '1TURNO',
    capacidade_dia_h INTEGER NOT NULL DEFAULT 8
);

-- ---------- recursos (mão de obra / máquina) ----------
CREATE TABLE recursos (
    id           BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(10) UNIQUE NOT NULL,
    nome        VARCHAR(60) NOT NULL,
    tipo         VARCHAR(20) NOT NULL,
    centro_id    BIGINT NOT NULL REFERENCES centros_trabalho(id),
    custo_hora  NUMERIC(10,2) NOT NULL DEFAULT 0
);

-- ---------- equipamentos ----------
CREATE TABLE equipamentos (
    id           BIGSERIAL PRIMARY KEY,
    tag          VARCHAR(15) UNIQUE NOT NULL,
    nome         VARCHAR(80) NOT NULL,
    modelo       VARCHAR(60),
    fabricante   VARCHAR(60),
    centro_id    BIGINT REFERENCES centros_trabalho(id),
    instalado_em DATE,
    status       VARCHAR(15) NOT NULL DEFAULT 'ATIVO'
);

-- ---------- ordens (ordens de produção) ----------
CREATE TABLE ordens (
    id           BIGSERIAL PRIMARY KEY,
    numero       VARCHAR(15) UNIQUE NOT NULL,
    cliente_id   BIGINT NOT NULL REFERENCES clientes(id),
    produto_id   BIGINT NOT NULL REFERENCES produtos(id),
    quantidade   NUMERIC(14,3) NOT NULL DEFAULT 1,
    qt_produzida NUMERIC(14,3) NOT NULL DEFAULT 0,
    status       ordem_status NOT NULL DEFAULT 'ABERTA',
    prioridade   INTEGER NOT NULL DEFAULT 3,
    emissao      DATE NOT NULL DEFAULT CURRENT_DATE,
    entrega      DATE,
    criado_em    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- ordem_itens ----------
CREATE TABLE ordem_itens (
    id            BIGSERIAL PRIMARY KEY,
    ordem_id      BIGINT NOT NULL REFERENCES ordens(id) ON DELETE CASCADE,
    produto_id    BIGINT NOT NULL REFERENCES produtos(id),
    tipo          VARCHAR(3) NOT NULL,
    quantidade    NUMERIC(14,3) NOT NULL,
    unidade       VARCHAR(3) NOT NULL DEFAULT 'UN'
);

-- ---------- operacoes (roteiro) ----------
CREATE TABLE operacoes (
    id            BIGSERIAL PRIMARY KEY,
    codigo        VARCHAR(10) NOT NULL,
    descricao     VARCHAR(120) NOT NULL,
    centro_id     BIGINT NOT NULL REFERENCES centros_trabalho(id),
    tempo_setup_min INTEGER NOT NULL DEFAULT 0,
    tempo_unit_min  NUMERIC(10,2) NOT NULL DEFAULT 0
);

-- ---------- ordem_operacoes (apontamentos) ----------
CREATE TABLE ordem_operacoes (
    id              BIGSERIAL PRIMARY KEY,
    ordem_id        BIGINT NOT NULL REFERENCES ordens(id) ON DELETE CASCADE,
    operacao_id     BIGINT NOT NULL REFERENCES operacoes(id),
    sequencia        INTEGER NOT NULL,
    recurso_id      BIGINT REFERENCES recursos(id),
    inicio_prev     TIMESTAMPTZ,
    fim_prev        TIMESTAMPTZ,
    inicio_real     TIMESTAMPTZ,
    fim_real        TIMESTAMPTZ,
    qty_apontada    NUMERIC(14,3) NOT NULL DEFAULT 0,
    status          op_status NOT NULL DEFAULT 'PENDENTE'
);

-- ---------- notas (fiscais) ----------
CREATE TABLE notas (
    id             BIGSERIAL PRIMARY KEY,
    numero         VARCHAR(20) UNIQUE NOT NULL,
    serie          VARCHAR(3) NOT NULL DEFAULT '001',
    tipo           nota_tipo NOT NULL,
    status         nota_status NOT NULL DEFAULT 'EMITIDA',
    cliente_id     BIGINT REFERENCES clientes(id),
    parceiro_doc   VARCHAR(18),
    emissao        DATE NOT NULL DEFAULT CURRENT_DATE,
    valor_total    NUMERIC(14,2) NOT NULL DEFAULT 0,
    ordem_id       BIGINT REFERENCES ordens(id)
);

-- ---------- nota_itens ----------
CREATE TABLE nota_itens (
    id             BIGSERIAL PRIMARY KEY,
    nota_id        BIGINT NOT NULL REFERENCES notas(id) ON DELETE CASCADE,
    produto_id     BIGINT NOT NULL REFERENCES produtos(id),
    quantidade     NUMERIC(14,3) NOT NULL,
    valor_unit     NUMERIC(14,4) NOT NULL,
    valor_total   NUMERIC(14,2) NOT NULL
);

-- ---------- usuario read-only ----------
DO $$
BEGIN
    EXECUTE format('CREATE ROLE sqp_ro LOGIN PASSWORD %L', 'sqp_ro_pwd');
EXCEPTION WHEN duplicate_object THEN NULL;
END$$;

GRANT CONNECT ON DATABASE sqp TO sqp_ro;
GRANT USAGE ON SCHEMA public TO sqp_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sqp_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO sqp_ro;

COMMIT;