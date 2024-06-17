USE Autolavado;

DELIMITER //

# 2. Reporte diario de ventas y tipos de servicio
CREATE PROCEDURE ReporteDiarioVentas()
BEGIN
    SELECT 
        p.descripcion AS 'Tipo de servicio',
        COUNT(*) AS 'Numero de ventas',
        SUM(t.total) AS 'Total'
    FROM 
        ticket t
    INNER JOIN 
        paquete p ON t.paquete = p.id_paquete
    WHERE 
        DATE(t.fecha) = CURDATE()
    GROUP BY 
        p.descripcion;
END; //

# 9. Buscar cliente por nombre
CREATE PROCEDURE BuscarCliente(IN $nombre VARCHAR(50))
BEGIN
    SELECT 
        c.nombre, c.apellido_paterno, c.apellido_materno,
        m.membresia,
        p.descripcion AS 'Ultimos 10 dias de servicios'
    FROM 
        cliente c
    INNER JOIN 
        membresia m ON c.id_membresia = m.id_membresia
    INNER JOIN 
        ticket t ON c.curp = t.cliente
    INNER JOIN 
        paquete p ON t.paquete = p.id_paquete
    WHERE 
        c.nombre LIKE CONCAT('%', $nombre, '%')
    AND 
        t.fecha >= DATE_SUB(CURDATE(), INTERVAL 10 DAY);
END; //

# 11. Buscar empleado por número de empleado
CREATE PROCEDURE BuscarEmpleado(IN $numero_empleado INT)
BEGIN
    SELECT 
        e.nombre, e.apellido_paterno, e.apellido_materno,
        s.nombre AS 'Sucursal',
        SUM(t.total) AS 'Total de ventas',
        AVG(t.total) AS 'Promedio de ventas'
    FROM 
        empleado e
    INNER JOIN 
        sucursal s ON e.id_sucursal = s.id_sucursal
    INNER JOIN 
        ticket t ON e.numero_empleado = t.operador
    WHERE 
        e.numero_empleado = $numero_empleado
    AND 
        t.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
END; //

# 12. Operadores del mes
CREATE PROCEDURE OperadoresDelMes()
BEGIN
    SELECT 
        e.nombre, e.apellido_paterno, e.apellido_materno,
        s.nombre AS 'Sucursal',
        SUM(t.total) AS 'Total de ventas',
        CASE 
            WHEN SUM(t.total) > 1000 THEN SUM(t.total) * 0.05
            ELSE 0
        END AS 'Bono',
        CASE 
            WHEN SUM(t.total) > 1000 THEN 'Operador del mes'
            ELSE ''
        END AS 'Mensaje'
    FROM 
        empleado e
    INNER JOIN 
        sucursal s ON e.id_sucursal = s.id_sucursal
    INNER JOIN 
        ticket t ON e.numero_empleado = t.operador
    GROUP BY 
        e.numero_empleado;
END; //

# 13. Ventas por sucursal
CREATE PROCEDURE VentasPorSucursal(IN $sucursal INT, IN $fecha_inicio DATE, IN $fecha_fin DATE)
BEGIN
    SELECT 
        s.nombre AS 'Sucursal',
        SUM(t.total) AS 'Total de ventas'
    FROM 
        sucursal s
    INNER JOIN 
        ticket t ON s.id_sucursal = t.sucursal
    WHERE 
        s.id_sucursal = $sucursal
    AND 
        t.fecha >= $fecha_inicio
    AND 
        t.fecha <= $fecha_fin;
END; //

# 14. Ventas por operador
CREATE PROCEDURE VentasPorOperador(IN $operador VARCHAR(50), IN $fecha_inicio DATE, IN $fecha_fin DATE)
BEGIN
    SELECT 
        e.nombre, e.apellido_paterno, e.apellido_materno,
        SUM(t.total) AS 'Total de ventas'
    FROM 
        empleado e
    INNER JOIN 
        ticket t ON e.numero_empleado = t.operador
    WHERE 
        e.nombre LIKE CONCAT('%', $operador, '%')
    AND 
        t.fecha >= $fecha_inicio
    AND 
        t.fecha <= $fecha_fin;
