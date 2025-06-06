-- VAMOS A CREAR UNA TABLA NUEVA, QUE CALCULE EL IMC DE CADA PACIENTE NUEVO
CREATE TABLE imc_pacientes (
    imc_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    imc DECIMAL(5,2) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(paciente_id)
);

-- CREAMOS UN DISPARADOR, CADA VEZ QUE HAYA UN INSERT NUEVO EN PACIENTES, GENERAMOS EL REGISTRO CORRESPONDIENTE EN IMC_PACIENTES
DELIMITER $$

CREATE TRIGGER trg_calcular_imc
AFTER INSERT ON pacientes
FOR EACH ROW
BEGIN
    DECLARE imc_val DECIMAL(5,2);

    -- Calculamos IMC = peso (kg) / (altura (m))^2
    -- Aseguramos que peso y altura no sean NULL ni 0 para evitar errores
    IF NEW.peso IS NOT NULL AND NEW.altura IS NOT NULL AND NEW.altura > 0 THEN
        SET imc_val = NEW.peso / (NEW.altura * NEW.altura);
    ELSE
        SET imc_val = NULL;
    END IF;

    -- Insertamos el IMC en la tabla imc_pacientes solo si es válido
    IF imc_val IS NOT NULL THEN
        INSERT INTO imc_pacientes(paciente_id, imc)
        VALUES (NEW.paciente_id, imc_val);
    END IF;
END $$

INSERT INTO pacientes (nombre, apellido, peso, altura) VALUE ('Pepa', 'Gómez', 50, 1.69);

-- incluimos un nuevo disparador para que, cuando se modifique un paciente, se actualice su imc asociado
-- dentro de un disparador, puedo invocar a funciones, pero no a procedimientos

DELIMITER $$

CREATE TRIGGER trg_actualizar_imc
AFTER UPDATE ON pacientes
FOR EACH ROW
BEGIN
    DECLARE imc_val DECIMAL(5,2);

    -- Calculamos el nuevo IMC si peso o altura cambiaron y son válidos
    IF (NEW.peso <> OLD.peso OR NEW.altura <> OLD.altura) 
       AND NEW.peso IS NOT NULL AND NEW.altura IS NOT NULL AND NEW.altura > 0 THEN

        SET imc_val = NEW.peso / (NEW.altura * NEW.altura);

        -- Actualizamos el IMC en la tabla imc_pacientes
        UPDATE imc_pacientes
        SET imc = imc_val,
            fecha_registro = CURRENT_TIMESTAMP
        WHERE paciente_id = NEW.paciente_id;

        -- Si no existe el registro de IMC, lo insertamos
        IF ROW_COUNT() = 0 THEN
            INSERT INTO imc_pacientes (paciente_id, imc)
            VALUES (NEW.paciente_id, imc_val);
        END IF;
    END IF;
END $$

-- HACED UN DISPARADOR, PARA QUE CUANDO SE ELIMINE UN PACIENTE, SE ELIMINE TAMBIÉN EL REGISTRO ASICOADO EN IMC_PACIENTES

DELIMITER $$

CREATE TRIGGER trg_eliminar_imc
BEFORE DELETE ON pacientes
FOR EACH ROW
BEGIN
    DELETE FROM imc_pacientes WHERE paciente_id = OLD.paciente_id;
END $$
	
DELIMITER ;

-- definimos un nuevo disparadador para controlar una regla de negocio y es que:
-- no puedo haber más de dos asignaciones al mismo doctor el mismo día

DELIMITER $$

