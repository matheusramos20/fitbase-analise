-- 02_modelar.sql
DROP TABLE IF EXISTS series;
DROP TABLE IF EXISTS treinos;
DROP TABLE IF EXISTS exercicios;

CREATE TABLE exercicios (
  id             SERIAL PRIMARY KEY,
  nome           VARCHAR(100) NOT NULL UNIQUE,
  grupo_muscular VARCHAR(50)  NOT NULL
);

CREATE TABLE treinos (
  id          SERIAL PRIMARY KEY,
  data        DATE    NOT NULL UNIQUE,
  duracao_min INTEGER,
  observacao  TEXT
);

CREATE TABLE series (
  id           SERIAL  PRIMARY KEY,
  treino_id    INTEGER NOT NULL REFERENCES treinos(id)    ON DELETE CASCADE,
  exercicio_id INTEGER NOT NULL REFERENCES exercicios(id) ON DELETE RESTRICT,
  numero_serie INTEGER NOT NULL,
  repeticoes   INTEGER NOT NULL,
  peso_kg      NUMERIC(6,2) NOT NULL,
  CHECK (repeticoes > 0 AND peso_kg >= 0)
);