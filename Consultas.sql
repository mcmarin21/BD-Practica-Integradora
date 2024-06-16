CREATE VIEW ClientesPorSucursal AS
SELECT 
    cliente.nombre, 
    cliente.apellido_paterno, 
    cliente.apellido_materno, 
    sucursal.nombre AS sucursal, 
    TIMESTAMPDIFF(YEAR, cliente.fecha_registro, CURDATE()) AS antiguedad,
    membresia.membresia AS tipo_cliente
FROM cliente
JOIN sucursal ON cliente.id_direccion = sucursal.id_direccion
JOIN membresia ON cliente.id_membresia = membresia.id_membresia;

CREATE VIEW OperacionesSemanales AS
SELECT 
    DAYNAME(ticket.fecha) AS dia,
    ticket.sucursal,
    tipos_pago.tipo AS 'Tipo operacion',
    COUNT(*) AS Operaciones
FROM ticket
JOIN tipos_pago ON ticket.tipo_pago = tipos_pago.id_tipos_pago
WHERE ticket.fecha BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
GROUP BY dia, ticket.sucursal, tipos_pago.tipo;

CREATE VIEW ReportePromedioVentas AS
SELECT 
    sucursal.nombre AS sucursal,
    YEAR(ticket.fecha) AS año,
    MONTH(ticket.fecha) AS mes,
    AVG(ticket.total) AS promedio
FROM ticket
JOIN sucursal ON ticket.sucursal = sucursal.id_sucursal
WHERE ticket.fecha >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY sucursal, año, mes
ORDER BY promedio DESC;

CREATE VIEW ReportePromocionesDiarias AS
SELECT 
    ticket.fecha,
    cliente.nombre AS cliente,
    empleado.nombre AS operador,
    sucursal.nombre AS sucursal,
    paquete.descripcion AS 'tipo servicio'
FROM ticket
JOIN cliente ON ticket.cliente = cliente.curp
JOIN empleado ON ticket.operador = empleado.numero_empleado
JOIN sucursal ON ticket.sucursal = sucursal.id_sucursal
JOIN paquete ON ticket.paquete = paquete.id_paquete;