-- esto es un comentario de línea
/*
esto es un comentario multilínea
*/
-- CREATE SCHEMA `hospital`;

-- SELECCCIONAR NOMBRE, APELLIDO Y GÉNERO DE TODOS LOS PACIENTES CON GÉNERO MASCULINO

SELECT 
    nombre, apellido, genero
FROM
    pacientes
WHERE
    genero = 'M';
    
-- -- SELECCCIONAR NOMBRE Y APELLIDO DE LOS PACIENTES QUE EMPIEZAN POR LA LETRA C

SELECT 
    nombre, apellido
FROM
    pacientes
WHERE
    LEFT(nombre, 1) = 'C';


SELECT 
    nombre, apellido
FROM
    pacientes
WHERE
    SUBSTRING(nombre, 1, 1) = 'C';

SELECT 
    nombre, apellido
FROM
    pacientes
WHERE
    nombre LIKE 'C%';-- '%A%';

SELECT 
    nombre, apellido
FROM
    pacientes
WHERE
    UPPER(nombre) LIKE 'C%';
 
--  -- SELECCIONAR NOMBRE, APELLIDO Y PESO DE LOS PACIENTES QUE ESTÉN ENTRE 70 Y 90 KG
 
SELECT 
    nombre, peso
FROM
    pacientes
WHERE
    peso BETWEEN 70 AND 90;
    
    
SELECT 
    nombre, apellido, peso
FROM
    pacientes
WHERE
    (peso >= 70) AND (peso <= 90);


-- SELECCIONAR DE PACIENTES EL NOMBRE Y APELLIDO QUE APREZCA BAJO UN ÚNICA COLUMNA NOMBRE COMPLETO

SELECT 
    CONCAT(nombre, ' ', apellido) AS nombre_completo
FROM
    pacientes;

-- SELECCIONAR EL NÚMERO DE PACIENTES COMO "TOTAL PACIENTES" NACIDOS EN 1980
SET @year := 1990;
SELECT 
    COUNT(*) AS 'TOTAL PACIENTES'
FROM
    pacientes
WHERE
    YEAR(fecha_nacimiento) = @year;
    
SELECT 
    COUNT(*) AS 'TOTAL PACIENTES'
FROM
    pacientes
WHERE
    fecha_nacimiento BETWEEN '1980-01-01' AND '1989-12-31';

-- SELECCIONAR NOMBRE Y PESO DEL PACIENTE CON MAYOR PESO

SELECT 
    nombre, apellido, peso
FROM
    pacientes
ORDER BY peso DESC -- ASC 
LIMIT 1;

SELECT 
    nombre, apellido, peso
FROM
    pacientes
WHERE
    peso = (
		SELECT 
            MAX(peso)
        FROM
            pacientes
            );
-- SELECCIONAR NOMBRE Y NOMBRE DE SU POBLACIÓN QUE SEAN DE Badalona       

SELECT 
    pa.nombre, po.nombre
FROM
    pacientes pa,
    poblaciones po
WHERE
    pa.poblacion_id = po.poblacion_id
        AND po.nombre = 'Badalona';






SELECT 
    pa.nombre
FROM
    pacientes pa
WHERE
    pa.poblacion_id IN (SELECT 
            poblacion_id
        FROM
            poblaciones
        WHERE
            nombre = 'Badalona');


-- SELECIONAR LOS NOMBRES DE LOS PACIENTES Y SU ID DE ALERGIA ( EN CASO QUE TENGAN ALGUNA )
SELECT 
    p.nombre, pa.alergia_id
FROM
    pacientes p -- TABLA A
        INNER JOIN
    paciente_alergia pa ON p.paciente_id = pa.paciente_id; -- TABLA B

SELECT 
    p.nombre, pa.alergia_id
FROM
    pacientes p
		JOIN
    paciente_alergia pa ON p.paciente_id = pa.paciente_id;
    
-- -- SELECIONAR LOS NOMBRES DE LOS PACIENTES Y SU NOMBRE DE ALERGIA ( EN CASO QUE TENGAN ALGUNA )


SELECT 
    p.nombre, pa.alergia_id, a.nombre
FROM
    pacientes p
		JOIN
    paciente_alergia pa ON p.paciente_id = pa.paciente_id
		JOIN 
	alergias a ON a.alergia_id = pa.alergia_id;

