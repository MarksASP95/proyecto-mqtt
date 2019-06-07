CREATE OR REPLACE FUNCTION public.registrar_acceso(
	var_id_acc integer,
	var_io boolean,
	var_mac macaddr,
	var_sexo character,
	var_edad integer)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_acceso values(var_id_act, var_id_acc, var_io);
if(var_mac is not null) then
	insert into act_acc_mac values(var_id_act, var_mac);
end if;
if(var_sexo is not null or var_edad is not null) then
	insert into usuario_ai(id_act, sexo, edad) values(var_id_act, var_sexo, var_edad);
end if;
return (select id_act from actividad limit 1);
end;
$BODY$;

CREATE OR REPLACE FUNCTION public.registrar_mesa(
	var_id_mesa integer,
	var_io boolean,
	var_mac macaddr)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_mesa values(var_id_act, var_id_mesa, var_io);
if(var_mac is not null) then
	insert into act_mesa_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$BODY$;

CREATE OR REPLACE FUNCTION public.registrar_recorrido(
	var_id_nodo integer,
	var_mac macaddr)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_nodo values(var_id_act, var_id_nodo);
if(var_mac is not null) then
	insert into act_nodo_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$BODY$;

CREATE OR REPLACE FUNCTION public.registrar_tienda(
	var_id_tienda integer,
	var_io boolean,
	var_mac macaddr)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_tienda values(var_id_act, var_id_tienda, var_io);
if(var_mac is not null) then
	insert into act_tienda_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$BODY$;