END; //

# 15. Ventas por fecha
CREATE PROCEDURE VentasPorFecha(IN $fecha_inicio DATE, IN $fecha_fin DATE)
BEGIN
    SELECT 
        t.fecha,
        p.descripcion AS 'Tipo de servicio',
        SUM(t.total) AS 'Total de ventas'
    FROM 
        ticket t
    INNER JOIN 
        paquete p ON t.paquete = p.id_paquete
    WHERE 
        t.fecha >= $fecha_inicio
    AND 
        t.fecha <= $fecha_fin
    GROUP BY 
        t.fecha, p.descripcion;
END; //

# 16. Reporte de servicios proporcionados por empleado
CREATE PROCEDURE ReporteServiciosEmpleado(IN $empleado VARCHAR(50))
BEGIN
    SELECT 
        c.nombre, c.apellido_paterno, c.apellido_materno,
        p.descripcion AS 'Tipo de servicio',
        t.fecha
    FROM 
        cliente c
    INNER JOIN 
        ticket t ON c.curp = t.cliente
    INNER JOIN 
        paquete p ON t.paquete = p.id_paquete
    INNER JOIN 
        empleado e ON t.operador = e.numero_empleado
    WHERE 
        e.nombre LIKE CONCAT('%', $empleado, '%')
    ORDER BY 
        c.nombre, t.fecha;
END; //

CREATE PROCEDURE sp_AgregarEstado()
BEGIN
    INSERT INTO estado (estado) VALUES ('Aguascalientes');
    INSERT INTO estado (estado) VALUES ('Baja California');
    INSERT INTO estado (estado) VALUES ('Baja California Sur');
    INSERT INTO estado (estado) VALUES ('Campeche');
    INSERT INTO estado (estado) VALUES ('Chiapas');
END; //

CREATE PROCEDURE sp_ActualizarEstado(
    IN $id_estado INT,
    IN $estado VARCHAR(50)
)
BEGIN
    UPDATE estado
    SET estado = $estado
    WHERE id_estado = $id_estado;
END; //

CREATE PROCEDURE sp_EliminarEstado(
    IN $id_estado INT
)
BEGIN
    DELETE FROM estado
    WHERE id_estado = $id_estado;
END; //

CREATE PROCEDURE sp_AgregarDireccion()
BEGIN
    INSERT INTO Direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES (1, 20000, 'Avenida Independencia', 123, 1);
    INSERT INTO Direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES (2, 21000, 'Calle 20 de Noviembre', 456, 2);
    INSERT INTO Direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES (3, 23000, 'Avenida Constituyentes', 789, 3);
    INSERT INTO Direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES (4, 24000, 'Calle 16 de Septiembre', 901, 4);
    INSERT INTO Direccion (id_estado, codigo_postal, calle, numero_exterior, numero_interior)
    VALUES (5, 25000, 'Avenida Juárez', 111, 5);
END; //

CREATE PROCEDURE sp_ActualizarDireccion(
    IN $id_direccion INT,
    IN $id_estado INT,
    IN $codigo_postal INT,
    IN $calle VARCHAR(50),
    IN $numero_exterior INT,
    IN $numero_interior INT
)
BEGIN
    UPDATE direccion
    SET id_estado = $id_estado,
        codigo_postal = $codigoPostal,
        calle = $calle,
        numero_exterior = $numero_exterior,
        numero_interior = $numero_interior
    WHERE id_direccion = $id_direccion;
END; //

CREATE PROCEDURE sp_EliminarDireccion(
    IN $id_direccion INT
)
BEGIN
    DELETE FROM direccion
    WHERE id_direccion = $id_direccion;
END; //

CREATE PROCEDURE sp_AgregarTipoContacto()
BEGIN
    INSERT INTO tipo_contacto (Tipo) VALUES ('Teléfono');
    INSERT INTO tipo_contacto (Tipo) VALUES ('Correo Electrónico');
    INSERT INTO tipo_contacto (Tipo) VALUES ('Dirección');
    INSERT INTO tipo_contacto (Tipo) VALUES ('Redes Sociales');
    INSERT INTO tipo_contacto (Tipo) VALUES ('Otros');
