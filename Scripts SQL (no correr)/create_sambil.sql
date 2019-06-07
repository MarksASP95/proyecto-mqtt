## POSTGRESQL

create table if not exists actividad
(id_act serial, 
 time_act timestamp with time zone not null, 
 primary key(id_act));
 
 create table if not exists acceso
 (id_acc serial,
  nom_acc char varying(40) not null,
  primary key(id_acc));
  
 create table if not exists tienda
 (id_tienda serial,
 nom_tienda char varying(40),
 primary key(id_tienda));
 
 create table if not exists act_acceso
 (id_act int4, id_acc int4 not null, io boolean not null,
 foreign key (id_act) references actividad(id_act),
 foreign key (id_acc) references acceso(id_acc),
 primary key(id_act));
 
 create table if not exists act_acc_mac
 (id_act int4,
 mac macaddr not null,
 foreign key (id_act) references act_acceso(id_act),
 primary key(id_act));
 
 create table if not exists act_tienda
 (id_act int4, 
  id_tienda int4 not null, 
  io boolean not null,
  foreign key(id_act) references actividad(id_act),
  foreign key(id_tienda) references tienda(id_tienda),
  primary key(id_act));
  
 create table if not exists act_tienda_mac
 (id_act int4,
 mac macaddr not null,
 foreign key (id_act) references act_tienda(id_act),
 primary key(id_act));
 
create table if not exists nodo
(id_nodo serial,
desc_nodo char varying(20),
primary key(id_nodo));

create table if not exists act_nodo
(id_act int4,
id_nodo int4,
foreign key (id_act) references actividad(id_act),
foreign key (id_nodo) references nodo(id_nodo),
primary key(id_act));

create table if not exists act_nodo_mac
(id_act int4,
mac macaddr not null,
foreign key(id_act) references act_nodo(id_act),
primary key(id_act));

create table if not exists usuario_ai
(id_usuario_ai serial,
id_act int4 not null,
sexo char not null,
edad smallint not null,
foreign key(id_act) references act_acceso(id_act),
primary key(id_usuario_ai));

create table if not exists cliente
(ci_cli int4,
nom_cli char varying(30),
primary key(ci_cli));

create table if not exists transaccion
(id_trans serial,
 ci_cli int4 not null,
 id_tienda int4 not null,
 monto float not null,
 foreign key(ci_cli) references cliente(ci_cli),
 foreign key(id_tienda) references tienda(id_tienda),
 primary key(id_trans));
 
 create table if not exists transaccion_mac
 (id_trans int4,
 mac macaddr not null,
 foreign key (id_trans) references transaccion(id_trans),
 primary key(id_trans));
 
 create table if not exists mesa
 (id_mesa serial,
 primary key (id_mesa));
 
 create table if not exists act_mesa
 (id_act int4,
 id_mesa int4 not null,
 io boolean not null,
 foreign key (id_act) references actividad(id_act),
 foreign key (id_mesa) references mesa(id_mesa),
 primary key(id_act));
 
 create table if not exists act_mesa_mac
 (id_act int4,
 mac macaddr not null,
 foreign key (id_act) references act_mesa(id_act),
 primary key(id_act));
 