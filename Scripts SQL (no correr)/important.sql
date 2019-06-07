/* Lista de actividades de entrada y salida de usuario con direccion MAC ordenado por timestamp*/
select act_acc_mac.mac, act_acceso.io, actividad.id_act, actividad.time_act 
from actividad
inner join act_acceso on actividad.id_act = act_acceso.id_act
inner join act_acc_mac on act_acceso.id_act = act_acc_mac.id_act
where mac = '8f:06:bd:48:3e:87'
order by actividad.time_act asc;

/* Persona con direccion MAC dentro de centro comercial? */
select act_acceso.io
from actividad
inner join act_acceso on actividad.id_act = act_acceso.id_act
inner join act_acc_mac on act_acceso.id_act = act_acc_mac.id_act
where mac = '8f:06:bd:48:3e:87'
order by actividad.time_act desc
limit 1;

/* Cedulas con sus direcciones MAC */
select cliente.ci_cli, transaccion_mac.mac from cliente
inner join transaccion on cliente.ci_cli = transaccion.ci_cli
inner join transaccion_mac on transaccion.id_trans = transaccion_mac.id_trans;

/* Direccion(es) MAC de una cedula */
select cliente.ci_cli, transaccion_mac.mac from cliente
inner join transaccion on cliente.ci_cli = transaccion.ci_cli
inner join transaccion_mac on transaccion.id_trans = transaccion_mac.id_trans
where cliente.ci_cli = 25038600;

/* TRIGGER PARA VALIDAR VENTA (MAC EN CC) */
create or replace function check_mac_en_cc()
returns trigger as $$
declare 
	var_ci_cli int4;
	var_mac macaddr;
	io boolean;
begin
var_mac = (select transaccion_mac.mac from cliente
		inner join transaccion on cliente.ci_cli = transaccion.ci_cli
		inner join transaccion_mac on transaccion.id_trans = transaccion_mac.id_trans
		where cliente.ci_cli = new.ci_cli limit 1);

if(var_mac is null) then
	return new;
end if;
		
io = (select act_acceso.io
	 from actividad
	 inner join act_acceso on actividad.id_act = act_acceso.id_act
	 inner join act_acc_mac on act_acceso.id_act = act_acc_mac.id_act
	 where mac = var_mac
	 order by actividad.time_act desc
	 limit 1);
if(io = true) then
	return new;
else
	raise exception 'Se ha tratado de comprar con una MAC que no está en el centro comercial';
end if;
end;
$$
language 'plpgsql';

create trigger before_venta
before insert on transaccion
for each row
execute procedure check_mac_en_cc();
/*----------------------------------------------------------------------------------------------------------*/

/* FUNCION DE COMPRA */
create or replace function compra(var_ci_cli int4, var_nom_cli char varying, var_id_tienda int4, var_monto float, var_mac macaddr)
returns text as $$
declare 
existe int4;
var_id_trans int4;
begin
existe = (select ci_cli from cliente where ci_cli = var_ci_cli);
if(existe is null) then
	insert into cliente values(var_ci_cli, var_nom_cli);
end if;

insert into transaccion(ci_cli, id_tienda, monto) values(var_ci_cli, var_id_tienda, var_monto) returning id_trans into var_id_trans;
if(var_mac is not null) then
	insert into transaccion_mac values(var_id_trans, var_mac);
end if;
return (select id_trans from transaccion limit 1);
end
$$
language 'plpgsql';
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE VENTAS TOTALES VS VENTAS CON MAC*/
create or replace view ventas_totales_vs_mac as
with 
total as 
	(select count(id_trans) as "Todas las ventas" 
	 from transaccion 
	 where time_trans >= date_trunc('month', CURRENT_DATE)), 
mac as 
	(select count(id_trans) as "Ventas MAC" from transaccion_mac natural join total)