END; //

CREATE PROCEDURE sp_ActualizarTipoContacto(
    IN $id_tipo_contacto INT,
    IN $tipo VARCHAR(50)
)
BEGIN
    UPDATE tipo_contacto
    SET tipo = $tipo
    WHERE id_tipo_contacto = $id_tipo_contacto;
END; //

CREATE PROCEDURE sp_EliminarTipoContacto(
    IN $id_tipo_contacto INT
)
BEGIN
    DELETE FROM tipo_contacto
    WHERE id_tipo_contacto = $id_tipo_contacto;
END; //

CREATE PROCEDURE sp_AgregarPuesto()
BEGIN
    INSERT INTO puesto (puesto, salario) VALUES ('Gerente', 5000.00);
    INSERT INTO puesto (puesto, salario) VALUES ('Supervisor', 300.00);
    INSERT INTO puesto (puesto, salario) VALUES ('Empleado', 200.00);
    INSERT INTO puesto (puesto, salario) VALUES ('Asistente', 1500.00);
    INSERT INTO puesto (puesto, salario) VALUES ('Practicante', 100.00);
END; //

CREATE PROCEDURE sp_ActualizarPuesto(
    IN $id_puesto INT,
    IN $puesto VARCHAR(50),
    IN $salario DECIMAL(10, 2)
)
BEGIN
    UPDATE puesto
    SET puesto = $puesto,
        salario = $salario
    WHERE id_puesto = $id_puesto;
END; //

CREATE PROCEDURE sp_EliminarPuesto(
    IN $id_puesto INT
)
BEGIN
    DELETE FROM puesto
    WHERE id_puesto = $id_puesto;
END; //

CREATE PROCEDURE sp_AgregarHorario()
BEGIN
    INSERT INTO horario (hora_entrada, hora_salida) VALUES ('08:00:00', '16:00:00');
    INSERT INTO horario (hora_entrada, hora_salida) VALUES ('09:00:00', '17:00:00');
    INSERT INTO horario (hora_entrada, hora_salida) VALUES ('10:00:00', '18:00:00');
    INSERT INTO horario (hora_entrada, hora_salida) VALUES ('11:00:00', '19:00:00');
    INSERT INTO horario (hora_entrada, hora_salida) VALUES ('12:00:00', '20:00:00');
END; //

CREATE PROCEDURE sp_ActualizarHorario(
    IN $id_horario INT,
    IN $hora_entrada TIME,
    IN $hora_salida TIME
)
BEGIN
    UPDATE horario
    SET hora_entrada = $hora_entrada,
        hora_salida = $hora_salida
    WHERE id_horario = $id_horario;
END; //

CREATE PROCEDURE sp_EliminarHorario(
    IN $id_horario INT
)
BEGIN
    DELETE FROM horario
    WHERE id_horario = $id_horario;
END; //

CREATE PROCEDURE sp_AgregarSucursal()
BEGIN
    INSERT INTO Sucursal (id_direccion, nombre) VALUES (1, 'Sucursal Centro');
    INSERT INTO Sucursal (id_direccion, nombre) VALUES (2, 'Sucursal Norte');
    INSERT INTO Sucursal (id_direccion, nombre) VALUES (3, 'Sucursal Sur');
    INSERT INTO Sucursal (id_direccion, nombre) VALUES (4, 'Sucursal Este');
    INSERT INTO Sucursal (id_direccion, nombre) VALUES (5, 'Sucursal Oeste');
END; //

CREATE PROCEDURE sp_ActualizarSucursal(
    IN $id_sucursal INT,
    IN $id_direccion INT,
    IN $nombre VARCHAR(50)
)
BEGIN
    UPDATE sucursal
    SET id_direccion = $id_direccion,
        nombre = $nombre
    WHERE id_sucursal = $id_sucursal;
END; //

