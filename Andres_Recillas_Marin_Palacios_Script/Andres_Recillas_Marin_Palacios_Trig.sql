USE Autolavado;

CREATE TABLE VentasPorDia (
    fecha DATE NOT NULL,
    id_paquete INT NOT NULL,
    total_ventas DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (fecha, id_paquete),
    FOREIGN KEY (id_paquete) REFERENCES paquete(id_paquete)
);

DELIMITER //
CREATE TRIGGER ContabilizarVentas AFTER INSERT ON ticket
FOR EACH ROW
BEGIN
    DECLARE total_venta DECIMAL(10,2);
    SELECT SUM(subtotal) INTO total_venta
    FROM ticket
    WHERE fecha = NEW.fecha AND paquete = NEW.paquete;
    IF EXISTS (SELECT * FROM VentasPorDia WHERE fecha = NEW.fecha AND id_paquete = NEW.paquete) THEN
        UPDATE VentasPorDia
        SET total_ventas = total_venta
        WHERE fecha = NEW.fecha AND id_paquete = NEW.paquete;
    ELSE
        INSERT INTO VentasPorDia (fecha, id_paquete, total_ventas)
        VALUES (NEW.fecha, NEW.paquete, total_venta);
    END IF;
END//