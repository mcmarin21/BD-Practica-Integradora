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
    SELECT empleado.nempleado, empleado.nombre, empleado.apellido_paterno, empleado.apellido_materno, sucursal.nombre AS Sucursal,
    SUM(ticket.total) AS Total, AVG(ticket.total) AS Promedio
    FROM empleado
    INNER JOIN sucursal ON empleado.id_sucursal = sucursal.id_sucursal
    INNER JOIN ticket ON empleado.nempleado = ticket.operador
    WHERE empleado.nempleado = $numero
    AND ticket.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY empleado.nempleado;
END; //

CREATE PROCEDURE OperadorDelMes()
BEGIN
    SELECT empleado.nempleado, empleado.nombre, sucursal.nombre AS Sucursal, SUM(ticket.total) AS Total,
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
    INNER JOIN ticket ON empleado.nempleado = ticket.operador
    GROUP BY empleado.nempleado;
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
    INNER JOIN empleado ON ticket.operador = empleado.nempleado
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
        INSERT INTO sucursal (nombre, id_direccion, telefono)
        VALUES ($nombre, $direccion, $telefono);
        SELECT 'Sucursal agregada exitosamente.';
    END IF;
END; //

CREATE PROCEDURE AgregarEmpleado(
    IN $empleado INT,
    IN $sucursal INT,
    IN $puesto INT,
    IN $horario INT,
    IN $nombre VARCHAR(50),
    IN $apellido_paterno VARCHAR(50),
    IN $apellido_materno VARCHAR(50)
)
BEGIN
    DECLARE $existe INT DEFAULT 0;
    SELECT COUNT(*) INTO $existe
    FROM empleado
    WHERE numero_empleado = $empleado;
    IF $existe > 0 THEN
        SELECT 'El empleado ya existe.';
    ELSE
        START TRANSACTION;
        INSERT INTO empleado (numero_empleado, sucursal, puesto, nombre, apellido_paterno, apellido_materno)
        VALUES ($empleado, $sucursal, $puesto, $nombre, $apellido_paterno, $apellido_materno);
        INSERT INTO cronograma (numero_empleado, horario)
        VALUES ($empleado, $horario);
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
    DECLARE $cliente INT DEFAULT 0;
    DECLARE $coche INT DEFAULT 0;
    
    SELECT COUNT(*) INTO $cliente
    FROM cliente
    WHERE curp = $curp;
    
    SELECT COUNT(*) INTO $coche
    FROM coche
    WHERE placa = $placa;
    
    IF $cliente > 0 THEN
        SELECT 'El cliente ya existe.';
    ELSEIF $coche > 0 THEN
        SELECT 'El coche con esa placa ya existe.';
    ELSE
        START TRANSACTION;
        INSERT INTO cliente (curp, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
        VALUES ($curp, $membresia, $direccion, $nombre, $apellido_paterno, $apellido_materno, $fecha);
        INSERT INTO coche (placa, curp, modelo, año, color)
        VALUES ($placa, $curp, $modelo, $ano, $color);
        INSERT INTO contacto (curp, id_tipo_contacto, contacto)
        VALUES ($curp, $tipo_contacto, $contacto);  
        COMMIT;
        SELECT 'Cliente agregado exitosamente.';
    END IF;
END; //

CREATE PROCEDURE AgregarPromocionSucursal(
    IN $promocion INT,
    IN $sucursal INT,
    IN $fecha_inicio DATE,
    IN $fecha_fin DATE
)
BEGIN
    DECLARE $existe INT DEFAULT 0;
    SELECT COUNT(*) INTO $existe
    FROM promocion_sucursal
    WHERE id_promocion = $promocion AND id_sucursal = $sucursal;
    IF $existe > 0 THEN
        SELECT 'La promoción ya existe en la sucursal.';
    ELSE
        INSERT INTO promocion_sucursal (id_promocion, id_sucursal, fecha_inicio, fecha_fin)
        VALUES ($promocion, $sucursal, $fecha_inicio, $fecha_fin);
        SELECT 'Promoción agregada exitosamente a la sucursal.';
    END IF;
END; //

CREATE PROCEDURE AgregarHorario(
    IN $hora_entrada TIME,
    IN $hora_salida TIME
)
BEGIN
    INSERT INTO horario (hora_entrada, hora_salida)
    VALUES ($hora_entrada, $hora_salida);
    SELECT 'Horario agregado exitosamente.';
END; //

CREATE PROCEDURE AgregarContacto(
    IN $curp CHAR(18),
    IN $tipo_contacto INT,
    IN $contacto VARCHAR(76)
)
BEGIN
    INSERT INTO contacto (curp, id_tipo_contacto, contacto)
    VALUES ($curp, $tipo_contacto, $contacto);
    SELECT 'Contacto agregado exitosamente.';
END; //

CREATE PROCEDURE AgregarCoche(
    IN $placa CHAR(8),
    IN $curp CHAR(18),
    IN $modelo VARCHAR(50),
    IN $ano INT,
    IN $color VARCHAR(25)
)
BEGIN
    DECLARE $existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO $existe
    FROM coche
    WHERE placa = $placa;
    
    IF $existe > 0 THEN
        SELECT 'El coche con esa placa ya existe.';
    ELSE
        INSERT INTO coche (placa, curp, modelo, año, color)
        VALUES ($placa, $curp, $modelo, $ano, $color);
        SELECT 'Coche agregado exitosamente.';
    END IF;
END; //

CREATE PROCEDURE AgregarPuesto(
    IN $puesto VARCHAR(50),
    IN $salario DECIMAL(6,2)
)
BEGIN
    INSERT INTO puesto (puesto, salario)
    VALUES ($puesto, $salario);
    SELECT 'Puesto agregado exitosamente.';
END; //

CREATE PROCEDURE AgregarDireccion(
    IN $estado INT,
    IN $codigo_postal INT,
    IN $calle VARCHAR(250),
    IN $numero_exterior INT,
    IN $numero_interior INT
)
BEGIN
    INSERT INTO direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES ($estado, $codigo_postal, $calle, $numero_exterior, IFNULL($numero_interior, NULL));
    SELECT 'Dirección agregada exitosamente.';
END; //

CREATE PROCEDURE AgregarPaquete(
    IN $promocion VARCHAR(50),
    IN $descripcion VARCHAR(250),
    IN $precio DECIMAL(6,2)
)
BEGIN
    INSERT INTO paquete (promocion, descripcion, precio)
    VALUES ($promocion, $descripcion, $precio);
    SELECT 'Paquete agregado exitosamente.';
END; //

CREATE PROCEDURE GenerarTicket(
    IN $cliente CHAR(18),
    IN $operador INT,
    IN $coche CHAR(8),
    IN $sucursal INT,
    IN $tipo_pago INT,
    IN $paquete INT,
    IN $promocion INT,
    IN $comentario VARCHAR(250),
    IN $subtotal DECIMAL(8,2),
    IN $total DECIMAL(8,2)
)
BEGIN
    DECLARE $existe INT DEFAULT 0;
    DECLARE $ultimo INT;
    SELECT COUNT(*) INTO $existe
    FROM ticket
    WHERE cliente = $cliente AND coche = $coche AND sucursal = $sucursal;
    IF $existe > 0 THEN
        SELECT 'El ticket ya existe.';
    ELSE
        START TRANSACTION;
        INSERT INTO ticket (cliente, operador, coche, sucursal, tipo_pago, paquete, promocion, comentario, subtotal, total)
        VALUES ($cliente, $operador, $coche, $sucursal, $tipo_pago, $paquete, IFNULL($promocion, NULL), IFNULL($comentario, ''), $subtotal, $total);
        SET $ultimo = LAST_INSERT_ID();
        COMMIT;
        SELECT 'Ticket generado exitosamente.';
        SELECT * FROM ticket WHERE id_ticket = $ultimo;
    END IF;
END; //

CREATE PROCEDURE AgregarEstado(
    IN nombre VARCHAR(20)
)
BEGIN
    INSERT INTO estado (estado)
    VALUES (nombre);
    SELECT 'Esdtado agregado existosamente.';
END; //

CALL AgregarEstado('Ciudad de México');
CALL AgregarEstado('Jalisco');
CALL AgregarEstado('Puebla');
CALL AgregarEstado('Oaxaca');
CALL AgregarEstado('Quintana Roo');

CALL AgregarDireccion(1, 72000, 'Calle de los Ángeles', 101, 201);
CALL AgregarDireccion(2, 44100, 'Avenida Hidalgo', 102, NULL);
CALL AgregarDireccion(3, 68000, 'Boulevard Benito Juárez', 103, NULL);
CALL AgregarDireccion(4, 77500, 'Calle Quintana Roo', 104, 204);
CALL AgregarDireccion(5, 11560, 'Paseo de la Reforma', 105, NULL);

CALL AgregarSucursal('Sucursal Centro', 1, 1);
CALL AgregarSucursal('Sucursal Norte', 2, 2);
CALL AgregarSucursal('Sucursal Sur', 3, 3);
CALL AgregarSucursal('Sucursal Este', 4, 4);
CALL AgregarSucursal('Sucursal Oeste', 5, 5);

CALL AgregarHorario(TIME('08:00:00'), TIME('18:00:00'));
CALL AgregarHorario(TIME('09:00:00'), TIME('19:00:00'));

CALL AgregarPuesto('Gerente General', 2500.00);
CALL AgregarPuesto('Asistente de Gerencia', 1500.00);
CALL AgregarPuesto('Lavador de Autos', 800.00);
CALL AgregarPuesto('Contador Financiero', 2000.00);
CALL AgregarPuesto('Recepcionista de Servicio al Cliente', 1200.00);

CALL AgregarEmpleado('CURP001', 'Juan Pérez', 'Gerente General', 1, '555-123-4567', 'jperez@autowash.com');
CALL AgregarEmpleado('CURP002', 'María López', 'Asistente de Gerencia', 2, '555-234-5678', 'mlopez@autowash.com');
CALL AgregarEmpleado('CURP003', 'Carlos García', 'Lavador de Autos', 3, '555-345-6789', 'cgarcia@autowash.com');
CALL AgregarEmpleado('CURP004', 'Ana Martínez', 'Contador Financiero', 4, '555-456-7890', 'amartinez@autowash.com');
CALL AgregarEmpleado('CURP005', 'Luis Rodríguez', 'Recepcionista de Servicio al Cliente', 5, '555-567-8901', 'lrodriguez@autowash.com');

CALL AgregarPaquete('Lavado Básico', 'Incluye lavado exterior e interior básico.', 150.00);
CALL AgregarPaquete('Lavado Completo', 'Incluye lavado exterior e interior completo con cera.', 250.00);
CALL AgregarPaquete('Lavado Premium', 'Incluye lavado completo más pulido y encerado.', 350.00);
CALL AgregarPaquete('Lavado y Desinfección', 'Incluye lavado completo más desinfección interior.', 300.00);
CALL AgregarPaquete('Lavado Express', 'Lavado exterior rápido para clientes en movimiento.', 100.00);

CALL AgregarMembresia('Membresía Bronce', 'Descuento del 10% en todos los servicios.', 500.00);
CALL AgregarMembresia('Membresía Plata', 'Descuento del 15% en todos los servicios y un lavado gratis al mes.', 1000.00);
CALL AgregarMembresia('Membresía Oro', 'Descuento del 20% en todos los servicios y dos lavados gratis al mes.', 1500.00);

CALL AgregarPromocion('Promoción de Verano', '20% de descuento en lavado completo.', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH));
CALL AgregarPromocion('Promoción de Invierno', 'Lavado y desinfección con precio especial.', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH));