CREATE PROCEDURE sp_EliminarSucursal(
    IN $id_sucursal INT
)
BEGIN
    DELETE FROM sucursal
    WHERE id_sucursal = $id_sucursal;
END; //

CREATE PROCEDURE sp_AgregarCronograma()
BEGIN
    INSERT INTO Cronograma (numero_empleado, id_horario) VALUES (1, 1);
    INSERT INTO Cronograma (numero_empleado, id_horario) VALUES (2, 2);
    INSERT INTO Cronograma (numero_empleado, id_horario) VALUES (3, 3);
    INSERT INTO Cronograma (numero_empleado, id_horario) VALUES (4, 4);
    INSERT INTO Cronograma (numero_empleado, id_horario) VALUES (5, 5);
END; //

CREATE PROCEDURE sp_ActualizarCronograma(
    IN $id_cronograma INT,
    IN $numero_empleado INT,
    IN $id_horario INT
)
BEGIN
    UPDATE cronograma
    SET numero_empleado = $numero_empleado,
        id_horario = $id_horario
    WHERE id_cronograma = $id_cronograma;
END; //

CREATE PROCEDURE sp_EliminarCronograma(
    IN $id_cronograma INT
)
BEGIN
    DELETE FROM cronograma
    WHERE id_cronograma = $id_cronograma;
END; //

CREATE PROCEDURE sp_AgregarMembresia()
BEGIN
    INSERT INTO membresia (membresia, condicion) VALUES ('Membresia Básica', 'Pago mensual');
    INSERT INTO membresia (membresia, condicion) VALUES ('Membresia Premium', 'Pago anual');
    INSERT INTO membresia (membresia, condicion) VALUES ('Membresia Elite', 'Pago trimestral');
    INSERT INTO membresia (membresia, condicion) VALUES ('Membresia Estándar', 'Pago semestral');
    INSERT INTO membresia (membresia, condicion) VALUES ('Membresia Gratis', 'Registro gratuito');
END; //

CREATE PROCEDURE sp_ActualizarMembresia(
    IN $id_membresia INT,
    IN $membresia VARCHAR(50),
    IN $condicion VARCHAR(50)
)
BEGIN
    UPDATE membresia
    SET membresia = $membresia,
        condicion = $condicion
    WHERE id_membresia = $id_membresia;
END; //

CREATE PROCEDURE sp_EliminarMembresia(
    IN $id_membresia INT
)
BEGIN
    DELETE FROM membresia
    WHERE id_membresia = $id_membresia;
END; //

CREATE PROCEDURE sp_AgregarPromocion()
BEGIN
    INSERT INTO promocion (descripcion, condicion) VALUES ('Descuento del 10%', 'compra mínima de $1000');
    INSERT INTO promocion (descripcion, condicion) VALUES ('Descuento del 20%', 'compra mínima de $2000');
    INSERT INTO promocion (descripcion, condicion) VALUES ('Descuento del 30%', 'compra mínima de $3000');
    INSERT INTO promocion (descripcion, condicion) VALUES ('Descuento del 40%', 'compra mínima de $4000');
    INSERT INTO promocion (descripcion, condicion) VALUES ('Descuento del 50%', 'compra mínima de $5000');
END; //

CREATE PROCEDURE sp_ActualizarPromocion(
    IN $id_promocion INT,
    IN $descripcion VARCHAR(50),
    IN $condicion VARCHAR(50)
)
BEGIN
    UPDATE promocion
    SET descripcion = $descripcion,
        condicion = $condicion
    WHERE id_promocion = $id_promocion;
END; //

CREATE PROCEDURE sp_EliminarPromocion(
    IN $id_promocion INT
)
BEGIN
    DELETE FROM promocion
    WHERE id_promocion = $id_promocion;
END; //