CREATE TRIGGER trg_limitacion_pacientes_por_medico
BEFORE INSERT ON admisiones
FOR EACH ROW
BEGIN
	DECLARE admisiones_hoy INT;
    
	IF NEW.doctor_id IS NOT NULL THEN -- 0 compruebo el id del doctor (pq puede ser null)
         -- 1 calcular el número de admisiones que ha tenido un doctor en la fecha actual
		SELECT COUNT(*) INTO admisiones_hoy
		FROM admisiones
		WHERE doctor_id = NEW.doctor_id
		AND DATE(fecha_admision) = DATE(NEW.fecha_admision);
		-- 2 si el número de admisiones del paso 1 es mayor o igual a 2, LANZAMOS UN ERROR
		IF admisiones_hoy >= 2 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Error: El doctor ya tiene asignados 2 pacientes en esta fecha.';
		END IF;
	END IF;
    
END $$
	
DELIMITER ;


-- VAMOS A HACER UN PROCEDMINETO PARA INSERTAR A UN PACIENTE EN ADMISIONES
DELIMITER $$

CREATE PROCEDURE insertar_admision (
	IN id_paciente INT,
    IN id_doctor INT
	)
BEGIN
	INSERT INTO admisiones (
		fecha_admision, 
		fecha_alta,
		diagnostico,
		paciente_id,
		doctor_id)
    VALUES (
		NOW(),
		NULL,
		'En observación',
		id_paciente,
		id_doctor);
    
END $$
	
DELIMITER ;

call insertar_admision(5, 5);
call insertar_admision(6, 5);

call insertar_admision(7, 5);
-- Error Code: 1644. Error: El doctor ya tiene asignados 2 pacientes en esta fecha.

--  ejemplo de transacción gestionada por el programador
-- SET autocommit=1; -- las operaciones de modificación, se hacen de verdad, se confirman autmáticamente
SET autocommit=0;
START TRANSACTION; -- inicio una conversación

INSERT INTO pacientes(nombre, apellido, peso, altura)
VALUES ('Juan', 'Pérez', 75, 1.75);

ROLLBACK; -- DESHACE LAS OPERACIONES EJECUTADAS DESDE START TRANSACTION
-- COMMIT; -- confirmar las operaciones


-- VAMOS A MODIFICAR EL PROCEDMINETO GESTIONANDO LA TX
DELIMITER $$

CREATE PROCEDURE insertar_admision_tx (
	IN id_paciente INT,
    IN id_doctor INT,
    OUT mensaje_salida VARCHAR(500)
	)
BEGIN
	
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE vsqlstate CHAR(5) DEFAULT '00000';
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    
    -- SECCIÓN "PARACAÍDAS" GESTIÓN DE LA POTENCIAL EXCEPCIÓN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- OBTENER un detalle de la excepción y reflejarlo en la variable mensaje_salida
        -- opcional REGISTRAR EL FALLO, HACIENDO INSERTS EN TABLAS DE LOG PROPIAS
        GET DIAGNOSTICS CONDITION 1 -- OBNTEGO INFO DE LA ÚLTIMA EXCEPCIÓN OCURRIDA	
			codigo_error = MYSQL_ERRNO, -- error de la base de datos
			vsqlstate = RETURNED_SQLSTATE, -- valor SIGNAL definido por el programador
            mensaje_error = MESSAGE_TEXT;
			
            SET mensaje_salida = CONCAT ('ERROR', codigo_error, ' ' ,mensaje_error, ' ', vsqlstate);
    
		ROLLBACK;
    END;
	
	START TRANSACTION; -- no es necesario indicar autocommit a falso, al delcarar en el proc esta línea

	INSERT INTO admisiones (
		fecha_admision, 
		fecha_alta,
		diagnostico,
		paciente_id,
		doctor_id)
    VALUES (
		NOW(),
		NULL,
		'En observación',
		id_paciente,
		id_doctor);
     
    SET mensaje_salida = 'Insereción exitosa :)';
	COMMIT;  -- CONFIRMAMOS
    
END $$
	
DELIMITER ;

SET @mensaje='';
call insertar_admision_tx(6, 6, @mensaje);
SELECT @mensaje;

SET @mensaje='';
call insertar_admision_tx(7, 5, @mensaje);
SELECT @mensaje;