-- SELECCIONAR EL NOMBRE DE LOS PACIENTES QUE NO TIENEN NINGUNA ALERGIA:
-- HACEDLO CON LEFT JOIN Y SIN JOIN (CONSULTA ANIDADA)

SELECT 
    p.nombre -- , pa.alergia_id
FROM
    pacientes p -- TABLA A
        LEFT JOIN
    paciente_alergia pa ON p.paciente_id = pa.paciente_id -- TABLA B
    WHERE
		pa.alergia_id IS NULL;
        
SELECT 
    nombre
FROM
    pacientes
WHERE
    paciente_id NOT IN (SELECT 
            paciente_id
        FROM
            paciente_alergia);


SELECT 
    p.nombre
FROM
    paciente_alergia pa
        RIGHT JOIN
    pacientes p ON pa.paciente_id = p.paciente_id
WHERE
    alergia_id IS NULL;
    
  /**
  DISTINCT - ELIMINAR DUPLICADOS
  */
  
SELECT DISTINCT
    especialidad
FROM
    doctores;

-- DISTINTCT + COUNT 

SELECT COUNT(DISTINCT
    especialidad) AS total_especialidades
FROM
    doctores;
    
-- sacad un listado de las polbaciones donde viven los pacientes (sin repetirse)

-- Error Code: 1052. Column 'nombre' in field list is ambiguous

SELECT DISTINCT
    po.nombre
FROM
    poblaciones po
        JOIN
    pacientes pa ON pa.poblacion_id = po.poblacion_id;

-- SELECCIONAMOS LAS ALERGIAS QUE ESTÁN ASOCIADAS A ALGÚN PACIENTE

SELECT DISTINCT
    a.nombre
FROM
    alergias a
        JOIN
    paciente_alergia pa ON pa.alergia_id = a.alergia_id;
    
/** FUNCIONES DE AGREAGACIÓN ( COUNT, SUM, AVG, MAX, MIN, ETC.) */

-- CUÁNTAS PERSONAS NO TIENEN EL ALTA (PACIENTES QUE EN ADMISIONES, TIENE SU FECHA DE ALTA A NULL)

SELECT -- forma preferida
    COUNT(*) AS pacientes_ingresados
FROM
    admisiones
WHERE
    fecha_alta IS NULL;
    
SELECT 
    COUNT(1) AS pacientes_ingresados
FROM
    admisiones
WHERE
    fecha_alta IS NULL;

-- CUÁNTAS PERSONAS TIENEN EL ALTA (PACIENTES QUE EN ADMISIONES, TIENE SU FECHA De dalta != null)

SELECT  -- forma preferida
    COUNT(fecha_alta) AS pacientes_de_alta -- COUNT (NOMBRE_DEL_CAMPO) --> No contabiliza al registro si ese valor es nulo en la fila
FROM
    admisiones;
    
SELECT 
    COUNT(*) AS pacientes_de_alta -- COUNT (NOMBRE_DEL_CAMPO) --> No contabiliza al registro si ese valor es nulo en la fila
FROM
    admisiones WHERE fecha_alta IS NOT NULL;

-- OBTENER LA MEDIA DEL PESO DE TODOS LOS PACIENTES. REDONDEARLA A UN DECIMAL

SELECT 
    ROUND(AVG(peso), 1) AS peso_medio
FROM
    pacientes;

-- OBTENER LA MEDIA DE LA ALTURA DE TODOS LOS PACIENTES (expresada en CM) . REDONDEADA A UN DECIMAL

SELECT 
    ROUND(AVG(altura)*100, 1) AS altura_media_cm
FROM
    pacientes;

-- obtener la diferencia mayor entre el peso máximo y mínimo de los pacientes

SELECT 
    MAX(peso)-MIN(peso) AS diferencia_peso
FROM
    pacientes;


-- MOSTRAR EL NÚMERO TOTAL DE PACIENTES , EL NÚMERO TOTAL DE HOMBRES Y EL NÚMERO TOTAL DE MUJERES (3 COLUMNAS) 
-- count(*)
SELECT COUNT(*) AS total_pacientes, 
	SUM(CASE WHEN genero='M' THEN 1 ELSE 0 END) AS total_hombres,
    SUM(CASE WHEN genero='F' THEN 1 ELSE 0 END) AS total_muejres
 FROM pacientes;
 
 -- DADO UN PACIENTE, CONSULTAD CUÁNTAS ADMISIONES HA TENIDO. DEPUÉS, REFINAMOS LA CONUSLTA Y SACAMOS CUÁNTAS EN EL ÚLTIMO MES.
 