CREATE PROCEDURE sp_AgregarCliente()
BEGIN
    INSERT INTO Cliente (CURP, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
    VALUES ('RFC123456789', 1, 1, 'Juan', 'Pérez', 'González', '2022-01-01');
    INSERT INTO Cliente (CURP, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
    VALUES ('RFC987654321', 2, 2, 'María', 'López', 'Hernández', '2022-01-02');
    INSERT INTO Cliente (CURP, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
    VALUES ('RFC111111111', 3, 3, 'Carlos', 'García', 'Martínez', '2022-01-03');
    INSERT INTO Cliente (CURP, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
    VALUES ('RFC222222222', 4, 4, 'Ana', 'Rodríguez', 'Sánchez', '2022-01-04');
    INSERT INTO Cliente (CURP, id_membresia, id_direccion, nombre, apellido_paterno, apellido_materno, fecha_registro)
    VALUES ('RFC333333333', 5, 5, 'Pedro', 'Díaz', 'Fernández', '2022-01-05');
END; //

CREATE PROCEDURE sp_ActualizarCliente(
    IN $curp VARCHAR(18),
    IN $id_membresia INT,
    IN $id_direccion INT,
    IN $nombre VARCHAR(50),
    IN $apellido_paterno VARCHAR(50),
    IN $apellido_materno VARCHAR(50),
    IN $fecha_registro DATE
)
BEGIN
    UPDATE cliente
    SET id_membresia = $id_membresia,
        id_direccion = $id_direccion,
        nombre = $nombre,
        apellido_paterno = $apellido_paterno,
        apellido_materno = $apellido_materno,
        fecha_registro = $fecha_registro
    WHERE curp = $curp;
END; //

CREATE PROCEDURE sp_EliminarCliente(
    IN $curp VARCHAR(18)
)
BEGIN
    DELETE FROM cliente
    WHERE curp = $curp;
END; //

CREATE PROCEDURE sp_AgregarEmpleado()
BEGIN
    INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno)
    VALUES (1, 1, 'Juan', 'Pérez', 'González');
    INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno)
    VALUES (2, 2, 'María', 'López', 'Hernández');
    INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno)
    VALUES (3, 3, 'Carlos', 'García', 'Martínez');
    INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno)
    VALUES (4, 4, 'Ana', 'Rodríguez', 'Sánchez');
    INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno)
    VALUES (5, 5, 'Pedro', 'Díaz', 'Fernández');
END; //

CREATE PROCEDURE sp_ActualizarEmpleado(
    IN $numero_empleado INT,
    IN $id_sucursal INT,
    IN $id_puesto INT,
    IN $nombre VARCHAR(50),
    IN $apellido_paterno VARCHAR(50),
    IN $apellido_materno VARCHAR(50)
)
BEGIN
    UPDATE empleado
    SET id_sucursal = $id_sucursal,
        id_puesto = $id_puesto,
        nombre = $nombre,
        apellido_paterno = $apellido_paterno,
        apellido_materno = $apellido_materno
    WHERE numero_empleado = $numero_empleado;
END; //

CREATE PROCEDURE sp_EliminarEmpleado(
    IN $numero_empleado INT
)
BEGIN
    DELETE FROM empleado
    WHERE numero_empleado = $numero_empleado;
END; //

CREATE PROCEDURE sp_AgregarContacto()
BEGIN
    INSERT INTO contacto (curp, id_tipo_contacto, contacto) 
    VALUES ('RFC123456789', 1, '555-1234');
    INSERT INTO contacto (curp, id_tipo_contacto, contacto) 
    VALUES ('RFC123456789', 2, 'juan.angel@example.com');
    INSERT INTO contacto (curp, id_tipo_contacto, contacto) 
    VALUES ('RFC987654321', 1, '555-5678');
    INSERT INTO contacto (curp, id_tipo_contacto, contacto) 
    VALUES ('RFC987654321', 3, 'Calle 123, Col. Centro');
    INSERT INTO contacto (curp, id_tipo_contacto, contacto) 
    VALUES ('RFC111111111', 4, '@juanitoangelito');
END; //

CREATE PROCEDURE sp_ActualizarContacto(
    IN $id_contacto INT,
    IN $id_cliente INT,
    IN $id_tipo_contacto INT,
    IN $valor VARCHAR(50)
)
BEGIN
    UPDATE contacto
    SET id_cliente = $id_cliente,
        id_tipo_contacto = $id_tipo_contacto,
        valor = $valor
    WHERE id_contacto = $id_contacto;
