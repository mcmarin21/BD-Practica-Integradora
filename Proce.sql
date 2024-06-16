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