/****

UPDATE Y DELETE

****/

-- ACTUALIZAR TODOS LOS REGISTROS DE AMISIONES CON FECHA DE ALTA A LA FECHA ACTUAL
SET SQL_SAFE_UPDATES = 0; -- ALTER SESSION EQUIVALENTE EN ORACLE O DE MANERA PERMANENTE mysql --safe-updates=0 -u usuario -p
UPDATE admisiones
SET fecha_alta = CURDATE();
SET SQL_SAFE_UPDATES = 1;

-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  
-- To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
UPDATE pacientes
SET apellido='Martínez'
WHERE paciente_id = 1;

-- AUMENTAR EL 1K EL PESO DE TODOS LOS PACIENTES DE LA PROVINCIA DE 'Madrid'

-- ORDEN...IMPORTANTE
/*
*
UPDATE nombre_tabla
JOIN ...
SET no puede ir antes del JOIN
WHERE no puede ir antes del SET
*/


UPDATE pacientes
        JOIN
    poblaciones ON poblaciones.poblacion_id = pacientes.poblacion_id
        JOIN
    provincias ON poblaciones.provincia_id = provincias.provincia_id 
SET 
    peso = peso + 1
WHERE
    provincias.nombre = 'Madrid';
    
-- ACTUALIZAR EL DIAGNÓSTICO DE LAS ADMSIOIONES QUE NO TIENE FECHA DE ALTA A "EN OBSERVACIÓN"
SET SQL_SAFE_UPDATES = 0; -- ALTER SESSION EQUIVALENTE EN ORACLE O DE MANERA PERMANENTE mysql --safe-updates=0 -u usuario -p
UPDATE admisiones
SET diagnostico='En Observación'
WHERE fecha_alta IS NULL;
SET SQL_SAFE_UPDATES = 1; -- ALTER SESSION EQUIVALENTE EN ORACLE O DE MANERA PERMANENTE mysql --safe-updates=0 -u usuario -p

-- BORRAR EL PACIENTE 5
DELETE FROM pacientes
WHERE paciente_id = 5;

/**
Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails 
(`hospital_profe`.`admisiones`, CONSTRAINT `admisiones_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`))
(`hospital_profe`.`admisiones`, CONSTRAINT `admisiones_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`))


Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails 
(`hospital_profe`.`admisiones`, CONSTRAINT `admisiones_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`paciente_id`))


*/

-- ELIMINAD LAS ADMSIONES CON ANTIGÜEDAD MAYOR A 5 AÑOS
SET SQL_SAFE_UPDATES = 0; 
DELETE FROM admisiones
WHERE fecha_admision < DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
SET SQL_SAFE_UPDATES = 1; 

-- ELIMINAMOS LOS DOCTORES QUE EN EL ÚLTIMO AÑO, NO HAN TENIDO NINGUNA ADMISIÓN

SET SQL_SAFE_UPDATES = 0;
DELETE d
FROM doctores d
LEFT JOIN admisiones a ON d.doctor_id = a.doctor_id
WHERE a.fecha_admision IS NULL
   OR a.fecha_admision < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
SET SQL_SAFE_UPDATES = 1; 


SELECT *
FROM doctores d
LEFT JOIN admisiones a ON d.doctor_id = a.doctor_id
WHERE a.fecha_admision IS NULL
   OR a.fecha_admision < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