END; //

CREATE PROCEDURE sp_EliminarContacto(
    IN $id_contacto INT
)
BEGIN
    DELETE FROM contacto
    WHERE id_contacto = $id_contacto;
END; //

CREATE PROCEDURE sp_AgregarTiposPago()
BEGIN
    INSERT INTO tipos_pago (tipo) VALUES ('Efectivo');
    INSERT INTO tipos_pago (tipo) VALUES ('Tarjeta de crédito');
    INSERT INTO tipos_pago (tipo) VALUES ('Tarjeta de débito');
    INSERT INTO tipos_pago (tipo) VALUES ('PayPal');
    INSERT INTO tipos_pago (tipo) VALUES ('Transferencia bancaria');
END; //

CREATE PROCEDURE sp_ActualizarTiposPago(
    IN $id_tipo_pago INT,
    IN $tipo_pago VARCHAR(50)
)
BEGIN
    UPDATE tipos_pago
    SET tipo_pago = $tipo_pago
    WHERE id_tipo_pago = $id_tipo_pago;
END; //

CREATE PROCEDURE sp_EliminarTiposPago(
    IN $id_tipo_pago INT
)
BEGIN
    DELETE FROM tipos_pago
    WHERE id_tipo_pago = $id_tipo_pago;
END; //

CREATE PROCEDURE sp_AgregarPaquete()
BEGIN
    INSERT INTO paquete (descripcion, precio) VALUES ('Paquete básico', 100.00);
    INSERT INTO paquete (descripcion, precio) VALUES ('Paquete premium', 200.00);
    INSERT INTO paquete (descripcion, precio) VALUES ('Paquete deluxe', 300.00);
    INSERT INTO paquete (descripcion, precio) VALUES ('Paquete económico', 50.00);
    INSERT INTO paquete (descripcion, precio) VALUES ('Paquete empresarial', 500.00);
END; //

CREATE PROCEDURE sp_ActualizarPaquete(
    IN $id_paquete INT,
    IN $descripcion VARCHAR(50),
    IN $precio DECIMAL(10, 2)
)
BEGIN
    UPDATE paquete
    SET descripcion = $descripcion,
        precio = $precio
    WHERE id_paquete = $id_paquete;
END; //

CREATE PROCEDURE sp_EliminarPaquete(
    IN $id_paquete INT
)
BEGIN
    DELETE FROM paquete
    WHERE id_paquete = $id_paquete;
END; //

CREATE PROCEDURE sp_AgregarCoche()
BEGIN
    INSERT INTO coche (placa, modelo) VALUES ('ABC123', 'Corolla');
    INSERT INTO coche (placa, modelo) VALUES ('DEF456', 'Civic');
    INSERT INTO coche (placa, modelo) VALUES ('GHI789', 'Focus');
    INSERT INTO coche (placa, modelo) VALUES ('JKL012', 'Sentra');
    INSERT INTO coche (placa, modelo) VALUES ('MNO345', 'Golf');
END; //

CREATE PROCEDURE sp_ActualizarCoche(
    IN $matricula VARCHAR(10),
    IN $marca VARCHAR(50),
    IN $modelo VARCHAR(50)
)
BEGIN
    UPDATE coche
    SET marca = $marca,
        modelo = $modelo
    WHERE matricula = $matricula;
END; //

CREATE PROCEDURE sp_EliminarCoche(
    IN $matricula VARCHAR(10)
)
BEGIN
    DELETE FROM coche
    WHERE matricula = $matricula;
END; //

CREATE PROCEDURE sp_AgregarTicket()
BEGIN
    INSERT INTO ticket (fecha, Total) VALUES ('2022-01-01', 100.00);
    INSERT INTO ticket (fecha, Total) VALUES ('2022-01-02', 200.00);
    INSERT INTO ticket (fecha, Total) VALUES ('2022-01-03', 300.00);
    INSERT INTO ticket (fecha, Total) VALUES ('2022-01-04', 400.00);
    INSERT INTO ticket (fecha, Total) VALUES ('2022-01-05', 500.00);
