USE Autolavado;

CREATE TABLE VentasPorDia (
    fecha DATE NOT NULL,
    id_paquete INT NOT NULL,
    total_ventas DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (fecha, id_paquete),
    FOREIGN KEY (id_paquete) REFERENCES paquete(id_paquete)
);

drop trigger if exists ContabilizarVentas;

delimiter //

CREATE TRIGGER ContabilizarVentas AFTER INSERT ON compra
FOR EACH ROW
BEGIN 

	DECLARE total_venta DECIMAL(10,3);
    
    SELECT SUM(ticket.subtotal) into total_venta
    from compra
    inner join ticket
    on ticket.id_ticket = compra.id_ticket
    where ticket.fecha = current_date() and compra.paquete = NEW.id_paquete;
    
    IF EXISTS (SELECT * FROM VentasPorDia WHERE fecha = current_date() AND id_paquete = NEW.id_paquete) then
		UPDATE VentasPorDia
        SET total_ventas = total_venta
        WHERE fecha = current_date() AND id_paquete = NEW.id_paquete;
	ELSE
        INSERT INTO VentasPorDia (fecha, id_paquete, total_ventas)
        VALUES (current_date(), NEW.id_paquete, total_venta);
    END IF;

END;//

delimiter ;