CALL AgregarCliente('CURP006','Laura Jiménez','laurajimenez@genial.com','555-678-9012');
CALL AgregarCliente('CURP007','Oscar Hernández','oscarhernandez@yahoo1.com','555-789-0123');

CALL AgregarCoche('MEX1234', 'CURP001', 'Toyota Corolla', 2021, 'Gris');
CALL AgregarCoche('MEX5678', 'CURP002', 'Honda Civic', 2020, 'Negro');
CALL AgregarCoche('MEX9101', 'CURP003', 'Ford Focus', 2019, 'Blanco');
CALL AgregarCoche('MEX1121', 'CURP004', 'Nissan Sentra', 2018, 'Azul');
CALL AgregarCoche('MEX3141', 'CURP005', 'Chevrolet Aveo', 2017, 'Rojo');

CALL GenerarTicket('CURP001', 1, 'MEX1234', 1, 1, 1, NULL, 'Me gustó', 150.00, 180.00);
CALL GenerarTicket('CURP002', 2, 'MEX5678', 2, 2, 2, NULL, 'Dejan bien sucio', 250.00, 300.00);
CALL GenerarTicket('CURP003', 3, 'MEX9101', 3, 3, NULL, NULL,'Comentario esperando revision' ,350.00 ,420.00 );
CALL GenerarTicket('CURP004' ,4 ,'MEX1121' ,4 ,4 ,NULL ,NULL ,'Los baños bien cerdos' ,300.00 ,360.00 );
CALL GenerarTicket('CURP005' ,5 ,'MEX3141' ,5 ,5 ,NULL ,NULL ,'Hola miss iliana' ,100.00 ,120.00 );