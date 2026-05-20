SELECT
 t.data,
 e.nome,
 e.grupo_muscular,
 s.numero_serie,
 s.repeticoes,
 s.peso_kg
FROM series s
INNER JOIN exercicios e ON s.exercicio_id = e.id
INNER JOIN treinos t ON s.treino_id = t.id
ORDER BY t.data, e.nome, s.numero_serie;

--- Encontrar dado sem nenhum registro, no caso exercicio nunca executado ---
SELECT e.nome, e.grupo_muscular
FROM exercicios e
LEFT JOIN series s ON e.id = s.exercicio_id
WHERE s.id IS NULL;

SELECT id, data, duracao_min
FROM treinos
WHERE duracao_min > (
  SELECT AVG(duracao_min) FROM treinos
);

SELECT AVG(duracao_min) FROM treinos;


SELECT exercicio_id, COUNT(*) as total_series, SUM(repeticoes) as total_reps
FROM series
GROUP BY exercicio_id
HAVING COUNT(*) >= 3;

SELECT e.nome, e.grupo_muscular, COUNT(s.id) as total_series
FROM exercicios e
JOIN series s ON e.id = s.exercicio_id
GROUP BY e.id, e.nome, e.grupo_muscular
ORDER BY total_series DESC; 

SELECT id, data, duracao_min
FROM treinos
WHERE data >= '2026-01-01' AND data <= '2026-01-31';

SELECT 
 EXTRACT(MONTH FROM data) AS mes,
 COUNT(*) AS total_treinos,
 ROUND(AVG(duracao_min), 2) AS media_duracao
FROM treinos
GROUP BY EXTRACT(MONTH FROM data)
ORDER BY mes;
---- FIRST time usando o With, tipo tabela temporária.
WITH resumo_por_exercicio AS (
 SELECT
   exercicio_id,
   COUNT(*) AS total_series,
   SUM(repeticoes) AS total_reps,
   ROUND(AVG(peso_kg), 2) AS media_peso
 FROM series
 GROUP BY exercicio_id
)
SELECT
  e.nome,
  e.grupo_muscular,
  r.total_series,
  r.total_reps,
  r.media_peso
FROM resumo_por_exercicio r
JOIN exercicios e ON e.id = r.exercicio_id
ORDER BY r.total_reps DESC;
---- Usando Window Function
SELECT 
  e.nome,
  e.grupo_muscular,
  SUM(s.repeticoes) AS total_reps,
  ROW_NUMBER() OVER (PARTITION BY e.grupo_muscular ORDER BY SUM(s.repeticoes)DESC)
AS posicao_no_grupo,
  RANK() OVER (ORDER BY SUM(s.repeticoes) DESC) AS ranking_geral
FROM series s
JOIN exercicios e ON e.id = s.exercicio_id
GROUP BY e.id, e.nome, e.grupo_muscular
ORDER BY e.grupo_muscular, posicao_no_grupo;
----- LAG olha para a linha anterior de uma coluna. 
--- COALESCE ajuda a substituir os valores NULL por um indicado. NO caso pelo valor atual.
SELECT
  t.data,
  e.nome AS exercicio,
  ROUND(AVG(s.peso_kg)::NUMERIC, 2) AS peso_medio,
  COALESCE(
    LAG(ROUND(AVG(s.peso_kg)::NUMERIC, 2)) OVER (
      PARTITION BY e.nome ORDER BY t.data
    ),
    ROUND(AVG(s.peso_kg)::NUMERIC, 2)
  ) AS peso_treino_anterior
FROM series s
JOIN exercicios e ON s.exercicio_id = e.id
JOIN treinos   t ON s.treino_id    = t.id
GROUP BY t.data, e.nome
ORDER BY e.nome, t.data;
--- LEAD 

SELECT
	t.id,
	t.data,
	t.duracao_min,
	LEAD(data) OVER (ORDER BY data) AS proximo_treino,
	LEAD(data) OVER (ORDER BY data) - data AS dias_ate_proximo
from treinos t
ORDER BY data;

-- Lista as tabelas e as colunas e os tipos de dados de cada coluna.

SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('treinos', 'exercicios', 'series')
ORDER BY table_name, ordinal_position;

--- Diferenã entre RANK e DENSE_RANK
WITH volume AS (
  SELECT
    e.nome,
	e.grupo_muscular,
	SUM(s.peso_kg * s.repeticoes) AS volume_total
  FROM series s
  JOIN exercicios e ON s.exercicio_id = e.id
  GROUP BY e.nome, e.grupo_muscular
)

SELECT 
  nome,
  grupo_muscular,
  ROUND(volume_total::NUMERIC, 1) AS volume_total,
  RANK() OVER (ORDER BY volume_total DESC) AS rank_com_lacuna,
  DENSE_RANK() OVER(ORDER BY volume_total DESC) AS dense_rank
FROM volume
ORDER BY volume_total DESC;
----
WITH volume AS (
  SELECT
    e.grupo_muscular,
    SUM(s.peso_kg * s.repeticoes) AS volume_total
  FROM series s
  JOIN exercicios e ON s.exercicio_id = e.id
  GROUP BY e.grupo_muscular
)
SELECT
  grupo_muscular,
  ROUND(volume_total::NUMERIC, 1) AS volume_total,
  RANK()       OVER (ORDER BY volume_total DESC) AS rank_com_lacuna,
  DENSE_RANK() OVER (ORDER BY volume_total DESC) AS dense_rank
FROM volume
ORDER BY volume_total DESC;

--- 

WITH intensidade AS (
  SELECT
    t.id,
    t.data,
    t.duracao_min,
    SUM(s.peso_kg * s.repeticoes) AS volume_total
  FROM series s
  JOIN treinos t ON s.treino_id = t.id
  GROUP BY t.id, t.data, t.duracao_min
)
SELECT
  id,
  data,
  duracao_min,
  ROUND(volume_total::NUMERIC, 1) AS volume_total,
  NTILE(4) OVER (ORDER BY volume_total) AS quartil
FROM intensidade
ORDER BY volume_total;