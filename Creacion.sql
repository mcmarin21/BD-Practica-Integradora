drop database if exists Autolavado;
create database Autolavado;
create table estado (
	id_estado int primary key auto_increment,
    estado varchar(20)
);
create table direccion (
	id_direccion int primary key auto_increment,
    id_estado int not null,
    codigo_postal int not null,
    calle varchar(250) not null,
    numero_exterior int not null,
    numero_interior int
);
create table sucursal (
	id_sucursal int primary key auto_increment,
    id_direccion int not null,
    nombre varchar(255) not null
);
create table empleado (
	numero_empleado int primary key auto_increment,
    id_sucursal int not null,
    id_puesto int not null,
    nombre varchar(50) not null,
    apellido_paterno varchar(50) not null,
    apellido_materno varchar(50) not null
);
create table cronograma (
	id_cronograma int primary key auto_increment,
    numero_empleado int not null,
    id_horario int not null
);
create table puesto (
	id_puesto int primary key auto_increment,
    puesto varchar(50) not null,
    salario decimal (6,2) not null
);
create table horario (
	id_horario int primary key auto_increment,
    hora_entrada time,
    hora_salida time
);
create table contacto (
	id_contacto int primary key auto_increment,
    id_tipo_contacto int not null,
    contacto varchar(76)
);
create table tipo_contacto (
	id_tipo_contacto int primary key auto_increment,
    tipo varchar(30)
);
create table membresia (
	id_membresia int primary key auto_increment,
    membresia varchar(50),
    condicion varchar(250)
);
create table promocion (
	id_promocion int primary key auto_increment,
    descripcion varchar(50),
    condicion varchar(250)
);
create table cliente (
	curp char(16) primary key,
    id_membresia int not null,
    id_direccion int not null,
    nombre varchar(50) not null,
    apellido_paterno varchar(50) not null,
    apellido_materno varchar(50) not null,
    fecha_registro date
);
create table tipos_pago (
	id_tipos_pago int primary key auto_increment,
    tipo varchar(25)
);
create table paquete (
	id_paquete int primary key auto_increment,
    id_promocion int,
    promocion varchar(50),
    descripcion varchar(250),
    precio decimal(6,2)
);
create table coche (
	placa char(8),
    curp char(18),
    modelo varchar(50),
    año int,
    color varchar(25)
);
create table ticket (
	id_ticket int primary key auto_increment,
    cliente char(18) not null,
    operador char(18) not null,
    coche char(8) not null,
    sucursal int not null,
    tipo_pago int not null,
    paquete int not null,
    promocion int not null,
    comentario varchar(250),
    subtotal decimal(8,2),
    total decimal(8,2)
);
create table compra (
	id_compra int primary key auto_increment,
    id_ticket int not null,
    id_paquete int not null
);
create table promocion_sucursal (
	id_promocion_sucursal int primary key auto_increment,
    id_sucursal int not null,
    id_promocion int not null
);