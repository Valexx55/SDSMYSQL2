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

