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

