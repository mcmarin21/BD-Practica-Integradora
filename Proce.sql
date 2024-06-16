USE Autolavado;

DELIMITER //

CREATE PROCEDURE ReporteDiarioVentas()
BEGIN
    SELECT paquete.descripcion AS 'Tipo de servicio', COUNT(*) AS 'Numero de ventas', SUM(ticket.total) AS Total
    FROM ticket
    INNER JOIN paquete ON ticket.paquete = paquete.id_paquete
    WHERE DATE(ticket.fecha) = CURDATE()
    GROUP BY paquete.descripcion;
END; //

CREATE PROCEDURE BuscarCliente(
	IN $nombre VARCHAR(50)
)
BEGIN
    SELECT cliente.nombre, cliente.apellido_paterno, cliente.apellido_materno, membresia.membresia,
    paquete.descripcion AS 'Tipo de servicio', ticket.fecha
    FROM cliente
    INNER JOIN membresia ON cliente.id_membresia = membresia.id_membresia
    INNER JOIN ticket ON cliente.curp = ticket.cliente
    INNER JOIN paquete ON ticket.paquete = paquete.id_paquete
    WHERE cliente.nombre LIKE CONCAT('%', $nombre, '%')
    AND ticket.fecha >= DATE_SUB(CURDATE(), INTERVAL 10 DAY);
END; //

CREATE PROCEDURE BuscarPorNumero(
	IN $numero INT
)
BEGIN
    SELECT empleado.numero_empleado, empleado.nombre, empleado.apellido_paterno, empleado.apellido_materno, sucursal.nombre AS Sucursal,
    SUM(ticket.total) AS Total, AVG(ticket.total) AS Promedio
    FROM empleado
    INNER JOIN sucursal ON empleado.id_sucursal = sucursal.id_sucursal
    INNER JOIN ticket ON empleado.numero_empleado = ticket.operador
    WHERE empleado.numero_empleado = $numero
    AND ticket.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY empleado.numero_empleado;
END; //

CREATE PROCEDURE OperadorDelMes()
BEGIN
    SELECT empleado.numero_empleado, empleado.nombre, sucursal.nombre AS Sucursal, SUM(ticket.total) AS Total,
    CASE
        WHEN SUM(ticket.total) > 1000 THEN SUM(ticket.total) * 0.05
        ELSE 0
    END AS Bono,
    CASE
        WHEN SUM(ticket.total) > 1000 THEN 'Operador del mes'
        ELSE ''
    END AS Mensaje
    FROM empleado
    INNER JOIN sucursal ON empleado.id_sucursal = sucursal.id_sucursal
    INNER JOIN ticket ON empleado.numero_empleado = ticket.operador
    GROUP BY empleado.numero_empleado;
END; //

CREATE PROCEDURE ReporteServiciosCliente(
	IN $nombre VARCHAR(50)
)
BEGIN
    SELECT cliente.nombre, cliente.apellido_paterno, cliente.apellido_materno, paquete.descripcion AS 'Tipo de servicio',
    COUNT(*) AS 'Numero de servicios'
    FROM ticket
    INNER JOIN cliente ON ticket.cliente = cliente.curp
    INNER JOIN paquete ON ticket.paquete = paquete.id_paquete
    INNER JOIN empleado ON ticket.operador = empleado.numero_empleado
    WHERE empleado.nombre LIKE CONCAT('%', $nombre, '%')
    GROUP BY cliente.curp, paquete.descripcion;
END; //

CREATE PROCEDURE AgregarSucursal(
    IN $nombre VARCHAR(50),
    IN $direccion VARCHAR(100),
    IN $telefono VARCHAR(15)
)
BEGIN
    DECLARE $existe INT DEFAULT 0;
    SELECT COUNT(*) INTO $existe
    FROM sucursal
    WHERE nombre = $nombre;
    IF $existe > 0 THEN
        SELECT 'La sucursal ya existe.';
    ELSE
        INSERT INTO sucursal (nombre, direccion, telefono)
        VALUES ($nombre, $direccion, $telefono);
        SELECT 'Sucursal agregada exitosamente.';
    END IF;
END; //

CREATE PROCEDURE AgregarEmpleado(
    IN $numero_empleado INT,
    IN $id_puesto INT,
    IN $id_horario INT,
    IN $nombre VARCHAR(50),
    IN $apellido_paterno VARCHAR(50),
    IN $apellido_materno VARCHAR(50),
    IN $fecha_nacimiento DATE,
    IN $curp CHAR(18)
)
BEGIN
    DECLARE $existeEmpleado INT DEFAULT 0;
    SELECT COUNT(*) INTO $existeEmpleado
    FROM empleado
    WHERE numero_empleado = $numero_empleado;
    IF $existeEmpleado > 0 THEN
        SELECT 'El empleado ya existe.';
    ELSE
        START TRANSACTION;
        INSERT INTO empleado (numero_empleado, id_puesto, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, curp)
        VALUES ($numero_empleado, $id_puesto, $nombre, $apellido_paterno, $apellido_materno, $fecha_nacimiento, $curp);
        INSERT INTO cronograma (numero_empleado, id_horario)
        VALUES ($numero_empleado, $id_horario);
        COMMIT;
        SELECT 'Empleado agregado exitosamente.';
    END IF;
END; //

CREATE PROCEDURE AgregarCliente(
    IN $curp CHAR(18),
    IN $membresia INT,
    IN $direccion INT,
    IN $nombre VARCHAR(50),
    IN $apellido_paterno VARCHAR(50),
    IN $apellido_materno VARCHAR(50),
    IN $fecha DATE,
    IN $placa CHAR(8),
    IN $modelo VARCHAR(50),
    IN $ano INT,
    IN $color VARCHAR(25),
    IN $tipo_contacto INT,
    IN $contacto VARCHAR(76)
)
BEGIN
    DECLARE $existeCliente INT DEFAULT 0;
    DECLARE $existeCoche INT DEFAULT 0;
    
    SELECT COUNT(*) INTO $existeCliente
    FROM cliente
    WHERE curp = $curp;
    
    SELECT COUNT(*) INTO $existeCoche
    FROM coche
    WHERE placa = $placa;
    
    IF $existeCliente > 0 THEN
        SELECT 'El cliente ya existe.';
    ELSEIF $existeCoche > 0 THEN
        SELECT 'El coche con esa placa ya existe.';
    ELSE
        START TRANSACTION;
        INSERT INTO cliente (curp, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
        VALUES ($curp, $membresia, $direccion, $nombre, $apellido_paterno, $apellido_materno, $fecha);
        INSERT INTO coche (placa, curp, modelo, ano, color)
        VALUES ($placa, $curp, $modelo, $ano, $color);
        INSERT INTO contacto (curp, id_tipo_contacto, contacto)
        VALUES ($curp, $tipo_contacto, $contacto);  
        COMMIT;
        SELECT 'Cliente agregado exitosamente.';
    END IF;
END;