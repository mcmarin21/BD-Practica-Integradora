DROP DATABASE IF EXISTS Autolavado;
CREATE DATABASE Autolavado;
USE Autolavado;

CREATE TABLE estado (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(50) NOT NULL
);

CREATE TABLE direccion (
    id_direccion INT PRIMARY KEY AUTO_INCREMENT,
    id_estado INT NOT NULL,
    codigo_postal INT(5) NOT NULL,
    calle VARCHAR(250) NOT NULL,
    numero_exterior INT NOT NULL,
    numero_interior INT,
    FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
);

CREATE TABLE tipo_contacto (
    id_tipo_contacto INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(30)
);

CREATE TABLE puesto (
    id_puesto INT PRIMARY KEY AUTO_INCREMENT,
    puesto VARCHAR(50) NOT NULL,
    salario DECIMAL (6,2) NOT NULL
);

CREATE TABLE horario (
    id_horario INT PRIMARY KEY AUTO_INCREMENT,
    hora_entrada TIME NOT NULL,
    hora_salida TIME NOT NULL
);

CREATE TABLE sucursal (
    id_sucursal INT PRIMARY KEY AUTO_INCREMENT,
    id_direccion INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
);

CREATE TABLE empleado (
    numero_empleado INT PRIMARY KEY AUTO_INCREMENT,
    id_sucursal INT NOT NULL,
    id_puesto INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
    FOREIGN KEY (id_puesto) REFERENCES puesto(id_puesto)
);

CREATE TABLE cronograma (
    id_cronograma INT PRIMARY KEY AUTO_INCREMENT,
    numero_empleado INT NOT NULL,
    id_horario INT NOT NULL,
    FOREIGN KEY (numero_empleado) REFERENCES empleado(numero_empleado),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);

CREATE TABLE membresia (
	id_membresia INT PRIMARY KEY AUTO_INCREMENT,
	membresia VARCHAR(50) NOT NULL,
	condicion VARCHAR(250) NOT NULL
);

CREATE TABLE promocion (
	id_promocion INT PRIMARY KEY AUTO_INCREMENT,
	descripcion VARCHAR(50) NOT NULL,
	condicion VARCHAR(250) NOT NULL
);

CREATE TABLE cliente (
	curp CHAR(18) PRIMARY KEY,
	id_membresia INT NOT NULL,
	id_direccion INT NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	apellido_paterno VARCHAR(50) NOT NULL,
	apellido_materno VARCHAR(50) NOT NULL,
	fecha_registro DATE,
	FOREIGN KEY (id_membresia) REFERENCES membresia(id_membresia),
	FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
);

CREATE TABLE contacto (
    id_contacto INT PRIMARY KEY AUTO_INCREMENT,
    curp CHAR(18) NOT NULL,
    id_tipo_contacto INT NOT NULL,
    contacto VARCHAR(76),
    FOREIGN KEY (curp) REFERENCES cliente(curp),
    FOREIGN KEY (id_tipo_contacto) REFERENCES tipo_contacto(id_tipo_contacto)
);

CREATE TABLE tipos_pago (
	id_tipos_pago INT PRIMARY KEY AUTO_INCREMENT,
	tipo VARCHAR(25) NOT NULL
);

CREATE TABLE paquete (
	id_paquete INT PRIMARY KEY AUTO_INCREMENT,
	descripcion VARCHAR(250),
	precio DECIMAL(6,2)
);

CREATE TABLE coche (
	placa CHAR(8) PRIMARY KEY,
	curp CHAR(18),
	modelo VARCHAR(50),
	año INT,
	color VARCHAR(25),
	FOREIGN KEY (curp) REFERENCES cliente(curp)
);

CREATE TABLE ticket (
	id_ticket INT PRIMARY KEY AUTO_INCREMENT,
	cliente CHAR(18) NOT NULL,
	operador INT NOT NULL,
	coche CHAR(8) NOT NULL,
	sucursal INT NOT NULL,
	tipo_pago INT NOT NULL,
	promocion INT,
	comentario VARCHAR(250),
    fecha date,
	subtotal DECIMAL(8,2),
	total DECIMAL(8,2),
	FOREIGN KEY (cliente) REFERENCES cliente(curp),
	FOREIGN KEY (operador) REFERENCES empleado(numero_empleado),
    FOREIGN KEY (coche) REFERENCES coche(placa),
	FOREIGN KEY (sucursal) REFERENCES sucursal(id_sucursal),
	FOREIGN KEY (tipo_pago) REFERENCES tipos_pago(id_tipos_pago),
	FOREIGN KEY (promocion) REFERENCES promocion(id_promocion)
);

CREATE TABLE compra (
	id_compra INT PRIMARY KEY AUTO_INCREMENT,
	id_ticket INT NOT NULL,
	id_paquete INT NOT NULL,
	cantidad INT,
	precio DECIMAL(6,2),
	FOREIGN KEY (id_ticket) REFERENCES ticket(id_ticket),
	FOREIGN KEY (id_paquete) REFERENCES paquete(id_paquete)
);

CREATE TABLE promocion_sucursal (
	id_promocion_sucursal INT PRIMARY KEY AUTO_INCREMENT,
    id_promocion INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    FOREIGN KEY (id_promocion) REFERENCES promocion(id_promocion),
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);