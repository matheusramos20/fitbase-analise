SELECT nome, grupo_muscular
FROM exercicios
ORDER BY grupo_muscular, nome;

--Quantas séries foram realizadas por exercício, do mais treinado para o menos?

SELECT
    e.nome,
    COUNT(*) AS total_series
FROM series s
JOIN exercicios e ON s.exercicio_id = e.id
GROUP BY e.nome
ORDER BY total_series DESC;

-- Qual o peso máximo levantado em cada exercício?

SELECT
	e.nome,
	MAX(s.peso_kg) AS peso_maximo
FROM series s
JOIN exercicios e ON s.exercicio_id = e.id
GROUP BY e.nome
ORDER BY peso_maximo DESC;

-- Conta registros em cada tabela
SELECT 'exercicios' AS tabela, COUNT(*) FROM exercicios
UNION ALL
SELECT 'treinos',               COUNT(*) FROM treinos
UNION ALL
SELECT 'series',                COUNT(*) FROM series;


-- Ver os dados diretamente
SELECT * FROM exercicios;
SELECT * FROM treinos;
SELECT * FROM series LIMIT 10;