END; //

CREATE PROCEDURE sp_ActualizarTicket(
    IN $id_ticket INT,
    IN $fecha DATE,
    IN $hora TIME,
    IN $total DECIMAL(10, 2)
)
BEGIN
    UPDATE ticket
    SET fecha = $fecha,
        hora = $hora,
        total = $total
    WHERE id_ticket = $id_ticket;
END; //

CREATE PROCEDURE sp_EliminarTicket(
    IN $id_ticket INT
)
BEGIN
    DELETE FROM ticket
    WHERE id_ticket = $id_ticket;
END; //

CREATE PROCEDURE sp_AgregarCompra()
BEGIN
    INSERT INTO compra (fecha, Total) VALUES ('2022-01-01', 100.00);
    INSERT INTO compra (fecha, Total) VALUES ('2022-01-02', 200.00);
    INSERT INTO compra (fecha, Total) VALUES ('2022-01-03', 300.00);
    INSERT INTO compra (fecha, Total) VALUES ('2022-01-04', 400.00);
    INSERT INTO compra (fecha, Total) VALUES ('2022-01-05', 500.00);
END; //

CREATE PROCEDURE sp_ActualizarCompra(
    IN $id_compra INT,
    IN $fecha DATE,
    IN $total DECIMAL(10, 2)
)
BEGIN
    UPDATE compra
    SET fecha = $fecha,
        total = $total
    WHERE id_compra = $id_compra;
END; //

CREATE PROCEDURE sp_EliminarCompra(
    IN $id_compra INT
)
BEGIN
    DELETE FROM compra
    WHERE id_compra = $id_compra;
END; //

CREATE PROCEDURE sp_AgregarPromocionSucursal()
BEGIN
    INSERT INTO Promocion_sucursal (descripcion, condicion) VALUES ('Descuento del 10%', 'compra mínima de $1000');
    INSERT INTO Promocion_sucursal (descripcion, condicion) VALUES ('Descuento del 20%', 'compra mínima de $2000');
    INSERT INTO Promocion_sucursal (descripcion, condicion) VALUES ('Descuento del 30%', 'compra mínima de $3000');
    INSERT INTO Promocion_sucursal (descripcion, condicion) VALUES ('Descuento del 40%', 'compra mínima de $4000');
    INSERT INTO Promocion_sucursal (descripcion, condicion) VALUES ('Descuento del 50%', 'compra mínima de $5000');
END; //

CREATE PROCEDURE sp_ActualizarPromocionSucursal(
    IN $id_promocion_sucursal INT,
    IN $descripcion VARCHAR(50),
    IN $condicion VARCHAR(50)
)
BEGIN
    UPDATE promocion_sucursal
    SET descripcion = $descripcion,
        condicion = $condicion
    WHERE id_promocion_sucursal = $id_promocion_sucursal;
END; //

CREATE PROCEDURE sp_EliminarPromocionSucursal(
    IN $id_promocion_sucursal INT
)
BEGIN
    DELETE FROM promocion_sucursal
    WHERE id_promocion_sucursal = $id_promocion_sucursal;
END; //

DELIMITER ;
CALL sp_AgregarEstado();
CALL sp_AgregarDireccion();
CALL sp_AgregarTipoContacto();
CALL sp_AgregarPuesto();
CALL sp_AgregarHorario();
CALL sp_AgregarSucursal();
CALL sp_AgregarCronograma();
CALL sp_AgregarMembresia();
CALL sp_AgregarPromocion();
CALL sp_AgregarCliente();
CALL sp_AgregarEmpleado();
CALL sp_AgregarContacto();
CALL sp_AgregarTiposPago();
CALL sp_AgregarPaquete();
CALL sp_AgregarCoche();
CALL sp_AgregarTicket();
CALL sp_AgregarCompra();
CALL sp_AgregarPromocionSucursal();