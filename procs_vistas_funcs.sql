/**
VISTA
**/

-- CREAMOS UNA VISTA PARA MOSTRAR PACIENTES Y ALERGIAS (vista no actualizable directamente con UPDATE: JOIN, GROUP BY, AVG())
CREATE OR REPLACE VIEW vista_pacientes_alergia AS
SELECT 
	p.paciente_id,
	p.nombre AS nombre_paciente, 
    p.apellido, 
	a.nombre AS nombre_alergia
FROM pacientes p
JOIN paciente_alergia pa ON p.paciente_id = pa.paciente_id
JOIN alergias a ON pa.alergia_id = a.alergia_id;

-- hacemos una vista que me muestre todos los datos de los pacientes, omitiendo EL GÉNERO Y LA FECHA DE NACIMIENTO (vista con Datos actualizables por UPDATE)
-- TODO probar a hacer un UPDATE sobre la vista
CREATE VIEW vista_pacientes_simplificada AS
SELECT
	paciente_id,
	nombre, 
    apellido, 
    peso,
    altura,
    poblacion_id
FROM pacientes;

-- CREAMOS UNA VISTA, PARA QUE ME DÉ EL DETALLE DE CUÁNDO HA SIDO ADMITIDO UN PACIENTE, SU NOMBRE, QUÉ DOCTOR LE HA ATENDIDO Y EL DIAGNOSITCO
CREATE VIEW vista_admisiones_detalle AS
SELECT
	p.nombre AS nombre_paciente,
    p.apellido AS apellido_paciente,
    a.fecha_admision, 
    a.diagnostico,
    d.nombre AS nombre_doctor,
    d.apellido AS apellido_doctor
FROM 
	admisiones a
JOIN pacientes p ON a.paciente_id = p.paciente_id
LEFT JOIN doctores d ON	d.doctor_id = a.doctor_id;
    
/**
PROCEDIMIENTOS / PROCEDURES
**/


-- Procedimineto para buscar los pacientes por su apellido .  Sólo nos hace falta la parte incial
-- ej: búscame los pacientes que empicen por M --> MORENO, MARTINEZ...

DELIMITER $$

CREATE PROCEDURE busqueda_paciente_por_apellido (IN prefijo VARCHAR(10)) -- CABECERA PARÁMETROS FORMALES
BEGIN
	-- CUERPO
    SELECT	
		*
	FROM pacientes	
    WHERE apellido LIKE CONCAT(prefijo, '%');
END $$

DELIMITER ;

-- EJEMPLO DE LLAMADA/ invocación
call hospital_profe.busqueda_paciente_por_apellido('M'); -- PARÁMETRO ACTUAL - han de coincidir en número, orden y tipo 
call hospital_profe.busqueda_paciente_por_apellido('S');


-- haced un procedmiento, que dado el id de un paciente, me diga cuántas admisiones ha tenido y el nombre completo (nombre + apellido)

DELIMITER $$

CREATE PROCEDURE info_paciente_admisiones (IN id_paciente INT, OUT num_admisiones INT , OUT nombre_completo VARCHAR(60)) -- CABECERA
BEGIN
	 -- cuántas admisiones ha tenido
     SELECT COUNT(*) INTO num_admisiones
     FROM admisiones
     WHERE paciente_id = id_paciente;
     
     -- nombre completo
     
     SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
     FROM pacientes
     WHERE paciente_id= id_paciente;
     
END $$

DELIMITER ;


set @num_admisiones = 0;
set @nombre_completo = '0';
call hospital_profe.info_paciente_admisiones(2, @num_admisiones, @nombre_completo);
select @num_admisiones, @nombre_completo;


-- HACER UNA FUNCIÓN, que dada la fecha de nacimiento, nos diga la edad

DELIMITER $$

CREATE FUNCTION calcular_edad (fecha_nac DATE) -- CABECERA
RETURNS INT -- TIPO DEVUELTO
DETERMINISTIC
BEGIN
      RETURN TIMESTAMPDIFF(YEAR,fecha_nac,CURDATE()); -- siempre un return 
END $$

DELIMITER ;

 -- Error Code: 1418. This function has none of DETERMINISTIC, 
  -- NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)





SELECT 
    nombre, apellido, CALCULAR_EDAD(fecha_nacimiento) AS EDAD, convertir_peso (peso) AS peso_coma
FROM
    pacientes;
    
-- AÑADIR UNA FUNCIÓN NUEVA, PARA PODER OBTENER EL LISTADO DE PACIENTES CON SU PESO EN FORMATO KG,D


-- TODO revisar mañana

DELIMITER $$

CREATE FUNCTION convertir_peso (peso DECIMAL) -- CABECERA
RETURNS VARCHAR(4) -- TIPO DEVUELTO
DETERMINISTIC
BEGIN
      RETURN REPLACE(FORMAT(peso, 1), '.', ',');
END $$

DELIMITER ;


-- función, que devuelve el nombre completo de un paciente dado un id

DELIMITER $$

CREATE FUNCTION nombre_completo(p_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA  -- cuando se accede a tablas
BEGIN
    DECLARE nombre_apellido VARCHAR(100); -- VARIABLE LOCAL
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_apellido
    FROM pacientes
    WHERE paciente_id = p_id;
    RETURN nombre_apellido;
END $$

DELIMITER ;

-- LLAMADA
SELECT nombre_completo(paciente_id) AS nombre_completo FROM pacientes; 