SET @paciente := 2;
SELECT 
    COUNT(*) AS ingresos_ultimo_mes
FROM
    admisiones
WHERE
    admisiones.paciente_id = @paciente
AND fecha_admision >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH); -- Y SU FECHA DE ADMISIÓN SEA ANTERIOR A UN MES DESDE LA  CURDATE()
 
 
 -- LISTADO DE ALERGIAS AGRUPADO POR EL NOMBRE DE LA ALERGIA Y EL NÚMERO DE PACIENTES QUE LA TIENEN

SELECT alergias.nombre, COUNT(*) AS num_pacientes -- SI COMBINO UNA F() DE AGREGACIÓN CON OTRO DATO --> DEBO USAR GROUP BY
FROM paciente_alergia
JOIN alergias ON alergias.alergia_id = paciente_alergia.alergia_id
GROUP BY alergias.nombre;

-- OJO AL FALLO SI NO USO GROUP BY Error Code: 1140. 
-- In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'hospital_profe.alergias.nombre'; this is incompatible with sql_mode=only_full_group_by

-- VISUALIZAMOS EL MODO EN QUE ESTÁ TRABAJANDO LA BASE DE DATOS
-- SELECT @@SESSION.sql_mode;
SELECT @@sql_mode;

SET SESSION sql_mode = REPLACE(@@SESSION.sql_mode, 'ONLY_FULL_GROUP_BY,', '');


-- EL NÚMERO DE ADMISIONES POR PROVINCIA odernado por el número de admisiones de mayor a menor y por el nombre de provincias alfabéticamente
/**
1- QUÉ DATOS TENGO QUE OBTENER (CALCULADOS O NO), -select 
2 - DE QUÉ TABLA(S) - from / join
3 - CÓMO LOS AGRUPO
4 - ORDENAMOS LOS DATOS
**/
SELECT provincias.nombre , COUNT(admisiones.admisiones_id) AS num_admisiones
FROM admisiones
JOIN pacientes ON admisiones.paciente_id = pacientes.paciente_id
JOIN poblaciones ON pacientes.poblacion_id = poblaciones.poblacion_id
JOIN provincias ON provincias.provincia_id = poblaciones.provincia_id
GROUP BY provincias.nombre
ORDER BY num_admisiones DESC, provincias.nombre ASC;

-- PROVINCIAS CON MÁS DE 2 PACIENTES
/**
1- QUÉ DATOS TENGO QUE OBTENER (CALCULADOS O NO), -select 
2 - DE QUÉ TABLA(S) - from / join
3 - CÓMO LOS AGRUPO
4 - ORDENAMOS LOS DATOS
5 - FILTRO CON HAVING / LIMIT
**/

SELECT provincias.nombre, COUNT(*) as num_pacientes
FROM provincias 
JOIN poblaciones ON poblaciones.provincia_id = provincias.provincia_id
JOIN pacientes ON poblaciones.poblacion_id = pacientes.poblacion_id
GROUP BY provincias.nombre
HAVING num_pacientes >2;


-- CONSULTAR LA ALEGIA MÁS COMÚN
/*
1 datos - select nombre alergia, número de pacientes
2 TABLAS - paciente alergia, alergia
3 - gruop by - nombre alergia
4 - ordenación
5 - filtrado
*/


SELECT alergias.nombre, COUNT(*) AS num_pacientes
FROM paciente_alergia
JOIN alergias ON paciente_alergia.alergia_id = alergias.alergia_id
GROUP BY alergias.nombre
ORDER BY num_pacientes DESC
LIMIT 1; 


-- CTE Common Table Expressions MYSLQ 8 "TABLAS TEMPORALES"
/*
1) obtengo alergias y número de veces que aparecen
2) cuales el número de máximo de veces que aparece una alergia (intermadia)
3)  DE LAS ALERGIAS DE (1), FILTRO LAS QUE COINCIDEN CON LA CANTIDAD (2)
*/