select 
	"Todas las ventas", 
	"Ventas MAC", 
	"Todas las ventas" - "Ventas MAC" as "Ventas sin MAC", 
	("Ventas MAC" * 100)/"Todas las ventas" as "% Ventas MAC",
	(("Todas las ventas" - "Ventas MAC") * 100)/"Todas las ventas" as "% Ventas sin MAC"
	from total, mac;
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE TOP 5 DE MACS QUE MAS HAN ENTRADO EN EL MES ACTUAL (nombres y todo papa) */
create or replace view top_cinco_mac_entrada as
	with "mac_cliente" as (select distinct transaccion_mac.mac, ci_cli, nom_cli from transaccion_mac natural join transaccion natural join cliente)
	select count(io) as "Cantidad de entradas", 
		   act_acc_mac.mac as "Direccion MAC",
		   "mac_cliente".ci_cli as "CI",
		   "mac_cliente".nom_cli as "Nombre"
	from act_acceso
	inner join actividad
		on act_acceso.id_act = actividad.id_act
	inner join act_acc_mac 
		on actividad.id_act = act_acc_mac.id_act
	right outer join "mac_cliente"
		on "mac_cliente".mac = act_acc_mac.mac
	where time_act >= date_trunc('month', CURRENT_DATE) and act_acceso.io = true
	group by act_acc_mac.mac, "mac_cliente".ci_cli, "mac_cliente".nom_cli
	order by "Cantidad de entradas" desc
	limit 5;
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE VENTAS DE TIENDAS DEL MES EN ORDEN DESCENDENTE */
create or replace view ventas_mes_actual_por_tienda as
	select tienda.nom_tienda as "Tienda", sum(transaccion.monto) as "Venta mensual"
	from tienda
	inner join transaccion on tienda.id_tienda = transaccion.id_tienda
	where transaccion.time_trans >= date_trunc('month', CURRENT_DATE)
	group by "Tienda"
	order by "Venta mensual" desc;
/*----------------------------------------------------------------------------------------------------------*/

/* Combinar ventas de tiendas con sus visitas en un grafico (relacion visitas-ventas)*/

/* VISTA DE CANTIDAD DE VISITAS A TIENDAS EN EL MES ACTUAL EN ORDEN DESCENDENTE */
create or replace view cantidad_de_visitas_tienda_mes_actual as
	select tienda.nom_tienda as "Tienda", count(act_tienda.id_act) as "Cantidad de visitas"
	from tienda
	inner join act_tienda on tienda.id_tienda = act_tienda.id_tienda
	inner join actividad on act_tienda.id_act = actividad.id_act
	where actividad.time_act >= date_trunc('month', CURRENT_DATE) and act_tienda.io = true
	group by "Tienda"
	order by "Cantidad de visitas" desc;
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE PORCENTAJE DE PERSONAS QUE SE SIENTAN */
create or replace view entradas_vs_sentados as
with 
entradas as 
	(select count(act_acceso.id_act) as "Entradas" 
	 from act_acceso inner join actividad on act_acceso.id_act = actividad.id_act
	 where actividad.time_act >= date_trunc('month', CURRENT_DATE) and act_acceso.io = true), 
sentados as 
	(select count(act_mesa.id_act) as "Num. de sentados" from act_mesa natural join entradas)
select 
	"Entradas", 
	"Num. de sentados", 
	("Num. de sentados" * 100)/"Entradas" as "% de sentados"
	from entradas, sentados;
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE CANTIDAD DE HOMBRES VS CANTIDAD DE MUJERES (HISTORICO) */
create or replace view hombres_vs_mujeres as
	with "hombre" as (select count(sexo) as "Hombres" from usuario_ai where sexo = 'M'),
	"mujer" as (select count(sexo) as "Mujeres" from usuario_ai where sexo = 'F')
	select "Hombres", "Mujeres" from "hombre", "mujer";
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE CANTIDAD DE MUJERES POR EDAD */
create or replace view cantidad_mujeres_por_edad as
	select edad as "Edad", count(sexo) as "Cantidad"
	from usuario_ai 
	where sexo = 'F' 
	group by edad 
	order by edad asc;
/*----------------------------------------------------------------------------------------------------------*/

/* VISTA DE CANTIDAD DE HOMBRES POR EDAD */
create or replace view cantidad_mujeres_por_edad as
	select edad as "Edad", count(sexo) as "Cantidad"
	from usuario_ai 
	where sexo = 'M' 
	group by edad 
	order by edad asc;
/*----------------------------------------------------------------------------------------------------------*/