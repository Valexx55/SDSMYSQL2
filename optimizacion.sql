EXPLAIN SELECT 
    COUNT(*) AS num_pacientes_grupo,
    FLOOR(peso / 10) * 10 AS grupo_peso
FROM
    pacientes
GROUP BY grupo_peso;

EXPLAIN ANALYZE SELECT 
    COUNT(*) AS num_pacientes_grupo,
    FLOOR(peso / 10) * 10 AS grupo_peso
FROM
    pacientes
GROUP BY grupo_peso;






/**
para mejorar:

1) hacemos de gurpo_peso un dato calculado
2) creamos un índice sobre el dato calculado
**/

ALTER TABLE pacientes ADD COLUMN grupo_peso INT GENERATED ALWAYS AS (FLOOR(peso / 10) * 10) STORED;

CREATE INDEX idx_grupo_peso ON pacientes(grupo_peso);


EXPLAIN SELECT 
    COUNT(*) AS num_pacientes_grupo,
    grupo_peso
FROM
    pacientes
GROUP BY grupo_peso;

EXPLAIN ANALYZE SELECT 
    COUNT(*) AS num_pacientes_grupo,
    grupo_peso
FROM
    pacientes
GROUP BY grupo_peso;


SELECT 
    COUNT(*) AS num_pacientes_grupo,
    grupo_peso
FROM
    pacientes
GROUP BY grupo_peso;


-- analizamos la optimización de la siguiente consulta

EXPLAIN SELECT 
    alergias.nombre, 
    COUNT(*) AS num_pacientes
FROM
    paciente_alergia
JOIN
    alergias ON paciente_alergia.alergia_id = alergias.alergia_id
GROUP BY 
    alergias.nombre
ORDER BY 
    num_pacientes DESC
LIMIT 1;

-- 1) REORGANIZAMOS LA CONSULTA EN 2 CONSUBLTAS PARA FORZAR A QUE PRIMERO AGRUPE Y LUEGO ORDENE (ASÍ "GASTA MENOS)
-- 2) AGRUPAR USANDO EL ID - siempre es más óptimo

SELECT nombre, num_pacientes
FROM (
    SELECT 
        a.alergia_id,
        a.nombre, 
        COUNT(*) AS num_pacientes
    FROM paciente_alergia pa
    JOIN alergias a ON pa.alergia_id = a.alergia_id
    GROUP BY a.alergia_id, a.nombre
) AS sub
ORDER BY num_pacientes DESC
LIMIT 1;



-- PARA EXPORTAR
/**

 1) mysql -u usuario -p -D basededatos -e "SELECT * FROM tabla;" > resultado.txt
 
 2) DESDE WL WORKBENCH -- EXPORT (ELEGIR EL FORMATO)
 
 3) AGREGANDO EL OUTFILE A LA CONSULTA
 
SHOW VARIABLES LIKE 'secure_file_priv'; -- a qué directorio puedo exportar

SELECT 
    COUNT(*) AS num_pacientes_grupo,
    grupo_peso
FROM
    pacientes
GROUP BY grupo_peso
INTO OUTFILE '/var/lib/mysql-files/archivo5.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

*/

SELECT user, host FROM mysql.user;