WITH alergias_con_conteo AS (
    SELECT 
        a.nombre,
        COUNT(*) AS cantidad
    FROM
        paciente_alergia pa
    JOIN 
        alergias a ON pa.alergia_id = a.alergia_id
    GROUP BY 
        a.nombre
),
cantidad_maxima AS (
    SELECT MAX(cantidad) AS max_cantidad
    FROM alergias_con_conteo
)
SELECT 
    ac.nombre,
    ac.cantidad
FROM 
    alergias_con_conteo ac
JOIN 
    cantidad_maxima cm ON ac.cantidad = cm.max_cantidad;
    
-- otra alterniva, serían las subconsultas para versiones anteriores

SELECT 
    nombre, cantidad
FROM
    (SELECT 
        a.nombre, COUNT(*) AS cantidad
    FROM
        paciente_alergia pa
    JOIN alergias a ON pa.alergia_id = a.alergia_id
    GROUP BY pa.alergia_id , a.nombre) AS p
WHERE
    cantidad = (SELECT 
            MAX(cantidad)
        FROM
            (SELECT 
                COUNT(*) AS cantidad
            FROM
                paciente_alergia
            GROUP BY alergia_id) AS sub);

-- QUÉ PACIENTE, HA ESTADO MÁS DÍAS EN ADMISIÓN 

SELECT 
    p.paciente_id,
    p.nombre,
    p.apellido,
    SUM(
		DATEDIFF(
				IF(a.fecha_alta IS NOT NULL, a.fecha_alta, CURDATE()), -- fecha fin
				a.fecha_admision -- fecha inicio
				)
    ) AS dias_totales
FROM 
    admisiones a
JOIN 
    pacientes p ON a.paciente_id = p.paciente_id
GROUP BY 
    p.paciente_id, p.nombre, p.apellido
ORDER BY 
    dias_totales DESC
LIMIT 1;


-- MÁXIMO DÍAS PACIENTE INGRESADO CON CTES
-- (1) sacamos los días de cada paciente
-- (2) sacamos el máximo de días de estancia
-- (3) ME QUEDO con los pacientes de (1) que cumplan el criterio (2)


WITH dias_por_paciente AS (
SELECT 
    p.paciente_id,
    p.nombre,
    p.apellido,
    SUM(
		DATEDIFF(
				IF(a.fecha_alta IS NOT NULL, a.fecha_alta, CURDATE()), -- fecha fin
				a.fecha_admision -- fecha inicio
				)
    ) AS dias_totales
FROM 
    admisiones a
JOIN 
    pacientes p ON a.paciente_id = p.paciente_id
GROUP BY 
    p.paciente_id, p.nombre, p.apellido
), maximo AS 
(
	SELECT MAX(dias_totales) AS max_dias FROM dias_por_paciente
)
SELECT 
	d.paciente_id,
    d.nombre,
    d.apellido,
    d.dias_totales
FROM dias_por_paciente d
JOIN maximo ON d.dias_totales = maximo.max_dias;
    
/**
CONSULTAS CON COLUMNAS DE DATOS CALCULADOS /AGREGADOS
**/
    
-- EL NÚMERO DE PACIENTES AGRUPADOS EN CADA RANGO DE PESO, DE 10 , 10 DE MENOR A MAYOR
-- PEJ: 3 50kg 4 60kg 5 70
SELECT 
	COUNT(*) AS num_pacientes_grupo, 
    FLOOR(peso/10)*10 AS grupo_peso
FROM 
	pacientes
group by grupo_peso
ORDER BY grupo_peso ASC;

-- MOSTRAR EL ID , LA ALTURA Y PESO DE UN PACIENTE Y DECID ADEMÁS SI TIENE SOBREPESO, CON UN FLAG/BOOLEANO (0-1)
-- sobrepeso es cuando el Índice de Masa Corporal sea mayor que 25  IMC = peso kg / altura*altura m

SELECT 
    paciente_id,
    altura,
    peso,
    (peso / (POWER(altura, 2)) >= 25) AS sobrepeso
FROM
    pacientes
ORDER BY sobrepeso;


SELECT paciente_id, peso, altura,
  (CASE 
      WHEN (peso/POWER(p.altura,2)) >= 25 THEN
          1
      ELSE
          0
      END) AS SOBREPESO
FROM pacientes p;


SELECT paciente_id, peso, altura,
  IF(peso/POWER(p.altura,2) >= 25, 'Sí', 'No') AS SOBREPESO
FROM pacientes p;



