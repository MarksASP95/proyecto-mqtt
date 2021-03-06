PGDMP         :                w            sambil    11.2    11.2 t    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    49231    sambil    DATABASE     �   CREATE DATABASE sambil WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE sambil;
             postgres    false            �           1247    49388 	   sexo_enum    TYPE     ;   CREATE TYPE public.sexo_enum AS ENUM (
    'M',
    'F'
);
    DROP TYPE public.sexo_enum;
       public       postgres    false            �            1255    49583    check_mac_en_cc()    FUNCTION     B  CREATE FUNCTION public.check_mac_en_cc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 (   DROP FUNCTION public.check_mac_en_cc();
       public       postgres    false            �            1255    49587 F   compra(integer, character varying, integer, double precision, macaddr)    FUNCTION     �  CREATE FUNCTION public.compra(var_ci_cli integer, var_nom_cli character varying, var_id_tienda integer, var_monto double precision, var_mac macaddr) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;
 �   DROP FUNCTION public.compra(var_ci_cli integer, var_nom_cli character varying, var_id_tienda integer, var_monto double precision, var_mac macaddr);
       public       postgres    false            �            1255    49533 ?   registrar_acceso(integer, boolean, macaddr, character, integer)    FUNCTION     �  CREATE FUNCTION public.registrar_acceso(var_id_acc integer, var_io boolean, var_mac macaddr, var_sexo character, var_edad integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;
 �   DROP FUNCTION public.registrar_acceso(var_id_acc integer, var_io boolean, var_mac macaddr, var_sexo character, var_edad integer);
       public       postgres    false            �            1255    49516 )   registrar_mesa(integer, boolean, macaddr)    FUNCTION     �  CREATE FUNCTION public.registrar_mesa(var_id_mesa integer, var_io boolean, var_mac macaddr) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_mesa values(var_id_act, var_id_mesa, var_io);
if(var_mac is not null) then
	insert into act_mesa_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$$;
 [   DROP FUNCTION public.registrar_mesa(var_id_mesa integer, var_io boolean, var_mac macaddr);
       public       postgres    false            �            1255    49514 %   registrar_recorrido(integer, macaddr)    FUNCTION     �  CREATE FUNCTION public.registrar_recorrido(var_id_nodo integer, var_mac macaddr) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_nodo values(var_id_act, var_id_nodo);
if(var_mac is not null) then
	insert into act_nodo_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$$;
 P   DROP FUNCTION public.registrar_recorrido(var_id_nodo integer, var_mac macaddr);
       public       postgres    false            �            1255    49515 +   registrar_tienda(integer, boolean, macaddr)    FUNCTION     �  CREATE FUNCTION public.registrar_tienda(var_id_tienda integer, var_io boolean, var_mac macaddr) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare var_id_act int4;
begin
insert into actividad(time_act) values (now()) returning id_act into var_id_act;
insert into act_tienda values(var_id_act, var_id_tienda, var_io);
if(var_mac is not null) then
	insert into act_tienda_mac values(var_id_act, var_mac);
end if;
return (select id_act from actividad limit 1);
end;
$$;
 _   DROP FUNCTION public.registrar_tienda(var_id_tienda integer, var_io boolean, var_mac macaddr);
       public       postgres    false            �            1259    49242    acceso    TABLE     _   CREATE TABLE public.acceso (
    id_acc integer NOT NULL,
    nom_acc character varying(40)
);
    DROP TABLE public.acceso;
       public         postgres    false            �            1259    49240    acceso_id_acc_seq    SEQUENCE     �   CREATE SEQUENCE public.acceso_id_acc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.acceso_id_acc_seq;
       public       postgres    false    199            �           0    0    acceso_id_acc_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.acceso_id_acc_seq OWNED BY public.acceso.id_acc;
            public       postgres    false    198            �            1259    49294    act_acc_mac    TABLE     [   CREATE TABLE public.act_acc_mac (
    id_act integer NOT NULL,
    mac macaddr NOT NULL
);
    DROP TABLE public.act_acc_mac;
       public         postgres    false            �            1259    49274 
   act_acceso    TABLE     v   CREATE TABLE public.act_acceso (
    id_act integer NOT NULL,
    id_acc integer NOT NULL,
    io boolean NOT NULL
);
    DROP TABLE public.act_acceso;
       public         postgres    false            �            1259    49447    act_mesa    TABLE     u   CREATE TABLE public.act_mesa (
    id_act integer NOT NULL,
    id_mesa integer NOT NULL,
    io boolean NOT NULL
);
    DROP TABLE public.act_mesa;
       public         postgres    false            �            1259    49462    act_mesa_mac    TABLE     \   CREATE TABLE public.act_mesa_mac (
    id_act integer NOT NULL,
    mac macaddr NOT NULL
);
     DROP TABLE public.act_mesa_mac;
       public         postgres    false            �            1259    49337    act_nodo    TABLE     S   CREATE TABLE public.act_nodo (
    id_act integer NOT NULL,
    id_nodo integer
);
    DROP TABLE public.act_nodo;
       public         postgres    false            �            1259    49352    act_nodo_mac    TABLE     \   CREATE TABLE public.act_nodo_mac (
    id_act integer NOT NULL,
    mac macaddr NOT NULL
);
     DROP TABLE public.act_nodo_mac;
       public         postgres    false            �            1259    49304 
   act_tienda    TABLE     y   CREATE TABLE public.act_tienda (
    id_act integer NOT NULL,
    id_tienda integer NOT NULL,
    io boolean NOT NULL
);
    DROP TABLE public.act_tienda;
       public         postgres    false            �            1259    49319    act_tienda_mac    TABLE     ^   CREATE TABLE public.act_tienda_mac (
    id_act integer NOT NULL,
    mac macaddr NOT NULL
);
 "   DROP TABLE public.act_tienda_mac;
       public         postgres    false            �            1259    49234 	   actividad    TABLE     o   CREATE TABLE public.actividad (
    id_act integer NOT NULL,
    time_act timestamp with time zone NOT NULL
);
    DROP TABLE public.actividad;
       public         postgres    false            �            1259    49232    actividad_id_act_seq    SEQUENCE     �   CREATE SEQUENCE public.actividad_id_act_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.actividad_id_act_seq;
       public       postgres    false    197            �           0    0    actividad_id_act_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.actividad_id_act_seq OWNED BY public.actividad.id_act;
            public       postgres    false    196            �            1259    49250    tienda    TABLE     e   CREATE TABLE public.tienda (
    id_tienda integer NOT NULL,
    nom_tienda character varying(40)
);
    DROP TABLE public.tienda;
       public         postgres    false            �            1259    49780 %   cantidad_de_visitas_tienda_mes_actual    VIEW       CREATE VIEW public.cantidad_de_visitas_tienda_mes_actual AS
 SELECT tienda.nom_tienda AS "Tienda",
    count(act_tienda.id_act) AS "Cantidad de visitas"
   FROM ((public.tienda
     JOIN public.act_tienda ON ((tienda.id_tienda = act_tienda.id_tienda)))
     JOIN public.actividad ON ((act_tienda.id_act = actividad.id_act)))
  WHERE ((actividad.time_act >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone)) AND (act_tienda.io = true))
  GROUP BY tienda.nom_tienda
  ORDER BY (count(act_tienda.id_act)) DESC;
 8   DROP VIEW public.cantidad_de_visitas_tienda_mes_actual;
       public       postgres    false    201    197    201    197    204    204    204            �            1259    49522 
   usuario_ai    TABLE     �   CREATE TABLE public.usuario_ai (
    id_usuario_ai integer NOT NULL,
    id_act integer NOT NULL,
    sexo character(1) NOT NULL,
    edad smallint NOT NULL
);
    DROP TABLE public.usuario_ai;
       public         postgres    false            �            1259    57733    cantidad_hombres_por_edad    VIEW     �   CREATE VIEW public.cantidad_hombres_por_edad AS
 SELECT usuario_ai.edad AS "Edad",
    count(usuario_ai.sexo) AS "Cantidad"
   FROM public.usuario_ai
  WHERE (usuario_ai.sexo = 'M'::bpchar)
  GROUP BY usuario_ai.edad
  ORDER BY usuario_ai.edad;
 ,   DROP VIEW public.cantidad_hombres_por_edad;
       public       postgres    false    215    215            �            1259    57729    cantidad_mujeres_por_edad    VIEW     �   CREATE VIEW public.cantidad_mujeres_por_edad AS
 SELECT usuario_ai.edad AS "Edad",
    count(usuario_ai.sexo) AS "Cantidad"
   FROM public.usuario_ai
  WHERE (usuario_ai.sexo = 'F'::bpchar)
  GROUP BY usuario_ai.edad
  ORDER BY usuario_ai.edad;
 ,   DROP VIEW public.cantidad_mujeres_por_edad;
       public       postgres    false    215    215            �            1259    49636    cliente    TABLE     `   CREATE TABLE public.cliente (
    ci_cli integer NOT NULL,
    nom_cli character varying(30)
);
    DROP TABLE public.cliente;
       public         postgres    false            �            1259    57712    entradas_vs_sentados    VIEW     �  CREATE VIEW public.entradas_vs_sentados AS
 WITH entradas AS (
         SELECT count(act_acceso.id_act) AS "Entradas"
           FROM (public.act_acceso
             JOIN public.actividad ON ((act_acceso.id_act = actividad.id_act)))
          WHERE ((actividad.time_act >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone)) AND (act_acceso.io = true))
        ), sentados AS (
         SELECT count(act_mesa.id_act) AS "Num. de sentados"
           FROM (public.act_mesa
             CROSS JOIN entradas entradas_1)
        )
 SELECT entradas."Entradas",
    sentados."Num. de sentados",
    ((sentados."Num. de sentados" * 100) / entradas."Entradas") AS "% de sentados"
   FROM entradas,
    sentados;
 '   DROP VIEW public.entradas_vs_sentados;
       public       postgres    false    197    197    202    202    212            �            1259    57717    hombres_vs_mujeres    VIEW     �  CREATE VIEW public.hombres_vs_mujeres AS
 WITH hombre AS (
         SELECT count(usuario_ai.sexo) AS "Hombres"
           FROM public.usuario_ai
          WHERE (usuario_ai.sexo = 'M'::bpchar)
        ), mujer AS (
         SELECT count(usuario_ai.sexo) AS "Mujeres"
           FROM public.usuario_ai
          WHERE (usuario_ai.sexo = 'F'::bpchar)
        )
 SELECT hombre."Hombres",
    mujer."Mujeres"
   FROM hombre,
    mujer;
 %   DROP VIEW public.hombres_vs_mujeres;
       public       postgres    false    215            �            1259    49431    mesa    TABLE     ;   CREATE TABLE public.mesa (
    id_mesa integer NOT NULL
);
    DROP TABLE public.mesa;
       public         postgres    false            �            1259    49429    mesa_id_mesa_seq    SEQUENCE     �   CREATE SEQUENCE public.mesa_id_mesa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.mesa_id_mesa_seq;
       public       postgres    false    211            �           0    0    mesa_id_mesa_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.mesa_id_mesa_seq OWNED BY public.mesa.id_mesa;
            public       postgres    false    210            �            1259    49331    nodo    TABLE     `   CREATE TABLE public.nodo (
    id_nodo integer NOT NULL,
    desc_nodo character varying(20)
);
    DROP TABLE public.nodo;
       public         postgres    false            �            1259    49329    nodo_id_nodo_seq    SEQUENCE     �   CREATE SEQUENCE public.nodo_id_nodo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.nodo_id_nodo_seq;
       public       postgres    false    207            �           0    0    nodo_id_nodo_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.nodo_id_nodo_seq OWNED BY public.nodo.id_nodo;
            public       postgres    false    206            �            1259    49248    tienda_id_tienda_seq    SEQUENCE     �   CREATE SEQUENCE public.tienda_id_tienda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.tienda_id_tienda_seq;
       public       postgres    false    201            �           0    0    tienda_id_tienda_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.tienda_id_tienda_seq OWNED BY public.tienda.id_tienda;
            public       postgres    false    200            �            1259    49759    top5_macs_entrada    VIEW     �  CREATE VIEW public.top5_macs_entrada AS
 SELECT count(act_acceso.io) AS cantidad,
    act_acc_mac.mac
   FROM ((public.act_acceso
     JOIN public.actividad ON ((act_acceso.id_act = actividad.id_act)))
     JOIN public.act_acc_mac ON ((actividad.id_act = act_acc_mac.id_act)))
  WHERE (actividad.time_act >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))
  GROUP BY act_acc_mac.mac
  ORDER BY (count(act_acceso.io)) DESC
 LIMIT 5;
 $   DROP VIEW public.top5_macs_entrada;
       public       postgres    false    203    197    197    202    202    203            �            1259    49643    transaccion    TABLE     �   CREATE TABLE public.transaccion (
    id_trans integer NOT NULL,
    ci_cli integer NOT NULL,
    id_tienda integer NOT NULL,
    monto double precision NOT NULL,
    time_trans timestamp with time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.transaccion;
       public         postgres    false            �            1259    49659    transaccion_mac    TABLE     a   CREATE TABLE public.transaccion_mac (
    id_trans integer NOT NULL,
    mac macaddr NOT NULL
);
 #   DROP TABLE public.transaccion_mac;
       public         postgres    false            �            1259    49785    top_cinco_mac_entrada    VIEW     �  CREATE VIEW public.top_cinco_mac_entrada AS
 WITH mac_cliente AS (
         SELECT DISTINCT transaccion_mac.mac,
            transaccion.ci_cli,
            cliente.nom_cli
           FROM ((public.transaccion_mac
             JOIN public.transaccion USING (id_trans))
             JOIN public.cliente USING (ci_cli))
        )
 SELECT count(act_acceso.io) AS "Cantidad de entradas",
    act_acc_mac.mac AS "Direccion MAC",
    mac_cliente.ci_cli AS "CI",
    mac_cliente.nom_cli AS "Nombre"
   FROM (((public.act_acceso
     JOIN public.actividad ON ((act_acceso.id_act = actividad.id_act)))
     JOIN public.act_acc_mac ON ((actividad.id_act = act_acc_mac.id_act)))
     RIGHT JOIN mac_cliente ON ((mac_cliente.mac = act_acc_mac.mac)))
  WHERE ((actividad.time_act >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone)) AND (act_acceso.io = true))
  GROUP BY act_acc_mac.mac, mac_cliente.ci_cli, mac_cliente.nom_cli
  ORDER BY (count(act_acceso.io)) DESC
 LIMIT 5;
 (   DROP VIEW public.top_cinco_mac_entrada;
       public       postgres    false    197    219    219    218    218    216    216    203    203    202    202    197            �            1259    49763    top_cinco_macs_entrada    VIEW     �  CREATE VIEW public.top_cinco_macs_entrada AS
 WITH mac_cliente AS (
         SELECT DISTINCT transaccion_mac.mac,
            transaccion.ci_cli,
            cliente.nom_cli
           FROM ((public.transaccion_mac
             JOIN public.transaccion USING (id_trans))
             JOIN public.cliente USING (ci_cli))
        )
 SELECT count(act_acceso.io) AS "Cantidad de entradas",
    act_acc_mac.mac AS "Direccion MAC",
    mac_cliente.ci_cli AS "CI",
    mac_cliente.nom_cli AS "Nombre"
   FROM (((public.act_acceso
     JOIN public.actividad ON ((act_acceso.id_act = actividad.id_act)))
     JOIN public.act_acc_mac ON ((actividad.id_act = act_acc_mac.id_act)))
     RIGHT JOIN mac_cliente ON ((mac_cliente.mac = act_acc_mac.mac)))
  WHERE (actividad.time_act >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))
  GROUP BY act_acc_mac.mac, mac_cliente.ci_cli, mac_cliente.nom_cli
  ORDER BY (count(act_acceso.io)) DESC
 LIMIT 5;
 )   DROP VIEW public.top_cinco_macs_entrada;
       public       postgres    false    203    216    216    218    218    219    219    197    197    202    202    203            �            1259    49641    transaccion_id_trans_seq    SEQUENCE     �   CREATE SEQUENCE public.transaccion_id_trans_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.transaccion_id_trans_seq;
       public       postgres    false    218            �           0    0    transaccion_id_trans_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.transaccion_id_trans_seq OWNED BY public.transaccion.id_trans;
            public       postgres    false    217            �            1259    49520    usuario_ai_id_usuario_ai_seq    SEQUENCE     �   CREATE SEQUENCE public.usuario_ai_id_usuario_ai_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.usuario_ai_id_usuario_ai_seq;
       public       postgres    false    215            �           0    0    usuario_ai_id_usuario_ai_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.usuario_ai_id_usuario_ai_seq OWNED BY public.usuario_ai.id_usuario_ai;
            public       postgres    false    214            �            1259    49772    ventas_mes_actual_por_tienda    VIEW     �  CREATE VIEW public.ventas_mes_actual_por_tienda AS
 SELECT tienda.nom_tienda AS "Tienda",
    sum(transaccion.monto) AS "Venta mensual"
   FROM (public.tienda
     JOIN public.transaccion ON ((tienda.id_tienda = transaccion.id_tienda)))
  WHERE (transaccion.time_trans >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))
  GROUP BY tienda.nom_tienda
  ORDER BY (sum(transaccion.monto)) DESC;
 /   DROP VIEW public.ventas_mes_actual_por_tienda;
       public       postgres    false    201    201    218    218    218            �            1259    49722    ventas_totales_vs_mac    VIEW       CREATE VIEW public.ventas_totales_vs_mac AS
 WITH total AS (
         SELECT count(transaccion.id_trans) AS "Todas las ventas"
           FROM public.transaccion
          WHERE (transaccion.time_trans >= date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))
        ), mac AS (
         SELECT count(transaccion_mac.id_trans) AS "Ventas MAC"
           FROM (public.transaccion_mac
             CROSS JOIN total total_1)
        )
 SELECT total."Todas las ventas",
    mac."Ventas MAC",
    (total."Todas las ventas" - mac."Ventas MAC") AS "Ventas sin MAC",
    ((mac."Ventas MAC" * 100) / total."Todas las ventas") AS "% Ventas MAC",
    (((total."Todas las ventas" - mac."Ventas MAC") * 100) / total."Todas las ventas") AS "% Ventas sin MAC"
   FROM total,
    mac;
 (   DROP VIEW public.ventas_totales_vs_mac;
       public       postgres    false    218    219    218            �
           2604    49245    acceso id_acc    DEFAULT     n   ALTER TABLE ONLY public.acceso ALTER COLUMN id_acc SET DEFAULT nextval('public.acceso_id_acc_seq'::regclass);
 <   ALTER TABLE public.acceso ALTER COLUMN id_acc DROP DEFAULT;
       public       postgres    false    199    198    199            �
           2604    49237    actividad id_act    DEFAULT     t   ALTER TABLE ONLY public.actividad ALTER COLUMN id_act SET DEFAULT nextval('public.actividad_id_act_seq'::regclass);
 ?   ALTER TABLE public.actividad ALTER COLUMN id_act DROP DEFAULT;
       public       postgres    false    196    197    197            �
           2604    49434    mesa id_mesa    DEFAULT     l   ALTER TABLE ONLY public.mesa ALTER COLUMN id_mesa SET DEFAULT nextval('public.mesa_id_mesa_seq'::regclass);
 ;   ALTER TABLE public.mesa ALTER COLUMN id_mesa DROP DEFAULT;
       public       postgres    false    211    210    211            �
           2604    49334    nodo id_nodo    DEFAULT     l   ALTER TABLE ONLY public.nodo ALTER COLUMN id_nodo SET DEFAULT nextval('public.nodo_id_nodo_seq'::regclass);
 ;   ALTER TABLE public.nodo ALTER COLUMN id_nodo DROP DEFAULT;
       public       postgres    false    207    206    207            �
           2604    49253    tienda id_tienda    DEFAULT     t   ALTER TABLE ONLY public.tienda ALTER COLUMN id_tienda SET DEFAULT nextval('public.tienda_id_tienda_seq'::regclass);
 ?   ALTER TABLE public.tienda ALTER COLUMN id_tienda DROP DEFAULT;
       public       postgres    false    201    200    201                        2604    49646    transaccion id_trans    DEFAULT     |   ALTER TABLE ONLY public.transaccion ALTER COLUMN id_trans SET DEFAULT nextval('public.transaccion_id_trans_seq'::regclass);
 C   ALTER TABLE public.transaccion ALTER COLUMN id_trans DROP DEFAULT;
       public       postgres    false    217    218    218            �
           2604    49525    usuario_ai id_usuario_ai    DEFAULT     �   ALTER TABLE ONLY public.usuario_ai ALTER COLUMN id_usuario_ai SET DEFAULT nextval('public.usuario_ai_id_usuario_ai_seq'::regclass);
 G   ALTER TABLE public.usuario_ai ALTER COLUMN id_usuario_ai DROP DEFAULT;
       public       postgres    false    215    214    215            �          0    49242    acceso 
   TABLE DATA               1   COPY public.acceso (id_acc, nom_acc) FROM stdin;
    public       postgres    false    199   z�       �          0    49294    act_acc_mac 
   TABLE DATA               2   COPY public.act_acc_mac (id_act, mac) FROM stdin;
    public       postgres    false    203   ��       �          0    49274 
   act_acceso 
   TABLE DATA               8   COPY public.act_acceso (id_act, id_acc, io) FROM stdin;
    public       postgres    false    202   f�       �          0    49447    act_mesa 
   TABLE DATA               7   COPY public.act_mesa (id_act, id_mesa, io) FROM stdin;
    public       postgres    false    212   9�       �          0    49462    act_mesa_mac 
   TABLE DATA               3   COPY public.act_mesa_mac (id_act, mac) FROM stdin;
    public       postgres    false    213   �       �          0    49337    act_nodo 
   TABLE DATA               3   COPY public.act_nodo (id_act, id_nodo) FROM stdin;
    public       postgres    false    208   q�       �          0    49352    act_nodo_mac 
   TABLE DATA               3   COPY public.act_nodo_mac (id_act, mac) FROM stdin;
    public       postgres    false    209   ��       �          0    49304 
   act_tienda 
   TABLE DATA               ;   COPY public.act_tienda (id_act, id_tienda, io) FROM stdin;
    public       postgres    false    204   n�       �          0    49319    act_tienda_mac 
   TABLE DATA               5   COPY public.act_tienda_mac (id_act, mac) FROM stdin;
    public       postgres    false    205   �       �          0    49234 	   actividad 
   TABLE DATA               5   COPY public.actividad (id_act, time_act) FROM stdin;
    public       postgres    false    197   F�       �          0    49636    cliente 
   TABLE DATA               2   COPY public.cliente (ci_cli, nom_cli) FROM stdin;
    public       postgres    false    216   v5      �          0    49431    mesa 
   TABLE DATA               '   COPY public.mesa (id_mesa) FROM stdin;
    public       postgres    false    211   �6      �          0    49331    nodo 
   TABLE DATA               2   COPY public.nodo (id_nodo, desc_nodo) FROM stdin;
    public       postgres    false    207   7      �          0    49250    tienda 
   TABLE DATA               7   COPY public.tienda (id_tienda, nom_tienda) FROM stdin;
    public       postgres    false    201   x7      �          0    49643    transaccion 
   TABLE DATA               U   COPY public.transaccion (id_trans, ci_cli, id_tienda, monto, time_trans) FROM stdin;
    public       postgres    false    218   F8      �          0    49659    transaccion_mac 
   TABLE DATA               8   COPY public.transaccion_mac (id_trans, mac) FROM stdin;
    public       postgres    false    219   CF      �          0    49522 
   usuario_ai 
   TABLE DATA               G   COPY public.usuario_ai (id_usuario_ai, id_act, sexo, edad) FROM stdin;
    public       postgres    false    215   5I      �           0    0    acceso_id_acc_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.acceso_id_acc_seq', 6, true);
            public       postgres    false    198            �           0    0    actividad_id_act_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.actividad_id_act_seq', 7007, true);
            public       postgres    false    196            �           0    0    mesa_id_mesa_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.mesa_id_mesa_seq', 1, false);
            public       postgres    false    210            �           0    0    nodo_id_nodo_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.nodo_id_nodo_seq', 1, false);
            public       postgres    false    206            �           0    0    tienda_id_tienda_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.tienda_id_tienda_seq', 11, true);
            public       postgres    false    200            �           0    0    transaccion_id_trans_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.transaccion_id_trans_seq', 490, true);
            public       postgres    false    217            �           0    0    usuario_ai_id_usuario_ai_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.usuario_ai_id_usuario_ai_seq', 1223, true);
            public       postgres    false    214                       2606    49247    acceso acceso_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.acceso
    ADD CONSTRAINT acceso_pkey PRIMARY KEY (id_acc);
 <   ALTER TABLE ONLY public.acceso DROP CONSTRAINT acceso_pkey;
       public         postgres    false    199                       2606    49298    act_acc_mac act_acc_mac_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.act_acc_mac
    ADD CONSTRAINT act_acc_mac_pkey PRIMARY KEY (id_act);
 F   ALTER TABLE ONLY public.act_acc_mac DROP CONSTRAINT act_acc_mac_pkey;
       public         postgres    false    203            	           2606    49278    act_acceso act_acceso_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.act_acceso
    ADD CONSTRAINT act_acceso_pkey PRIMARY KEY (id_act);
 D   ALTER TABLE ONLY public.act_acceso DROP CONSTRAINT act_acceso_pkey;
       public         postgres    false    202                       2606    49466    act_mesa_mac act_mesa_mac_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.act_mesa_mac
    ADD CONSTRAINT act_mesa_mac_pkey PRIMARY KEY (id_act);
 H   ALTER TABLE ONLY public.act_mesa_mac DROP CONSTRAINT act_mesa_mac_pkey;
       public         postgres    false    213                       2606    49451    act_mesa act_mesa_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.act_mesa
    ADD CONSTRAINT act_mesa_pkey PRIMARY KEY (id_act);
 @   ALTER TABLE ONLY public.act_mesa DROP CONSTRAINT act_mesa_pkey;
       public         postgres    false    212                       2606    49356    act_nodo_mac act_nodo_mac_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.act_nodo_mac
    ADD CONSTRAINT act_nodo_mac_pkey PRIMARY KEY (id_act);
 H   ALTER TABLE ONLY public.act_nodo_mac DROP CONSTRAINT act_nodo_mac_pkey;
       public         postgres    false    209                       2606    49341    act_nodo act_nodo_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.act_nodo
    ADD CONSTRAINT act_nodo_pkey PRIMARY KEY (id_act);
 @   ALTER TABLE ONLY public.act_nodo DROP CONSTRAINT act_nodo_pkey;
       public         postgres    false    208                       2606    49323 "   act_tienda_mac act_tienda_mac_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.act_tienda_mac
    ADD CONSTRAINT act_tienda_mac_pkey PRIMARY KEY (id_act);
 L   ALTER TABLE ONLY public.act_tienda_mac DROP CONSTRAINT act_tienda_mac_pkey;
       public         postgres    false    205                       2606    49308    act_tienda act_tienda_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.act_tienda
    ADD CONSTRAINT act_tienda_pkey PRIMARY KEY (id_act);
 D   ALTER TABLE ONLY public.act_tienda DROP CONSTRAINT act_tienda_pkey;
       public         postgres    false    204                       2606    49239    actividad actividad_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.actividad
    ADD CONSTRAINT actividad_pkey PRIMARY KEY (id_act);
 B   ALTER TABLE ONLY public.actividad DROP CONSTRAINT actividad_pkey;
       public         postgres    false    197                       2606    49640    cliente cliente_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (ci_cli);
 >   ALTER TABLE ONLY public.cliente DROP CONSTRAINT cliente_pkey;
       public         postgres    false    216                       2606    49436    mesa mesa_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.mesa
    ADD CONSTRAINT mesa_pkey PRIMARY KEY (id_mesa);
 8   ALTER TABLE ONLY public.mesa DROP CONSTRAINT mesa_pkey;
       public         postgres    false    211                       2606    49336    nodo nodo_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.nodo
    ADD CONSTRAINT nodo_pkey PRIMARY KEY (id_nodo);
 8   ALTER TABLE ONLY public.nodo DROP CONSTRAINT nodo_pkey;
       public         postgres    false    207                       2606    49255    tienda tienda_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.tienda
    ADD CONSTRAINT tienda_pkey PRIMARY KEY (id_tienda);
 <   ALTER TABLE ONLY public.tienda DROP CONSTRAINT tienda_pkey;
       public         postgres    false    201            #           2606    49663 $   transaccion_mac transaccion_mac_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.transaccion_mac
    ADD CONSTRAINT transaccion_mac_pkey PRIMARY KEY (id_trans);
 N   ALTER TABLE ONLY public.transaccion_mac DROP CONSTRAINT transaccion_mac_pkey;
       public         postgres    false    219            !           2606    49648    transaccion transaccion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.transaccion
    ADD CONSTRAINT transaccion_pkey PRIMARY KEY (id_trans);
 F   ALTER TABLE ONLY public.transaccion DROP CONSTRAINT transaccion_pkey;
       public         postgres    false    218                       2606    49527    usuario_ai usuario_ai_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.usuario_ai
    ADD CONSTRAINT usuario_ai_pkey PRIMARY KEY (id_usuario_ai);
 D   ALTER TABLE ONLY public.usuario_ai DROP CONSTRAINT usuario_ai_pkey;
       public         postgres    false    215            &           2606    49299 #   act_acc_mac act_acc_mac_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_acc_mac
    ADD CONSTRAINT act_acc_mac_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.act_acceso(id_act);
 M   ALTER TABLE ONLY public.act_acc_mac DROP CONSTRAINT act_acc_mac_id_act_fkey;
       public       postgres    false    2825    203    202            %           2606    49284 !   act_acceso act_acceso_id_acc_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_acceso
    ADD CONSTRAINT act_acceso_id_acc_fkey FOREIGN KEY (id_acc) REFERENCES public.acceso(id_acc);
 K   ALTER TABLE ONLY public.act_acceso DROP CONSTRAINT act_acceso_id_acc_fkey;
       public       postgres    false    202    199    2821            $           2606    49279 !   act_acceso act_acceso_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_acceso
    ADD CONSTRAINT act_acceso_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividad(id_act);
 K   ALTER TABLE ONLY public.act_acceso DROP CONSTRAINT act_acceso_id_act_fkey;
       public       postgres    false    197    2819    202            -           2606    49452    act_mesa act_mesa_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_mesa
    ADD CONSTRAINT act_mesa_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividad(id_act);
 G   ALTER TABLE ONLY public.act_mesa DROP CONSTRAINT act_mesa_id_act_fkey;
       public       postgres    false    2819    212    197            .           2606    49457    act_mesa act_mesa_id_mesa_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_mesa
    ADD CONSTRAINT act_mesa_id_mesa_fkey FOREIGN KEY (id_mesa) REFERENCES public.mesa(id_mesa);
 H   ALTER TABLE ONLY public.act_mesa DROP CONSTRAINT act_mesa_id_mesa_fkey;
       public       postgres    false    212    211    2839            /           2606    49467 %   act_mesa_mac act_mesa_mac_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_mesa_mac
    ADD CONSTRAINT act_mesa_mac_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.act_mesa(id_act);
 O   ALTER TABLE ONLY public.act_mesa_mac DROP CONSTRAINT act_mesa_mac_id_act_fkey;
       public       postgres    false    212    213    2841            *           2606    49342    act_nodo act_nodo_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_nodo
    ADD CONSTRAINT act_nodo_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividad(id_act);
 G   ALTER TABLE ONLY public.act_nodo DROP CONSTRAINT act_nodo_id_act_fkey;
       public       postgres    false    197    2819    208            +           2606    49347    act_nodo act_nodo_id_nodo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_nodo
    ADD CONSTRAINT act_nodo_id_nodo_fkey FOREIGN KEY (id_nodo) REFERENCES public.nodo(id_nodo);
 H   ALTER TABLE ONLY public.act_nodo DROP CONSTRAINT act_nodo_id_nodo_fkey;
       public       postgres    false    207    208    2833            ,           2606    49357 %   act_nodo_mac act_nodo_mac_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_nodo_mac
    ADD CONSTRAINT act_nodo_mac_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.act_nodo(id_act);
 O   ALTER TABLE ONLY public.act_nodo_mac DROP CONSTRAINT act_nodo_mac_id_act_fkey;
       public       postgres    false    209    208    2835            '           2606    49309 !   act_tienda act_tienda_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_tienda
    ADD CONSTRAINT act_tienda_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividad(id_act);
 K   ALTER TABLE ONLY public.act_tienda DROP CONSTRAINT act_tienda_id_act_fkey;
       public       postgres    false    2819    204    197            (           2606    49314 $   act_tienda act_tienda_id_tienda_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_tienda
    ADD CONSTRAINT act_tienda_id_tienda_fkey FOREIGN KEY (id_tienda) REFERENCES public.tienda(id_tienda);
 N   ALTER TABLE ONLY public.act_tienda DROP CONSTRAINT act_tienda_id_tienda_fkey;
       public       postgres    false    204    201    2823            )           2606    49324 )   act_tienda_mac act_tienda_mac_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.act_tienda_mac
    ADD CONSTRAINT act_tienda_mac_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.act_tienda(id_act);
 S   ALTER TABLE ONLY public.act_tienda_mac DROP CONSTRAINT act_tienda_mac_id_act_fkey;
       public       postgres    false    2829    204    205            1           2606    49649 #   transaccion transaccion_ci_cli_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaccion
    ADD CONSTRAINT transaccion_ci_cli_fkey FOREIGN KEY (ci_cli) REFERENCES public.cliente(ci_cli);
 M   ALTER TABLE ONLY public.transaccion DROP CONSTRAINT transaccion_ci_cli_fkey;
       public       postgres    false    2847    216    218            2           2606    49654 &   transaccion transaccion_id_tienda_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaccion
    ADD CONSTRAINT transaccion_id_tienda_fkey FOREIGN KEY (id_tienda) REFERENCES public.tienda(id_tienda);
 P   ALTER TABLE ONLY public.transaccion DROP CONSTRAINT transaccion_id_tienda_fkey;
       public       postgres    false    218    201    2823            3           2606    49664 -   transaccion_mac transaccion_mac_id_trans_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.transaccion_mac
    ADD CONSTRAINT transaccion_mac_id_trans_fkey FOREIGN KEY (id_trans) REFERENCES public.transaccion(id_trans);
 W   ALTER TABLE ONLY public.transaccion_mac DROP CONSTRAINT transaccion_mac_id_trans_fkey;
       public       postgres    false    219    218    2849            0           2606    49528 !   usuario_ai usuario_ai_id_act_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_ai
    ADD CONSTRAINT usuario_ai_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.act_acceso(id_act);
 K   ALTER TABLE ONLY public.usuario_ai DROP CONSTRAINT usuario_ai_id_act_fkey;
       public       postgres    false    215    202    2825            �   ,   x�3�t,-�/�,.I�2�t,K��LI�2�tJ,*������� �V
I      �   �  x�m�In9���T���o��{���0��V �CM*�ٔ�=�U=�_�^���ʟu�u}�]�w�_�����~����{uX�W�������k���f���}��#�{wE���v_��C:��~�G�]k�o�[����9��U���:?����=i~�����O��8�u��{���\���*�F׷?v~�i��J�Y���h��W��o���������'�ƥ�Ջ��f���^���~�������۩Ix�&l�#v#�̝D�S�S4�M�Y�b�h'�,�D�H͢H4�M�Y��&�,'��d�r�Ύ�D���7N�o�4�8i�q�b���I���'-NZ��8i1p���I�'-nn~r�6��x�BC�s;UT`�I��`��I�(e,��`��I���)ì���OC��QJM0D)5��Ԅ�5���Qk���c��U�I9���  �p�!Jͧ�7� l �0��p��	2� �AEM��2O�A�@�G��{P��,�a�a����A��A��A��A��A��A���m�4�4�4�4�4���^t'v�A(P� U�����n~�َgk}$C,`��KWxS�>�ǧ�}|�U�ɓ�}���>r�G�}���O�H�A�@��t��p���K ���$1�r���Q�I���DK�1�L�z+L���C0���:9���:9���:9�31�2182���Dg��3��Y��,�w�;�����Bg��Ka
u�D-+��O�3(��)ل�% L/a�0-�1��aaz	�K@�^����0%r�"�*g+��P�{`���$q�e��?�4h^;5�����4r��i�8;���a�^0a�a��HK�ua<d�~�+	��H�5Q�ђ#LY%LKN��P�������|�}l�5cRjF��????�%u�      �   �  x�=�Ird7��a$1�.^�}�0���v �>�����������������?���4�+��p�X`�2�M 	�l��
|��(����$�ϋ:}�˶�e�4,�'h�#K(˥ǹ���x��dh�<��ʵ��u���T��,��c�� *0��7p%�oT*0�6 �\R��XH\��	�n�Fy��ܚN�-���_p���3�V7j��͊�QTϊ
P���	6+ڬh�c�ڴ%���XT`���j];ʎ�����"��ߵM�X��x���r���8�pޠ�|4Q�P.���Go����K�߼��|���.Y�֛{p.P�(k���m-@m���ƀaq�M'l�� ���(�r67��=v-I�V��������X`��\��p�|�\��lʆ�~Z�p{U��Vd���FY��J?�u�bjB���b�K�x@,�\�W��k\TQE>lo�j�e
�V�w׳\)�a{or��s�|�0����	�&�ʥ�\�roW (Wz������r�0͔��H�֥��C�x������=,�Y�(�Q6#Pb̔��K{���򫼽5��4��vu�:^W@7*��(���}�Iԥ��K{��b:��t.�eݨ4�9N���9�_x]M+�����x����?�9�8?�P��1�r�ܟ38�����ax��������1��A      �   �  x�=�I�1D���3��k���VU&�B H���G~�}\�s��B	@_�V��jB��k���@?��M�ُ�&cR��I��������nš��s+�U����ʴ�B��ޚD�&-��2:��U�Zŀ5��V�s;�A=����b�=�@�sq��y���I�
#0���f�d]�Rg�'e�=�'��|}h$9"JP�I��s�&O��y! ��C9�N�3�6�v(޴��ب�:'ZQ�q��Y����.w�O6�;uw��z��v�"��k��.��ͥ��X`]��ڍPA�5�38�'���q�u!8�g[�x1[�$�3��̠�<�w!	G3S�H1%ԚހL0�4��,	��8v#�G]p�q�#z@Є���LgW3�)cŗ`�.AL�wq�z/%�XE��N�������)l�9�(l}������i�T      �   E  x�uVI�0;���ڥ��%[����{��%(E����iu�%Q�T�G��+9*��k�ujæ�����T'���pB_H�Z��bs萧f��eZ��p���>��
������Iu'^���
�9dգ�O�W�t��ȴ�G=TA�g1u��,)dH��"��dLԷ|yuF��<H�j+j��6���p��KuD]���wk�!��@l'�잉sQ�fe/�+{�.5�N���u<���x��Yq�]\�mXY3z&��⩛��ǆY3|B�$(���9c�Uv�_�Uau=Nd��	�=AȆ}g&X��9�a��My��wo�>nۿ��sw�%{�Oޣj���u���%E���*�^`S)�7�@v �*O��� 8�� [$�����_�a��Dd-�yٝ��|����mM��E�*&d����[��
��� ��+fcm4����@���3�ۜ�����}s��E�f�7�`��@fL�J2÷�^��UƊ�f�YD�͍�5��`��@[1[�`߰/8X_踚�^�l�(Lf�F�jva�I����K�v��G�NG��,;8���?���OKv�      �      x�5ZY�D)����>W�i/��u4I�����"��y��<�������{����g�l��;�^�Tm�ئ�߯�g��oa�6�wr0?�s�͕"k�c�Q��,�bp��ƪ�gL,��S_���V�����L�!���~g��N���7S�K�_S�{��0�=�W�Y$��b�'�	��/�p��p�����f���Z�X-)�Vx���gcT
џ���*Q;��D�H|����ڎ"�v4��*)��xG�6V�x[�;v�R���ǒk�2�k�Sj?JC��J�Ԫvh���`�c5+���J��&���/�R�w�F��X�}��ʜ�v�J�6�j�1F��;:_6D�^��
��<�vWSk{g'Ki�
{22�m�1�2zP��<j6{�Rjvى���Kg�(���k̶ֻ-S]�NY�Tj��}�j�� uj�Ӂ���-�A'qhD���ƚU���l��0���a��>����d��ET����8bPاF�T3?l�{���ܼ��+���b�B}&�{�CzcX��:�t��F�`XIp��e/wS���v3���c$�c
�|�
(��2�+Q��b�Q-fl��k��k��Ҹ�eM�l����L�v;:�~R�e�>z�h~�U>�� �藬�WV��-�"q�~;����·�����m��Kğ���2���Ij��~h��W��w����0���G��Һ�(�CG�W��T���\b�$�x�v��0E�p��*/���vBV8���yZ��V��	h�1܂o�Qc���*BF+�Q�=ƣ�G�����k�M#r���EŁ��C���E�R#dR�TR��kb��RU�D*]�Q:���EEӤ��ږ�D���[�ӕ���͏�ʥ��Ⱥ���M�%�<����l�H�<j>*�Wż:
yu_���Ս�&�K) ���t�rN0�{�;��
u��[���P��H]��4��K:]o���#̢�a�Юg�%�"�D���\���9I��Y�h�6=A>���1%��=ѹ:ʖ1e�5���+�>q}ܨ�R�,9ou���E�J�m-ת@E��Z��:Wu��z��둉�隯ui�W �����+D9y���ܵ���&�T�ͫ9���������K*E(URC��SEά��W�S��j|�핷y�k��j�_���������鏗:�}��1r��ڇn|i_�B_������9�htub���mc����z��L�A=�6��"J ��O�헋��v���簝�
:�u��D<(��:���";V�\��,��;y:�m���sգ;|�5@��E�,�����n�b-G�[t߭�Kd#�T�؟�q�N� �m �u��hh����D�\c���/nƁ�C�K�A���L��಍�9��B����OC(�$��x+�+#v�Zl��L�'�]��K����v@QP�~���[��ڦ��>�K��ao�[�!�%�5�������;xT4�qN��I�=��#w�ZA�`��p�(汷�pY�3(8Ԯ��c1~��$��-�u̼{|�m9��!,�^rD�l����}��d��:��=�:��V1�#^gw�D���������O?
�W�"�;CxH�G�{���cP{��� ���P*�)���X�H���V����Urk�E�(��= �Bw�pwƻ3^����vT6��U��w��CFGTO	�38�z�c<8��q׬����ۓ�.Q�:�dsWgO5���Q�	q=�����9%kAǎ0b�X��=&.��=w��K��ͱC�A̍�L��J2F������%�H?|X�j�n���2��{���K��C�����5&�!6��v��.z2�vXH��ٴ��V,��,?M�bx˻�d5�� ��~�`Q���!���#n��}K���:5����V��"|��</��yA�O�yJw� �G��̟����?(e0��(W�y��Bz��'8��'�.���g��g+�B?G8�r��k,�
���\.Zy.�H��`_��f
�=�w������9��fG�Ny9m�h �G�\�S�?�,[�����C)�A��)/�yJ��^���yJt�tύG�F� :E<�bn��jM���d��Y-���t�KC��yMA8Fy��%a�j �G��o��3'�w�
�<N�{�i}q8^�\1<G#�ʕDvF�h��-\��A�!_���9�ut/���펰��hy%ne�r˃۩c˺.���IU�]���r���J��^š�!�G�#�'�t�D�o!��kX����b�0:Ď� ��
Iy 5���������A	���!W��w-NB�ɜ��j�)@}�>�<CL!b� _s�,gܑ@��I�*�>����V�J�D���u�3m �������4F���e0{�e�ɴ� ��h}�d�d�Ƒ%@�L:�H`�UW^9�i:�iڞ�������%�2bZq�����F�"C>�Z}���<ʌ�ѴC�p�:j�ѼK�^GX �N}\�q�9W����K�\/�	����٩k�~�ҩ-� �/����˶�
�h���u%�)=n8�y�4�r5ګ���\.� �=�ҭ(y9��R(���tY�D�bw�Z��� �-[aZd�;�����^琁3��l{��&�i=�8e�ɺ�xb[�]��%�d4���v��̺lQ�*��L��[h�hf�)��6��S�)k�r��%��}��`��b��]����5تF�������U�Zɫ��A��Ђ�q��oq��˩;���%�H',�2�q�i�x�������7�8:�q�"1�F#�C�$y��]�tx����0�\��'jQr!�@�֎"�1 �0𰒷b � ^�s��9���4����!h���Nf�ȴaE��4�����%t4�����y�`L�� �_�Ho"�q� /�0%��ȟ!?L���a|�kL�=y��$����0�Q�\�Ɯ.N�2؃���8�.�t�����E̦����]`.���É�Q��h.m��8�hs]�S	����1)Oo�WR��ճm�<��:�x�����ѐ��V.A�ţ�t��Rkb�"��1,�HcD���_�0ժ(�b�x�Ղ�`���W�$��4&*MD:���JG�c�4��� ���#մ���%3�ܩp%�oTX=� <hx�"���~0&P�*踢���|Ԁo��^;>'[k	p6	2wg+�F�R�O�]	�A��Ǒ�� n���h@|B~]Ӧ��z#;Œ�?�2z_zj��{/bD�
zx@:��{xv��X�ӷC3�O�G!�;��cOC��М��:С<O$=�Y�1,�Y ����@�׳�?��<��A�.?�L�5��,[�}S���g��c[E�w�(i%uDR���{
�E_(����s
��fdk�ͣ����K}��� ���D)�p����j'w#�q��邡�E��s�h��Q"�Q I�5���1beJ�+^B��ʕ!�?Ь���~U�<�w�ͫ���������0S�y�"�Da �y_q�&�����W��H'��aB��+�{qI[��Y�����
�wPlt� ��	���;����5���|/.�|J�sP�cQ괽d����%��B��B�@�����M0}���G��GB:�*�Y\�o��R-������p��,�����mf��4ʛ������ě��F���v�X���y��>� @��H�y�zC#�h���.~p������SX��d��Q�4�@=�`/�Վ���!�Q4���\z{�X
�4Z�N��у�4���4K,y��'��dS*��0��[�K�oi�F�Ҩ��rr�;"���U�Y�?�4�3�gpШ-��n�4�����Q_=K�"'>^K4�-�j!x�fQ�L�e��h��j�:�|����K�"j����^��V�-.I�R��4z�F���W���j���t�g�'��V��ѠK�����}�K4����3i4����\�S&�����l�T�μԜ�+��F��TI���5   ��^]�\�����tn0�� �ڃ�+z�%[�dCo����� �l1�]����E;��S~P3$���.㈵�l�,?3�3�5�i\�]��5�s&:;x�8L�ȯn%���f?(�k��.�������]���+K�Ѫ��<Bm:�b������oY/��^����d�Pש�:E��lL1�X��پ�OLc(��c�4Ƨ4��4�S������xJc�Mcl�A�s�- Л�ش�&�Z��6��d8�\�16��L��a�Ƿ��v�����C],2��Zr<�3�����Mc���1�]�������Jc(X���?�C7�@���a��d�m�3�1�ߴ�<��XB����b������>�:���(����C�c�1e���MoԦ1���3�^V�ϗ�4�|���p�(uxoF_��6���4���o)�ws��(Nn#7����+0��qD�G����[i����:�l��cLc�1N
6�q7���|�1�'����[�_�/�難4�+�16}B�������� �ǎ       �      x�u�K�$������4"B"%�Zz�zx�Kh2��5`xpP�����	�y���������y�������=�p\?����y��_�x������߫��7���p����w������������g�~��zן�/�����}�'�_��;��ϻ>�����7������]�=��~�z���������y~~�x���iYF��s��]����Z���]�5�?�~T��?������ϟ��ɺ~f����]o��*Y�w��Y�����|������߆7U��=����NË:ه���S��,�~�����~ϟ'�����>e'�����<G|���=U�ܷ����������N�깷�繩�繤�繥��2��>�U=���ixS'��<�N�N*pH��)e�I����tR�Cp��|^擇v�f�5i�:Y����}S'!����B��/�A�� ��˗C�q�g\�;�|R��yH9n������[�q3yg<|��0���1�xhc���`xc��Ǽ���b��(/�N&�����bd�$�7K����9m�!���a�e�z��G�e�0�y1��kf��Ӿm�|��9�۾�;J=q�2�io�d�g��%�VH�}WT�A��6;A�2d�3��d����9��g�R���hV�,ვҬ�Y:	P3Y��*o�R3�2fZ�]���S�\�a�u�_��^���]�R���Z�ݬ��f�5+�^��aq6��<�;q1V��XL\�Uq����UX�,��a&���*�����:��$+��LcXU�:���dX��\f3�GX�a��@�@�e#[$��Hf�X4��P@8)N���~��{P�n��`�͂5#DV�	�r1�$�NV=H8�h��t��;�I>��9��r�-s0��`��ɼ���v��͞`6�l��������m�Y���!,���l�s3V�f��2d�����-ֺXh��^�.&�u1��������^j�̀릪��T���%|����b�`ٲ�ok��\�1vMƓ���LO[���*��8�;z��P`%�u%�r%�r�U�VU2P�Ł�Z������+TU~)Um���
��h۷��u���m�:l����}���7+���r��R�f��n$w;�Nv���~X��MӞL^�N��/��Œ� ���l�v9��L��;�ve)I�8Y��/�8ݛ����fܛ�~��#�mo���s�Z?� ���sn>ڹYT��M�)o�8�f�zn����q���U���	O|�*8�s��U����[�iUUN�N&ǝg��w'�b���wGǩ�$GMǩ�8����Twֳ�bmGMǉ�T���8���ٶ��qb<N���;����G16.n'
V�׭ҹ`k�V�<�`����K�kt]���|\C��`�!
V�-X�︦����,X�V�<�`yZ���U���|
�KŵTZ,�)X�f\�AO+X.U�j͸�i�N�&g��
�����Ԥ��I�S�o崂��
��ݷBX���}S�7W+���I�CY���]��8U��j&n.D��>0�۾�4 Ij�
��4��� qsiQ����J�q/M��<��R�f�� �U�5D���
�&5n.-�<R��UMՁ>m�T&F{����.4�\zEӀ���A'M�U5��znU��p�Q����p�[��傷��y�Z��I'Cs͂�L��C݂�����&C�3�.G�}��Д�`�O�|B-V4;H�
��I�f�i@����h��_ڸG�}$��j=�$)�&"�<Zd �p	:�M���1o&�`�C|��A�i)Pl�R�`���9r���NF��3#f�mp,F����a�Ai,���b�_�;*yI����nƪ��H�G�h��}XW��X5/ƪ�T���|�d:�͋�B�f����χ�����w6�sh/U�&9���@���=3���L���|�$=�N#��~s�-X��7�	��3O���}�d#�,	�֛eCXL�����"�`-��4��jie'\�G�i�����4��a掋�d�o��ඳ`6��mg�LGM��b��т5"+�s�jxd����
������`ZU3ak��m���kS^���`K�}���Zl�f����>�NC��[$�Y63	Y�}3��`���H��2D��P0%���,us$��|^����1/��y�������'Λo��V�Ѥ!<q��$��j�C����,r�4�h�"I|(؊V,�sx���F�C�H~qV0u�Ӳ�����I�dDN�z����Ƚ	I2��v�)Fz�-�`4�HO�Y���x"��X�c5O�0K�<,��Œ��K�I�`'�S���Ũ��/}�Ϻ��&$�N���X���s��-�c���j����s��$�`��kҥ֤�4J:���&�HU�N�[�u�;�	f_lś|Hsr�5�N0���4�R6�F��bx?,����=ݞk�A�؃�t�
���=8�Ӫ"�`��Mf]�3����ni7yx���ةO�b{󱓳��Q�^,��b�G[O|(F�q�)F����Y�f�woF�f�woq�b�n��E3���m���0O�`q[
�n��ɂ���+�s��8�S��$�a<���=�y��=�x�uN*������{��Y���x�`Uͯ�U�A�9���fc��ͯ�U�c3�}Nڪ�ϰ���6�x�u��g�|���|3�����;�K�$�[E|^���ZW%�j]�]�Y6���55�ˋ��l�̷�����|[6o�[Uyq!R-�UE�Lu�V��h/��"��l�
T�l_��t0$�#���d��{h��7�w͛Ԩ�u$�����C�J��	ϝW~.�@��TW�~y���7�Q�!'|���B���������|��d>�t2�� �~,��������}냰Z�|�F��z���:��	x�7�R,���x8z��p����w�5<,�*P�4/r�Ҥς��?��&f*P�>ɦZ*P�)؁�UA^l�+~k�V��0;P�z��\L��#[30�*�!
�����r���7;�
�*o��|
���V%?d>j2���"o��f�I�T��7�����d6�M�bC�7?)���>�.g3��Y��E������I�e'Edn��q�\�=S��|H�,؁�4�|�u.X}C��9��}��}��}
�����%�ȃ4��Y���~8������5 �e���[~�]0s��=�p�C#��U};�6���&iI��<_�fJ9�%Q�*�4�����d�aC�}h�Q�v3�r�s8"�K9P�;
����`��%�%Gz��R�=%���dN"̿{�,�G��q�oq>Ǎ�řK��А��,v>칛���+��n��'o8d��`'s���3K0�IzGN�v�IfFNw�]��i��Y��)$���4I+M�*؊M+�������qgN�8r�������$l�[R,���-�G�Yh7w��G�I�<�N���l��Sx��y����	�`�5r��Qɓ$Of���1�ӂ;��
f��D*r8�55J:qlƔTŝW������Y��\ѷ7��"xC��X6�J�C*C��I*C�Z&f��B�����BV$)�W���S��95+DH�����	�N���':I���!�o�Şl�̧�0� �&l�>r.�R�{����4��Z�F2�Q��8~q��kh*W������Y�O��1�O�H�Ņ��T�Y��,���P�
I͹x�)���'�9�l�T����ρ�on~p�2ȷ��nױ�u�v��̞����&lH'�B�'
6�@g�$��7��	��p�a�@OD���>]�8'ڇ�1�����:��x��{n�������>�h�'ǣ�>�A��֛ki���<��!3���^Qêz�!��F�ꅈʖE����Q�y�!��
2x�9�<��S�*Μt�l�\�����G"W�+�(�H�N�ӄ�L���Q�8杴��>��;I.�r���4�Lޛɦ�8;������,��b-������y��Yuub�m��}hP��tqF.Q�YBg�����$�[.~ ]0������ �   byj�6��k�FI�[|��}�v��g�T��@�M[0� �q�vv�Å���{���af�+��3�泗+��y�)�i�hn~Ȑ}�Nř��r��,��<����<��� sq�Y����b�[���8��<^:�5Va�ٖ5�L?(�ח�ψ�83]��ߪ�ԠX��Q�mU���ߊ]}t�řb����?�����ɡ      �   �	  x�=YKd)[gf0�ݥ�s���y�j�4~��?�����~��s�_�������g���g��%e��o��C�?��֛�߇ތ.r֛��7����1��9s?�9����7tR���cW��-s~f)I����b�J����(�!7��i'7.���f�'I�3 ��[�Z��5a�3nĞ�9s���;Ob��0Xa�(�ڛʛ�i;a�.j�F������
gb�7̤l����m����ƙ��&�k�	}s	W�Y���Ak����w"��	6~"_́c�9^���E��1��D�.�x�֘]_������Z?~��~����8������^�x���@��0��X�@��fx�98��~���T�!���-��4կI���6��9�!Pt��B|xd�K����6>i��):�*�ٞ�EO��k}��w�q�\����)P��j��>��Ę��T�#�HIy��G�D��!B�:�z���E*#q��1mq��wQ,(1�Cg��;�hPTF3sDS*ar�sT���r2��$`GN�|��r^ڂ�i,6iZ�x�i<�RVX��:S:�Ƨ3*S~Mg}�	������h*�se22��Y�cY,MYš^4c�	/f�D��O-կR��fX�\S����6��T}���d�X&��.5�J:��U!�,��j�R��!�:�����&�곱�>����S6�c���j���i�Ρ9ͯ4t�	�t��ΐ�^��<uI߅�>Y; -z L�%��nlc ��A`�	H��: �i |��o�c}}�����R��b��lp����d��pJZ� �g��Pb�� �}��T6t�M�2 $m��ܾP�t�f�q��W��Dn~��y��8&u�:E�8��[��vN�<����M�H���1�/���7(}"��(����K�?j��!wp��G�j�N0�N�8C����!�ӹFj�D��S![��G�\��c�4t4d< �$��v5tјݜyd��*Ї�-As�
����',��kn�.��]hP冔,�l�ue���s��s��3A����i2�$qP�,���,�Baӏ��v���P������íͩ~�;�����P���#b�q̧�>5��,ܝ�z ��VT����C��q3$r揓��p�'�"�C:V/��5C��
�� ���;� �P,�XAɖ�fJ�6�#��ĥ���g	�ꑽ 0n�\���4��W�.��0�B� ���ޔ#/�L������"� ��H,V�(��c���=7�h�[%[�$[���E+�k ~��=/���,�qכ���S� �|�����4�4ֲ��T�=:���S�}�%+jI���X%&�Q��e���1�˘FE�? hW�&�3�*T *��K 5�R'g��[r��ϰ��"�����;���s
DF7_=&���m@";@�0���[-�12�$���-��9�EXt1�OU�Й܇���E��4'�>bPp�ll#k��qJxY��e���cm��C�P��E�#,\�����3|@P��_�ᢼ��/����*�S�����F_�C4�8Os�������?K�6�l�)��f�����7�H�)����_yr(�C	�; !z�݋6�O<���������O��o��h��}q ��4�rP�:ܩ�tRNXr¡9ǹU��l�EK����r䟠;�NH9!�պtBə�H�_�����}�s�;t�]:��_�#'�Lm�c"�a[�,�"��"z��l ��2%����*��{��V��{ģ�����v�s���b1s�1� ��0��Jk�s(��.�+��@|o�qY��u` >���x��~"= �`�^^uH9��'jm���b�WA)�Ä���޴�ek�0��� ��A�;� F�{0���7uy�B��>��K���'�x�X�XK��%,���n9� �(������w�*Lvׄ.eE�c��*���2��!>�ͯR�$��S�>/��n���l��~��|x�ә΅�&Y���4| {Q|� ��V��Й#;F�'����bck� w�N��*	XKB5��N,�$S%����I�b�Di�%��GD�lћ:�2��1���Hr$9����y,�V$�b���� ��D����g���&ޣ�C���&��L�+	O��a�f�d�$�)>3�{kq�ڇ��,N��E�K>N	%gW*^�t����
X�zz������}X��X�[��F߷��4/�s`��v���� !�EY����1�H޷z�����������np���`�o�1�fI-ѡ�N����"�ʖ�rÕ��p�np��:1��r��1[|���\�����[�������?�h      �   	  x�u�Irc;E��b*H��Zjb[����Mu2"#�3yA���u�~�����~_����חn�Ǳ��{�~�ϕ���8�a��un�+->מ#6\$命�ύ�M�Ͽ�f��G�=y�n��-.�-�ٿ���y5��n��g!�����}����}_v�u~o�-q�s"9�P��ݿ{]���?��)(J<��＿����ݿ���Ⱥ����һ�7fm]�[��n>g�_��7b��=}��q�!@<XO��;�w��N���w0|׵�Y����Z�l$�c�qs�|ݧ̿z�툻�p�Z�[�n�h'Ҧ	��,(OP���$���AO��A8oi���mq�Ŷ��~�j��#��g��i;!�yw�TЙ��3��v���nR������#��6rn�M^��O������-�p�@��vW�>ڷC�F�"c��Nbo�6��m���n��.��n;���p��혠���:�kff�Ћ�0��/��悸��:�:�i�"����F--���F{�������Uyܼ�A��.耮X)�a��}Ŵe;7m�!��G�K����o�k�N���`,��^X���\�86F��X�E�@�nL�x�՟>��ڸ�juB0ڇ`1��[оCѹ���p� �'���v����L^�8"1pD�Fa�\Z$��yq.L0ٍ�΍UXv���`畆�R�c���uv;G��ZND�-�h&:`���?n����
`�ڨe�������掱���ְ� ���A�23չ��L��-sCq�]}�`ߕ����JR�<ʮ-��������Ϸ��<Ի�����T����i߶�^��Z��MS�ɹm�h[I���me�Sv��� k�M̂�C1��T��X	�>T�!��B��m%�n1^�V��Ff��#	��-&B͆��V�p��n`�Ʋ]x��IδX�H΢�d��}�D6d 9�R���lx6�r�0����1@�`�M�"�?]�|��jٍ�	ʀ-6����NP;a'��0Y�bu3�'8Tx�jR�(�3�q@�R�4�"$�H,��J�JbP�	�D����K�Ҵ}�ԅέ�����nz���7���qw�#$J�W�1��bB׾y��!��#�� �$~-�k�|Ik#)�b�����i���Ck�*d�C�@���$���o6�m�X�X�b�'Z��`���/̀�0�"�Ü��7�o�t�	�>n�?T��<��`!�B�6t<W�R�'i1F7��[����pJ��c:rG���.��hUğ؛S�Jj�[L��D��/bA[LM���'�7��$6�[�1"ǦV��A��w�}�P?o!�C��P̮��]C�|��қ��t�\ąٛ��D���0{�G�[��"'�I
*��Z��cy�Ū�D��KǞ$���� n$�mR'�L�Ϥ�LjыM���� >�X��L�.��2��˱��@Z���Z���b_�l�צ��b��P���ܾ�J�N�t󝸉���M����-&���Dc���S��+)u	����,�b�2��Z|�3����|X�=�����:ػ�L�$�هY�����>�> �lb*���#�#4��9S?L���X�y,��%�z��B�ڪ�[��@�?|��N^�\�P��Op�@R���a*����=�j_E�x���WQ���D�/����fk1�ޛZZ�� �s�CI��#��G���m1Q���B�;8V5����������>�x�G�k1�����K�-V�/vI"�ZL�@��Ҥ(s�L�"E�w��t�^�օ�K;B�ykw����U��3�D V3�D =M��TWe�J�y棆ł�ȋ+��u�-F����<�kb�W|�!��`��]ܶ0��a�K���O|��@���@��u�k�3�E�5�>�X���5��xG��v�Q7�p�����kL�o����-s�5d>l")�$I��C�nȶ�����rHK_T��oLGC�;�`��`��1�b�z���iK�X�Jt��FH8�y0��b�M���I,��Y9P'����ew p/tn��o�����P���_��b0�i,�Z�fŒ?��0��� ���7��}��R�XW���q<��XQGa���U-���W}"��>��{)�U�ʑX�����=�_�\�g`�;�!���Ӏ�3Y�3�Ekw�Kk��urX�E/M-F;�E�\GzA�!!̔`cS�K�.6�/�K��0��������ȅ�����u
K�RV^Y���Iy���B(g-�Nu�q�1T�'�������?���9      �      x�u�[��8������'p��w;���G��$��k��a�/5�����^�����{��5����U����SS.Yy�Y���j�<RR�H? e��8 ��Id��E�����)�G�
ﶤ�+ċ�j+I�A�����uV]�l�B."e[jE�sP��,e�A��zMDҶ�x�zP��9;�������l�3˭Ju�Q������H���N�@���u�)�뙝�@zm���������ZҶ9m�݈�H)�?���76�vw��R�vw�>���A�Q[ҽ�q+z���cD�#rw�W�':�;ӥO�ԝ����u�5�7�u���D����i�������]�����M�;u˟�r]���SH4oN\�������z��������H���p�I�;����+Z5'.�4��'n��Sz"/.����E���D^]4���ŭ)z�������)L/n͵�s�^ܚ��yqk^W�3O/nUX�e�-�<�w��y�֬v0��>�n�l���ʶ������-�I��A���U�F`U��ʶ9.���ŝe4��˫q3iX���7���xugU]���Fh-|�|yug�����F��]�W7��`�þR�@����>.~e�:��w]� �����A����|��1@�� �A�tw�' q�vF�����C�%����j�?�������(�aNq��⦃�+|����]�5/=�w]9���^��O�Q9{u�5*��l�Y��G쀲5g@Z����Pg��9���U����臀�@Y"�� �u�������:� ֕n�)$zt�B�̀��g�����l�52��z���\WQ���HtOB��%��`S��H[j�֛��;��,��.�l��������h���l��q7[�΀Do�wd�Y �C6��A�д�^����κ��'g^�!�n��b(��g@�P7g��1�YZ{du�֞}��yu{x�J��g@�d�=���Y{$�"_��g@"tꇼ�1h�kπ��y[{D��l��Y��ug���t]ŋ&$�n�΀ԩ a��0M��֝K_��g@"��E[{H����k���Ⱥ3K}�5gA�;Yo�,	�7�J���H|��ك�eլ��E��gf�Y�s��5<��,��;�Ț3 eqb4[s�Mݮ5g@0�Cĩ�JU�9k΀y�l��:3��5h@�}�N��'�}��ً�R���mJaC�X{�7kπ̤/��3 k�߰�,��4Ñ�=Ce^ڄ��n�K��1��[wH���nú3 ��Zw�jtZ�;�;]S�����C!�ŭ=4	�m�uq:�Xwd�q#�ŭ��K�ŭ#���!/nc��)֝ҶDċ_P�<m��HY�9�c��*q�r�S�=2k�U�m�|�֞�R��݃�0yB�Z��kπ���b�Y��1�kπ`Fī��+boY�=��i�Y �!^ݖBw��W7��P��HO��.֠���:��'F|)�v���^��`-��y�֡������:4 +�%�����t�H�\�+֢��*^�!뉼�+�®�=���u#q{o�kрLMxk��Hl֢��,�s��Z�@bt�t�ugRd���B�FE��A�3�|�4 �n�֠�rV�k���sX�$���b�B�IEWq�izA֟����-�p�B�������>��[�����3 Mv�X$|6�4 KS����(��\�A�c�F�n���*^]?����mW�:Q�H	�#kЀ��^�4 3���H�|G֢-�+�@��h��#��E��<�F�-�u;���^ꇌ��.UOd����]qȺڍu7�렺Σm�pN�8��	-���61�TT�C���Tyqm#k]|�ΡR0AJm�C�H�]�k��O�Y��-��р�K[m��h�߽�1:�Gqm#�6+Π	7���3h)w�vm#���:���ޗ��W��<Ρm$b�~�KA^�3�94 sUF���y��w�H�aum#ѷ7"^�yE��U��1�Ps�Ρm�3/lKċ;1W.ċ.s�:��l� �ŝ)�m"���x���:���<8ʪΡm+D�ֻ~�nZf�ΡmdjWOuH�m��V��6��ޑsh�[�shi���9����I���Ff�����ѣr�Q�CۈF��MD/Ŷ�ZK�К�߈3h@�МKum#�_?�4 �Z�V�9���/�9���ەV��6�9��ΠmbʠUgЀ���^�A�Hܭ�r��ΐW�A�H��:�[������~����/�9���v�(g�62n]�A��� �:�$�����kD����um#��Cu#rrEu���{R�E�H��Y��tmv�΢md޷rw^K��Y�@"�h3rum#1�a�rm#a�-:���ޖ���mk.誳h�����AQ�Eۈ���9�M�ʅ���F�ΫshYw�pHt��C�H�ߢsh�$	/n��W�,^�߼�wH�.����F�Vt���9� ��:4 S��jZ %���rP���T�Ѐī���� lZ ��;�:4 a5�X���b]�E24u\�G����֢���nŉ�'n 10T��H�R�Z4 ��@N\ !��h@°P9kрDD�.֥���T�Ҁ퉪֥i�3�պ4 1�U�K�Z�$}#֥��ѭ֥�UC������;j֥)�cͺ4 ��"u�T"u��dq[���EL��č� ��ͺ��=�+I/.F	���ui@�v96��26�V=�ui����:/n��!E�.�}'^�hM?�f=�pFl	֣YS�Z��LE-�z4 y�=[�����EU�G�{�
9h�M����2���Uچ�ᶄf=�q�7��2�k�/n���f=Z )k�Y��^��֋�Ol�Q9�l֡���:�@�U��6�Ѐ4�f-Z %B�n� -���ER���Y��q���O�]-z\!^�CG5kр�f-��E���C^�5��<5kрT�f-����Y���J�t��=�h֢�#t�H��D�E�B~h֢����f-Z �h�@�H�����h@�qy���p-t�k�HIE5�р�硝�@���^��@V�ȥY�V0.\��z4 U��5i@�ňfM�Q�8uq@&�����ƸE��z������Z�D����h �����6����f-Z ��_�Z4 1���֢��.�Y�V��⯵h@ꥱ��h@4�۬C���q�vY�f��}#�4 CW�4 �~k�J�߫���6�r��4 ���V��1��~�K{��o֞��Y{Vv�Vĳ�� @����3 i�۶�H���=ҵ��k������i�-���m��k�nd�ɘPRȸ���ٿ6"Q������/�_{�$�~hz��o�_{��f��k��̴���lq�r��:Qگ���/]�m���u�6��w�:h�i��ε���m��':h��l������k򳧃���шu�ϴ�#�ɨ[���TOFݍ,ml�ɨ[��T.q��)+��d��f4�q72t��'#�F�6�l��(q7Ryd�g�-��w�^[o�W��k�E���Xp�D�0���A�2d�{>��ʤ�>����J9���}!qat���A�qp���A݈�]W�����.�ŝ�u�+^�zQ�ⵝ�xD��1 I�pN[̎�B�ӫ�H��N�i������[��H��^��@����ŜY־�^��{rNM�:m��\Iz '.��q�:q��ݭ�A�c�l;hn�7��S�v�6b���v�6 ��� m�k�U��������Y%K;h����v�v͕u�-f�9&��k���8<�݋����u�m���A��&\D?�e��*^ڎ��B���>ѹ{i��j�w�m�ġ�{m��]o�m���Q���F[Iܚۇ7Z�&5������&�>�v�;�� nt��.r;���A��K��8�6Roq����̃��N���A��{�yw��L/.`j�6��#�wzq���ҭxqg�P
UӋ;�u�    >���]MC���_�C�ӗH�[y/ˉdj�kw�ȸ�Fԝ9���<Λm�t�J��62��f@�q:�;o�����&b������s@8�9��R:����U5�3g���p�,��@]ŋ�O�����F�l�!/n�:���&�/nGr.!^\t����f�S�̀��`ذ�,��;��a�YA�p�YoVp^W9ֆ�f��I"^܉އ�Zs���\�U�����8u�h�i�a����4Ú3 �r�C֝�E�7����z3��q�)C�z3 1��ҵaXo�nO֚�!'Ն�f@�fu��f@����f@FSc���&#�uf䚙֚����o�Y�i����Ҷ�k<�5����d�YE|�|��άboWӭXgV�'�v��ڟ4�2{��YM�6�:3 ��0`Xg�����њa��rߊ���q���G֚�Ad����Ѱ�H�L�z3 ur�ް��Ԏ�a�Y 9�f֛y>V�̀4M�̀��5g���jÚ3 Mãa��{|4�9�8/=�9}����1�֝�?�\Z+֝���P#��y���:�R�xq1�tI/n]�)�Xw���I��ug�T��������"�;#$6��ڟ���6��g��=���3 U����g@��j��3 �u��ʳr�?�=�M����S���WwE��B��+¢���g����n�a��;�X{��++ʰ������ �=é�KS���3 YnX{�;!���g@ڸ�rۏx/֟u�Jԙ�aZ ��s�tX�H���k�:NwppXֱ���z֠�?=,�FH֠A��LkЀ�Ǩ�5h@Vb�>�A��r���@�\�4 ���i���Z�4 �yh�n�K���uh��$u�uh@��H���:4 ��{�֡��_ay��x&6�uh@Z)��n8Z��5h��4�?�A�Hˤ/zZ�H��d�֠��<����C_CW��cA䚺�w��L/�:���[i���h@��nLg�ڵ��g݋Q7l��@v:����-��Y���g���hi���<�F�e��<�F"�1�nd���y4 �,=�3i�W�U��ر��9�I�Ȓ��Υ����Du����ѹ��D��'r6m#Sgݦ�i@Z���rPwvǦ�i��xh}�Φi%߷��M�j_�t6H4ouuΧ�����O�H�Y��|�F�����iY����%巙Χm�hw�t>m#U'��i�]/����L���i@�P�p>m#�ÚΧmd��t>m#K�*��i@ƥL������;;����gv>m��E;���b�n↶C�r7��,� �!A� n���!'�^[Ԛ�t>HX�*ĉ�1����O2�@ĩ���a�[t>m#M���iJ�9�O�������$M7M��6Rt�u:��L3���6-��8���qG	��6�����4 =e]� n�z}�Φm$�E�A���~� ���L��6FW9�;��fL��6҇"��i����ĝw>��|�F���L��6R5�p6��3�9��+W��:�� �ō�xhΧm$kk�r>m#U�ڗ�i��j9����s-������4F��|�FE��i���C�7�K�ȋ�E����i����i8`p��w9����"^܅�=��7��[\Φmdu���l��thh9������8���1��f9�$'���|�F�ms9����S��ٴ�t-,g�~[�u�g9���Gg͍-g�6R��CNܽ��b��em�Q��ŉdjeY�H���nY�$iѲ6�=2_֦��%����<z�֦�@�{�6���)��i����~�.��5Z���-kӀ�^u/uەo]�F�R{�6��9�ۺN$.kӀܵ��i�_��!`Y��7�h�fY���݋�i@F����F�Fk��>����emZ��l��e]�yq���K�H,#�I���ײHS�a-��s��Z4 �֢Ud�є��H�I�S��J.��@R[֡Y*���C�g�#_֡)ZUZ֢Qu�e�{�ʲH|8����#kFeY��*ɲHWf�e�"�S�-��T2rY��iOǲ�T�eZ Y%�uh���݋Ww������P��e��^����q�+��A!��5h@�j�,kЀ����H4X>�5h��r�3�Ѐ��^��ō�Y_�5hu�c�p���tlK9h�,���?�#��ڳ�ӨqnsY{V1��Ԝ�=R��fY{dh�lY{��?r�[֟i���?��ʙn�-�p��A�v����.kπ���~N[lP}�; �_s N[ ��P N[ �E
q�6[�	�i��.@ N[ 1ިD��@����2�ܦ]֞�,Skπ0�.�9�ʉp�x9 �s�⢞�}+q����Xw�pYsc�q��A\T}r���r�=�y"+��^���3 ��#9�[�HrP7����3 �y�����Xb���~ǋc��f��1>땭Ś3d��LE��x�r��-%��k�&$D:���Od���]�C^[�˘��A�0YW9�;OrPwVh�5g@VSwi��/�}��Zs�3�3]67�~?�5g�]r=W9��2Mk u���rP7F6S�ԍ�Ua���l'����
�t$ݨj�֝)W�Y��N]�?��[;���m�-	甗�׏A�!hs���cЄ ����B���?�v=�[\"X桸�&$�C��3�)�ǟ	i��V>�L˶a5�@̮���τ,���&f����H�@�R���gB�Y m�5ն?�LHf��@�����ǟ	iU�}��΁���8����7#se���cψd-�a���M�ǟ��3�ǟi)�}�����^>�LH���ǟ	�YA��τ,�JF���PX���τ�8���Xdӽԍ����Є���ǡS���Eғ��Ǣ	�EQ�cш��(�cф��5~,��r��|,�#rPw��"���3����Fdi��R0�î#},����8q��6�8qR
��m N\ �wʖ=;4u	�,}B���DĭV"N�@��ʁ8a����>�LP���t��
�뚓�X�س��e�?�L�!���L�%�K����Q��#)�` ^ۜT� �m�)ωxm#j�0a��^�h������y��ǝ��ܛ�#`A�:��ǝ	���
� n��B"q�+��]/n��m���ŋ�0Z��&�pc-֢�҆��m�s/�nk�$�E���z��?#�5��W��R�8�ǟ	iYo��τ�����2���4=2� ���C3%���Dt}Cs&����8(;�{rPv���fB��r��̈́�^�~>�LȜ�C��͈�М���̈́�oB>��X��v��N�@��ѵ���fe�Л%�̀d��DV�24PK֛Qq�@������9+;�&ŵ�D�7�92��5g@��9d%w� �N�q����Xsd��&k΀,��d�Y�|�P�a���%�5g@��m�Y��m'k�*��k> Ys��K֝A�s"N] �R����xکde�Q֝��i�΀`k������rP7�^��;��j��uXw�=���-mq�f ^�ң�`��!���>��[w$�W=�W-W�Ӻ�@��`�Y3)g���B��ĝj�֚wj�Y�jOr�v!Y����YB�l���!֙YL@Բ�f�OE��D�K����l��ʲ�Ȫ}@O��ŭ��T�xqk�b/n��Cw뵭����֝��!"^��{&;�l�YEڍKW�����Ub����ōxqN��?ۛ.��l���Ӷ�xq�IB�"�πt�pf�πL��l���~��g{���՝�iq2[�d������F/��3�o�,�?ۻ��;q��r���m�n:���%�l��ƚ���-J���dVN�f��*+�N` m{c�@��m��$���	1��w�� 
7?�݉74�֜z?֛�������b��@��;{G�E�� P뎈�vg���@���A榫xi��˺Y/-�r]8[w�3sp�8��x�����^�@���^�֛��]�z���c]� m    ֮�@Ңr�~� -�P[�̀�zf�̀ Q4�����y��j�U�+֛��[��H���fmS�a���84�֜�oHW���h�j�֜ɋC�l�Y��?EW��F����5g@3�rP� $9���l.֜i��wٚ3 �\Bꖕ���nM�����U�P9���|�֜���k΀��b�Y�p�[��@d��l��R'r���g��7K�L�	.y-����n�7m�d��C����Az�����d2O���fҵg=�t@��R����$�"RH���ug�3˩,/n������nmG�����@�M���S.�A۱X�*���3i�\mc8��r�����9�{/���i�wi�&�i�����q��������Z_�!P.'nF�O�y(ɉ����Ӧ��t ��oIN[dde#�X�2��2��=7_s���~_�+F&=�Wv���u%ye�(� �W6�[�3+�+;G�5.�K;�=�S��vU9�mx@��K>h�t�|����d�	t�ĺcJ>��Rg�Q�A�U��CqW��rwE/G��A�uo�(ŋ�p^�/n�|&��R���-_\.,ŋ�+1����]��i�@��+]���R��+�t?�Ww��6_c��_4�zuQ�J_k=��Cż�zP7k<���.��A\T<r7���K=�=�-�A\�u�X�3T���<!���(.�[im��g"mQ\B�A[��ӽ��§�r��8p q��Z��mS�"J;�ۖ�IJw�?�+�W N] 89Bĩd�̗���M�;q�n8%������~�iuP�8m���Vٝ�@��'�m 3e�N�8h=.�e��� ,��왋�e��S��8(���|�qP6�x:�2�" �8H�n^�A���y��8d�kL/�j� wza�յ�^���9t������ezmc,�%�b�Y����F��H%|}�֚)LG��HW۷ά�s��Xg��'�Z��*΍_�1֙�}n\ݠuf@�=ض���zE֚����Z����S8k�@�;���f@Pc��A�֙��Uk��o�� r�'m��֚):�U�5���j�Y�%�n� .��n� �@M>"u�Z�ԍ����Zoȼ��z3 Y��5g@�&ɫ5g����9uV�5��֝�x��8u�0e.&]�Pt�֞aa� ������.�-��L�Zw��q�i��֝��A���b�]$��H�"�8Vk΀������G��E� =�A�zϵT��JHZ�j��{Q�Zw�:�j�����ߺ3 we�YC!�u��A�^�=h۱H�-*��[����Bx��,,'R[�̀h�d�֬!����Vk̀4fE�^�2��k��ֱ����j��^C@�Ī,J��i&��W�3�9ʫ�A���N��l���Q�u�j���QΪ4�xmq`��*^[����֚���)kH�C֚���Uk̀t����L��֚5T�Վ�j��q"rP7�u#u�_�7k���gf���y�j��{��Zo�,�l�֛i�V�=��w��j����h���(�#)S[k΀DW���]��A\���E)hN�V�΀pʿZo��Q�����j���$X���ԫug@bt$�k����ڮ�qA������j�ٮ��պ3�X�)���9�� k�v����ڳ_��k�Y��WтJ��H���;��ui��Zw$	�;R���Zw�3#` N\ �h�֜�SCk�:���f���B �xmK|�\}k֜i��k֜�U�}ɕԬ7�{r�6��v۬7�(�2�� n��q������̀4�h֛�k����]��:��2} q���/�z3 XE%rP��DN����9�j֝-T8�Y�SH/�5�΀Vĩd�Fu�;[(��U�f���]���3 �7b��&�ڬ=2�-ZwD��K6�΀�h֝i:�լ;2�ϩYw$|f���/@m����S�%]� n�K�{��)��gi��/n�Q��f��j�k�K�p>�ug@��YwB�{�5gk�+Re�Y �b	Z������5g@�6�4�΀4V� -�
g���5��9[{���G+���3 E���3 M�b��g@�RK��Ƚ�Y{�����)9���K��l��:��=[ت3�:�;JR�����~��l��������'s��9w֮?W���sg@�ޓ��sg�Z8nΞY�s�*F܍T��oΞm�:����F���7g�I8S@�ٳ������FZV����F��%7��6��M�9$�{����FJ�����F����3 8/]��w�����}���62�Ż9��(!rж�zi���r�c(� g�6�}Hs�H��B��g��"��B�=���D��5T��ΞA�>��g�
yΞm��֋��������:{��95�q�6j��f��r7ƕ�yΠmD{F��g��׈�WaT�Οm$�$� ����g�芛����L�q��g@楹����Fp3Dڢ���r��DΟmd-6����.����u���֤�\w�l#񦩿�g@«w]ū;SV.����Fb��'�������g@��^��՝�$�J��gi:Fݝ?��hst��6���;{9��.�=�H����-��-9�[�h��Aܚ���;��������4m�Οmٜ�ĭ�9�e����&�č�`��g@�\B�Ɠ��8�����=�;����Y9n�3h��@�7�I1��W�,����u;������,�F�ݥ:������Y���I���hY���94���q�)���9���K��sh�ٝCۈNtg�@L5#r�v��3hY,L�A���}�3h�wqm#�u�9����v��ɨ�L�CۈJW�ō1yR����F�nZڅ�Exq�SUB�n�{}�H�7��E�$ċ�Ҝ��֠�]{����3Mg���g��e�n��U�fۭ?KX���n�����ŋ��>�v�πM�v�π,��֡���r�H�Ƚ[��k�`��l�\�EK(i�4\�H�.��A�r��֢��c��Z��H[k�@���i�7�֟��qշ�,�g]� -�?؞�AKHd���n���A�<�C^�	w'�k�̃E��ŝH}*]��3F�\p֡�Ϭ���3��H���a��22��ȸ��;�E�5�1�ERY&����+/Ű��;֢%J���Hlu�Z4 M�䆵h@PrP7�-#�H��[֢Q��a��m��:4 1��yq�uicðHV�aZF*Q֡e�ey�@��@��E�{��q���q�a-ZFf
�֢�:�0�E��dD��@f�9qQ��Jz�֡��2�C��SD��1�Dǰȝ�hX��1[��m��[k�@`�@�K�c��t'^ڌm%����Hm�G�Hi\�֠:�0�A�4p֠e��Ж�a�����A�;g���3KS������T���Y1%f/��/¹��2hB�/�C��2hB��*��x��6z��ˠ��JJ~:^M�@5h*�rh�>�ˡ	�ȇBu_�A �.*����Ź�{��b�A�\��F��.�ѽ��=-N��Ս�T��{u�X�(:�W7e����t�r�3���ԝm�}Pw�s&rP7�kt�c�]HcH��*�s�c�]]�N�8�v]��8����6c�}�^�u%�����]WU&�1��8k��xqW�3ň��]��C���]1^P'5���5H�<���٠����n�k�J&I�r�6�gE�t�.x�;FL���96U��)�V=�r��wﲜrk�R��f9�� ���t@��&ӱ�t@*+#��uxi��tu��h�v�pJ���A]d��=Ѽ�b�G#rP���h�:�����̼��{40������=���ȏ����^�A�.2{d"u�%!uc��A�Lu2�9�=6{�Y�C#�H�
<s/�,7��! �v`��w��*6��^�v��`H4$���Z���u"�ZH�C�X+��D��!7��HU����Z�����Z�&��uc���h    ��ȍ���T����F��z"/n��u/]O=���Q�F����!�F���M7�Ƈ��/)�<��d#iM7��@�	��F���1�hD��tz�@����W���T�Μ.�o�u�.�odh�h�(��q"�&W/��OE�Φ�	�u�u�ʓ�\��ވ��r�2�0㴔�u���ҹ\Z9�~�,�Wn�W�ܬt���++��l��c	�@\S�)�T��U��$��AĽg S��_��%�(n>�.�m��[��ɼ����D�«����)K�* � (�S�^4���*���h|�6X��-��V@�򌯊��֭:4�Ω�W=� %}]6�ͽ����Af"�v_-�n,4h˙h 5��޲;�����v�@��//۱��k�]�ki�)�l�$�[���'���V̲7��)��L�F�\Ѳ7���q�v�@��-�+Y�y�9' #i��r�h#E�ۗ�Ei,�ݖ�E�7.,g�6��"���W�,��sRv��,�F�F�Y�� s���^�ﴄw����l����D̽lN������^֪2�g#e
q�j#��_.Vmd��t�Uk�d��O�Ls����vc��۟�_%��A�l���^Pꙷ��2��������^��k��xދDQ����d� 37��rhR�A��P��y�N�p�8���nw�0a�\��Hf�~9c��:'_��E��bcp�j#�t� �ו&��9����'rAo#�'B��U�zܡ�/�f�̜u/.�m$t�;rQ$��s�U��Hơ��&�6R�%�=4�ƃ]�r��nhꗛ\R7���E��d��yx ��"g6���~�8�Z�~�0E��;.�l$׋��B�F�ǟ�A���Dj6����A[���%:ߴ���:l4
��u�q��bOn�m#���{rHW=ʞl��h=9�����PO6�,|ߓ�zi�®'���Wԉ�Eso=٠7~�H�8�����@Π2Q��w��F��u�l�{��ٳM�܄�����	�lT���!RO6*��/ѓ�(�Hc����=����|OΞmd�LYl��D�=ِ�rvO6���'r�.O�����@ʥ�O��H.j
no#���=9�����=�	���y�/ e��C���]��7*���_����D�n��G"��M��Y�5�|�#R��w�]�$�XA���&��Ջ}='�ɴ�=}=�F�o����$������Բ�C��H�������D���|D�d\L���~t�yD
�x��PiWӽ�(���;\ ��}�?"G���@O$Z����Y��{��h"���{��_"1��]%WyA*԰����
�F+�U��<D
G.�I�#���D�}+ɽg �C��Sn�Be���~�H�cz ����,���E"Rq-�N�,��H�S�_KI�r�G���J��(q���J$�]��7�YL[���u�������:���7�u�D4����u�Ȑ��v�ꙷ��?��W�:�n�Nv��������D�Fc���,}���HM���� �������FF߽�8�h仗�FI��w��BͥQ�w/�45��nt!���=}w�iL7��׻<���wzS�F�&}�7ٽg�/�;�I��~O_۩8r�^���=�3d�:FE�2����CC���S����8�������~H�.�ף�����H�^���&�f������Uo�����K�w������o�Ґ.�#rW���qD:����q�4�d�>v��������it�_'wG�K?t��w�R�11mUU#�7�0�d�_#�(����5rD��Z�F�H�{�.�)�\
��e6v���o����tz�;sI�j䞿Ӓ�!Y��;��s�=��bH�#��nk�4���8"u(�m����VDO��lm�O�ن� Z����Fo��&���|_��C�D��ne#��y/���U������a�M
w7} _+B�D��n�L��o�!ү���md0�cW{�;(����HV���*� ��E}M�&_�.+� �Kݯ/"�	�wU�������uND�����q?�Aܢ��.+� �g�����ɘh�n��n m�E��p�l���/��M��������C,&0��U7�\!�V�.I� �8����$��|�o��!S�?��ԃ�������+qm����wy�Y̼�ߵ�nd%��U�D����$҃`��tkN=��m$��<����$s�t<z�Z�{�-.���]��A����уh#d<���t���~H�S���_DTQ��K��Tn���� m�v�S�DP)��{��*�����+'��s��]O�AFm쀾�D�&�ޕn���-!^:̗�n]t���.��2�l9�];�APْ�W.>-:�˾<�b����r#��M!��;Ɂɻ˃4����Z+2�n7&uyWI�$�!�?�=��ER�'�.�")7R+3��w����!��ERd.�xI�!_t��ɻHʃ4���")7>[����$Ҙ裿��<H�G���.Q���.�r#+��aIy�����Ѝ�{�#ȁ0-II�	��xq'�x�n��ȡ%q��H�B&��i���w��H���Ŏ)�v`KW��>��EY�+�#���&L��2)r{�w����:�����~��L�hҚһLʃ���!��P�.���ͨhn�I��t�Qw#(�)��@���t���?$:�,]>�Qѻ�.�� ����Pʃ����Y���])�F�#��DֲӻPʃT���B)���Cq����c:"KK��R)72.���R)�-�Tʃ��w���hwk����`����8�@q�C"a�)�wN�D����;�B$���N����|Jyd/#r�v���;F%2������Ⱥ�%� .�y�#��ɛ�_�.�Q������ �G'��Rʍ`9D?��2�^�w	���K{ ޕR$�`DWJy�ҳ�.����w����u�ߥR���w���ı~��d������M[:�uR$���~��DV��;�CV��|����ߕR$�%��wG�.C�� �I�旅������J)RR�yuWD+nRyWJy�>��Ȩ�p�n��f�g��v��w}!��ts/QI����p#Hc���7������B�����B"��c��>Ã�_�gx�����]��FR*4F���܊�u�nŋ�R��Jċ����>Ãd����C1��wXH��_�gx������y�K{�g��r:�w}��O��3<D�h�]��A���A܈�j�nT��{z-�������N_D���=����FbՉ/��Ł{v�H �=p�ߨH$� R ~�dt�Cu�rŲ���Ȭ�R�?d\<��Cg$k��IT�-�7,a]� �bK1�wS^{E)4��hZt��*��U�rX\A�!�ŕk��\/v������������M;��������@��E�0_��xZ�8L��pqZ�8L�ce�9<t���;-�M� �9 �hz�Ψ�O4ulgT��I�t��.R9(,v*d/�h��y �l)���x-�h�e;C�W`��;� �k��|���4/��\��4�*�����o�v�$�E��u�Dڳtr�E�,����q�sǬ��"K�4����\h�
�W�zN"i�?tXE�^Y�[��H������Eڈ�b�^h��9<Q��ػ�6@k�5�ՙ]2�����%�#{E��~����F�F�v&l���^���GMu]��b�k�(�H�b��� �,u�v�]�̓ƺN��/�@-vC������@j��ý��+ۅ~ 3���U�����w��W���>�A8!~ȍ#+4+�2�ҴH�.C� C�Y_�H��U����s��w��r��u+�^���O��?s�6mPyW�|�%3�]��(TIK��)�{�E(�j�����5}?D�K���P>�rr�w����5��
��	|W�|���j�*�ҵ��]��Ab+�n<G���Aݰ�	��P>Ƚ��]� UK��7�$F+tV�
n��]��F��w��@j���wʹ��o�ͱn�ߓ)nu#SK    ��Be7Ҕ�����=H���׃�{J��&�H�97W����\1t��]n�A��Q7�d�������hK���փ�-P7ɷ�{`�u#�3K?t�e2N��z�{u�]n�A��,mjȬzO�8$,_��C@���@�|���!H��ԟ�KB��ze"N �����RӃ,f��2L7r߉�{v������Gt##��bg������w��)�my�	z�����:A�u��]'�A&˷�w��	[���C�[;M��Q��=HՊ��NЃ(�o�	z��S��:A��}�^���"ċ;���9��=*�����U�:A2u|�]h#y�san��.�s#�>����� ����f΍`��꺨����&�r7�T�Qw#K�=ޅjnd$�{W�y����w��	]�C����.��p ���r#��t]h��=�.�� ]�-�r+��`D/�
x�ƖyX$��i�@�.q� CS��&�Xz��˓�}��]|�AT���+�<Hc1��.� ��P:gx62u��]6�F����%��&��eC$Ft�o�]6�ԝĉ��w��A��E��PE����.�� U��]��A���*N: S�P�5)n$� ��w��ɝ��]M�A������;+��ă�N�.�p#3�8�EƍTe��	7��Γ�'��nĿ�qe�ޅ_��'B�bG�.�� C�߅d]EW��	��pd��xN�!�t�4�!wi�n��'�nw�4s���� ��Ҏ�T�!14���������aD-\�4y��t�s�&)?l"r�[��S9�f#Y��L�|"��ǙD�D�1����h�Z�5��4m6y�L-᛬�?$]:hf��)�+`��iڕl�������6��+�$��!9)�I?���R⺘en�@.`�ƅ_dR�)�1�o���h7�ω����vך��`Җoi�8)or�)���ɨ���0Ma3u��y�@�A�n�F�����=���Ha)�@w��@��i���O�*7�t�o:?$'�����&����r'ѵr�����/q�����S���< %_7r��m��.�m�%�'�6�Y��� `I���j���M�u"C$Mu"�eC�I���������4��Mu"��b��3&:� ��^�H�!��]m��O�RnD��1,U~���A��+>���Ԗ�!�]m�2g�I�N�޴3]�H�h��6�����#���8�����VJ��N��t�D�2�ks�9ǍL����FTd)��;FY��b��:��l��������f �N;���D����Ѭ��(�<�4�H�r�Mnn�j7��L�o�D�ۈ�*ܨ}Jk�ܠDN(4wJa#��v�Yh:�����L�����X��qs��ӵ��u���͝.��$�$ssG~kI�^�:<sY�*ܜ{�-7iڲ9���&��z���?rx�:t��n}#K���s{-	� D/ �G����i��~�	وN}5~�Zw�r�a/7���6R�rxEXo佸���/������jr�h�4?w񆡵��BA)"�%�NⰂP�JZ�9� ��)a�8$������;���E���@��]w�8?wZsM�ە��z��nW�w�V��K��iݮ��%���Z� ���+�J�{��������g�4�j���=;�ձCS��gj�����w���������9���g��Y�d���瞜�WV�u��n�3L;~�B��(�&�0����<������SaM��⋟�R�~����"tw�跄34n�����7u����=�]��H����sY@�y9��K�۹����=m��ea�亴*k����|owq䷆���;ⷄsM-��T�݅.��u�#~K8��|׺��]#�B�r��w���:��.B/��8�[���w��)�k!��.��k܅�߲��\ߥ�o$��ԧ5�}j}���������G��R�2���]'�A�As�Mw�Wy�-��!�6��:<Q������D�VV��owSb�U}����Z�D�;Fս�)��B����}��LZ8|��~���$�B����DO㵪:����T��I�����/-��l�ki�5 �nvG�د��l���eԺm��k/]K/��Z����s�í�`6�~+/��MQe��h�b*&K��v��էV��D+U-k�co��3U������@����AЀL�4���r)y��/L�\�E�x0�!�_ш���h�- Y�6b
�j�dhu��Ca�DiM]eM]�رsj�����3Er�D������:�����W80NϹ����xf
�j�f�W9�.�Kk��0#�w7�b���<N;��M�]�w�Ng�~K<������ֲ�s=Ѥ��<�mΝn��o�Gk��E���v�M����a�t�~<���5l$wMO�P��*�=]����Je7�x�5�gg�6�2o����刦x:i*��ʇgJ�r��RbSҗHR�Sҗ�9�%��T;�^�P�^���B��CO7��[(j��M)��X����4el�..�V��Yr���[)b��n*�r	'iG���K�>�gj�iMKn��FF�E�3i.n��n[�o5��ݶ��jR�r.�q5I��z\N�ʻ3zqO���ɽ�g����I˭v+�^XQE�i��^XႬ��K�(Ҳ��4'4%}�<�5�e7���S8���<� ��f��[J��ڀ���1E}�����e7$ ��n7]�F�I)kGڲ�����ݐ�w���-S��ȨZd�{�,�X2uH��:�g�}$���%j6���U�ݵ d4��e�$ YI9�_�����L$����L�j�j���J<lj����*�͗ݑ�v�k�����w�p�Ѳ��܇ٖݴ �$�h���D�և�W@�ݺ����w^i��nlX$M�)���D�4�ˆ+ -sՔ&�1���
��	JSb�����`��&�/�i�֯I�vm�Z{�_��6^Q�1�I,-��
�?�&m=4���J�d*i��f��ja��C�����r��.��֮��5�e�N��q���5�![�� H�9�Lqx"�J���Aǜ��d��+H݋�=;H�� q�R���)�-�i,kj�릡XoM�;����fG ed^vk[�߫����v��̲;��ޖs	9Hw��'��0�m
�+���=@f�D�)�N$Z�����7�?d}^v�v�s�����_ڝmk�L.^��TxgYò~#s]��2ju9��k8f7��])W����d��в��Ч��+Hn�t�n�� �m7���])��ݶ��<�yn������[����n]��*�S�[�ƙ����U���'rW�6���3���b�ѯ�M�c�쀨��0�߉�;H������@ԵAt�"�D2�@��'R��S���_�jf#|#j�kf�o#�~�f�sY̏��|��)�wL��MT�mfƐο1�O72�}+������*�B�F�ϴ�iG�����,'�9����$�p��A���AZN����<���vu,��
�ܠ��(�Y_�w�@dqgT3���PZ�ffI�D���r�A%"mc(��9h{�P6������O+\�nf3=����V�Ε�?��(�#��$1O��B'�̌.�vU�fW4y#J�����F�C*�k��'�(7����T��o5Fy��q �µ�f6�i4�lr'�B~C�q �|R��8���t��_'H$si��M�D8����Q;�G7���ȼ��k��0�ʹ ��R�C��H^�;P Qu��U$A�_�w(A$lo��&�(�h3��H�8���d-����H�������tT��Æ��
|�l�'R�絙�Z"�ے��LOd1�{3��?$'ݮ�LOU�~�w��HK�WqÍ���f\6��y�ffkH�8�lf��H�Y�{x�1{h3��D˔53[Kd�4L3F��T9�f�8�r!�ۭ�c�f�8��bO�q"K���?���x+6(�tG�}���%R㌱�D��ȡ� ��*N��U�����|毁��D��{[x�   E��{W87.43�Kdp}���\"|���~_�����?���-�ޚ1�DF�K�1�b~�f��iא.��\"8�E�5��s<�*6���Z���@bH�6g����曶q~�D]lr_�O���Q~o-�؅}�>	��%r����N�@ ;�s��nv��^3S��oK��GE\0���v@3��C��T���D���ND�Ndr��X�ђJ�].�m�(G����Fj�4����F���r�n��Iļ����_U��n�y���n�j�����F��i_.�md�$���F�#rx��t��r^s#��]@�H�8x���~�8ut����{���"b���u��r&p#�$���vgS2��8Idd��wq��]���.N�����C�"�f�Ƈ���C0��[q�j#�:C��$��� ��l{�P[p���� S~�6�C�	�w 7�E^.�md)���]��!�/��A��=��\�ۈ��\.�5d�IJZ|}�7�p������D\��9i���rs#Kl���II��/T7R�9.T72��Ù獬v?�A��$j�w�DUf�뻌J�.�v9������ơ���܌���$x�:�@`t��%���3�i�l���,��* YK%�F* Ui���T@T�*9[������ٲ��(��9[Ȍx�E�d�r�[NΖm�]�.��-ۈ�%�@L��dc��� ��6��Z�Ln�r#U��3e�ʍ��)��ԙ��L�F��F��ҭ�]O�Q
��c9�����A�<��29k����]�7 ��ۺ��?��?����Z�,      �   d  x���n�0E��W�
�z�Z�3}�3S�EVA7�Et��r �-��/�-/yxp�AcnԶC{�����G"|�cf�'���}����z��>��,z��G��m��v�p��TV��Ι��L��4��Ҟ�e�$4���<<�\X�6Z2��n�Z���,�B�t�x�Y����
C�����U�*�>�0�@�O�^��l@7�r�7/T~���{�a��4փ8�]��C٘b���}d��o���0&���n��&/�R�/��D���4��I�ֵL�d�s�!\�E��3�*&o�����ɰ�So�K>�c·B�;�B�ӝ���
��K�Ea
.%k����0�/����R� ��M      �   "   x�3�24�2�2�2�2�2�2������� -�K      �   L   x�˹�0D�ؿ
*@����' H1B��/�l��z��y���#��Eo3���f1�Q�B�X��'����������'H      �   �   x�-λn�@��z�)�lCn��HA����v<b�A{I���IR���N���)S�9��|d1���x/�ʱ2���!qfK��=����G������X�+�g���K��T��μ��'h����z�?�g=����۱�i�n�D�Kxc��.��`sU��R���#6�8Ȟ+�*�;Jש}����G;      �   �  x�uZQ���
�N��'�Y* ����?�WDs4;��wݾ���EQ`���Z-��v�a]避���W��?E>L'	��
��D���z�LgS�1\���G3e&��TnR{����F�ژ�s;��Y�b���~�v��頣U��"�ƏZJ�B|�Õ����D�y)��`c��ϦF��^�&.�͙�RL�Z�eځi�.�襇	[�Bt�4m��uv�"'�jw�CTi��R=��,��t�|�;����F���b���:.��,j�1S]�Ը��c���� �ͥ%��rj�\�q|On�%Y'0���y��?� u�Zv;R��ڌ�֣�+�-�,��2 "�����ś~\�������:ݽ&	*�,E�FԔWR��{al6�0b��8*kov�᷵7�}%(���<�0R����dsGP���lsDI"��
��S7I�����A6[�1ҡ�����i(-;@� {�ĵ�ƶ�o)�j�'���q�ְ9W*!>	&����Puf�1͐��+����c�C�FV� �Eu���xP �����ӧ��+m�8�%��)�)�ȯ���~�8���@�:x�k�
d��9���M�xY1@8�7�6�(p��q ����l\X�u���&�� �Y�����Ѓ;�f���SD=���w�3; qC}���AVd�	�C�f�9hr�i�A��B"q����?0p�Ṃ(@vz�h�������J�*��z���f8FmͲ40j61uY#К���-�����^�^�dbEI�: ���E�YB�� }[��F��l�����x$ �=�f�X&�L<0}Ol���5��|��@������5yr;�A%�[�=�;�ö�A���u�;_ �_$E�佔� 3��k3�"��:�;�nqm([GNr8��N[ǡ�s
��Ti=>�v�n3 6=8EŽ����K�آ�#+f�iآ�	�!#ε?�5�_��e	2����M���Jb3h������u�c�3�<�tV���60�K]���
/!�2�+ejG��j��-�8B[����(��������?��Ս�/y�]m�}�����ҕ��&��i����M��<�1Xhb���0��:�N4h�*o䎸��z��<����8�w��1�ms߫(���n�`Hغ;l!>E�D�}�F[Q
��7׈�Xi��#y.o�׉`5��c<�F�7�=�nM0�.>���Q�E�%TDs^(b�]�1˶������<��`�5�ǌ���+i�K����V�H�<�Pܒ' �MN��{�B=;0���������k��5G�3�V�&��H5�[?��Յ�����-Z$���JQ>f�~@j�}`x�.
��p_�4����U�e�Һ�Iz�mb�G�r_%��hү��L=d]y�+�ƽY=1�#{�V����Z�܃����rj�/���a�f�OR�1������&�.VG�k����9>l+���j�<ǠE�q?B�ۇY�`��?_�|�����O�j{���չ��RNЯ닣���2R�3�mjukԾ�₈N1���*������<��׍��f���:����C���/q���q��2Tվ[���h��?�D���@��b�����MY�*�O��Fђ3b;�D�,X}ׄ���u���K��ǡ#?{������J~��K�p�݈~a���E�WD��D���5m^� �=��y�S���G=����N�.l�;A�a#��bpx3����c2끶euQE`d�ug`��5D��}�%=Pxw�i%bt�Z�h�^I= ��ٌ��%"�Q�;݋����,�QRw&�g	���1A=�g���2�
ݚD� }�&�i�,�2�����wa�lܨ�s�Nn��[�����kr����1m);0(����>�S�;��U��x�B��W
��
�n����ڷR�T��nҁ6�m
&�|���w��P�j�'���'Fw;Y��q������aS{��A�7�ж7d�pKXpa��H��c�)��m�g1�4�4��7�Q�TYP�[t��A��W����|Ȥ��^Bp9X�S[T��!i#n15\VWb������m��>5D�MI��31���lm"�QA���4<�<1�߳��-���.��Bo����q`�"���>i���'{CU����Mp�V^4���71[� 	�Ѭ������i������~��}@�0$<��!���n��WS1!Vx�E�Βr�Nрȩ7��?��H0vb���l�Aܧګ��1P��y�(s��0��e��� ��һ	��1��(�k��UD@Џî!�Z�S��;�'�p�q9�mf�ь�§��ف�ڧ��:���>#rk����Z>ryI��2ב�j��W��X���cn�5b^&��)�IgtW6���7�0����p�wܰR!� Q�u��9���9�ѓ�� ��ʮ=�(Šul����xL�ɩ�E 0��t�F��~nksk	ІA�2�	msk�#<��g� :��G��COS�0V���l����y���3f>8ж!~�q��f����c~Mi�!1��Oށ�=u�}�I#}z��xU�.��N`���}j�I`T����px����h�i`{�6z�$*�ٓ�0�<��y	�6���T�I�}4k������hC�a�Zr��鵍��xdٚ���E�܉�+��a��Nv�$l�e��(=�ĦR5��ۛ��q��O�F�� ����������"2�R!K;Aaʄ�i]?�Cs%�)�:�\ ���c}�?LA���vczi2�+���%�����	�7zc��l�F{>�L����i�x{?��o�B �V�����f�*�����ǀtn��b���9�ԑ;��
�]*����fk�⣕�|��1�p��(��8Oh�z~S�_J"-zv�6�D�xl[:�z`��MϨ!#�es�M���"��Y�x@����&�h��&�� Ν����ߧ���2�2,��@R�;&F�d?���R�s|ڑb���<�x�D�<��1-Q���������e)����Orz]�%e�eg��?�*�O��+n�68����6-@�"�F�T� ��
}3��_ӹ	A�Dz����"(Q^�=1V�[_�P���;�rct	U����Xr0����h99Oqc��:&������%96=����?F�&	Х��к�����	����~|�T�[��zL:8��xF<� Xp�S��Vޕ޿���|�`�&F�ʛ&!hPPA����S�K���"/��b������]��m�}$ѱ��p�¸�\gkP��ӻ�]/B]�������w���O�R��`z`�>�B�J� �T�R�sC�ߓ�����g��/B a��#h�4z�{_�񆓤NLr��;�j�¸J�n毻����FF��>qPԶ�� &a����������*7��ʬ_R�@�Q�Z���%� r�'F�a�w���?�pL�&      �   �  x�m�A��*DǾ���ABk��8v���'�}�R"�R�����\�\+�{����1���k�8���Y�~�O�#c����y�jQ��+Cy��={��#r��+�r��X�P�{����+�j�����y���_�]�=��q=g~-�W�v\�����{B_�Z�;����V�+�rX��hw^�|��wa\�:���6��F����ԧ��l��2�A��0�Ľ���N��:T�Wu�T��70��|è�!:-�Q���Xua�i�;k�1�Mqw'�l��֡;[��*�V�U܍���ͽa�5b��sam �F����:�#��ڦ��b��c��v�ɲ.�Y��b�,�A���)�A3d�(�1)߱��#(��̌�`��ڢ^ͅ1�lS߄}�b-��b!���0;���PL��ӐQ�NP�I
n�C�/����i�CV>��>+ǁ��[��-���E�(�E E�̐c�]��\�Ns����X�r��:��ț;�=.F��m�qy`ۨ��d�jl�Y9���B���Ѵ�Ѵ�����L��|U~��J�!�R{Ȭ;�L}C4ȝ4ȝ4H�4��5H54h
e�jVj9�2Uj(��[��1U"�J�y�Q��P��u�&�?h�i����=�z����DF���}�W��yI���h���;�n
�7 ~��^,�٨�o�W�=��t��������u��c%+�8���B]W�kF1��A�� MU�o*��M�������� #u�      �   �  x�=�K�%'�݇�	\`vs��
������QN���̟Q[���3����E��D
�.�{(EYE��e��x6E�?�ް���LQ@U��.�����q	�}�҇��p�q�m\z�ْ�ƥO��3\��ްq���l�2���${�z��eQ�P%�\z����K�~k�7t�TK) z����l �������%ԳU*a�TgN0A���);�2"�h��Dc���"@��-#VI�:������X��V�XM�� �����*�ᕛ��U�yJ%�U�v�_K+�ۍ߶
rƛҩ+����z�N})�q\�Y�)�A#��Y�u��WI5��}�o՝B
kI��p|�@�T�
��n� �n�0�*ky[�XU���b5ؠ��c5X��<�
pR�형���CV��9���y�X8@$7�=t�#�R���Y�3�X�@H��O7�d�(`?�%� �jT#��Ԫ�)V=��V�+]`ձ
?Ū�-V�N5+�n��X���,�����1^�+7��N#4vgڧt8k��x��R	�v5z`��TR#���7�a���a��*���@5B�����f��9�~�R����z)�2��'V�U�o�r��c'Vvva����]X��ja5�������^XM��-�4���x)Y��Y)υ��Q�.�j�D�7�t�>/�U��N	"��-��78JaJ�x�����I/��I������ʩ�����Ί3�g���4���`��J���HjYp�ҩW��2I�$t�3e�4z�k%-��4(1<lA�(��i�=Ъl������Vn٫�]襌	����ZT��T-*7
���ZU-*�[�ڰr���!�	]����.N���~��)�oX���j4��=熕#(�V�)X�c��U����W���h����c��jQ��0�}ی�G�(N��h(ׄ���#U'-Vg>"u`�!V�>|u`�!���ꄌ�bun�h`unh�΍�S�KVo���Se�r��*�r���5�:�E#�:1b��1b���12�X��$��F㷉���X��P���db�ʓL�V{�d�\�I��s�'I��_X��s�!��@4��-�v���wͫ$�Z��c9���L;�������ɖ_��U�#�va�w��b��sa�	�+��I~�yc�ۭ�]��
!�oRT�l�3Ȕ-�潩���~����'��.��2Յ�O�+���yc5���X�w�+�7��Z��T7V���n�Υ�(�X�|]���Ϸ��X�g�
V>_��
V�Y���?O��־�i�]nqZ�j�[�V���ⴂ�~��V�����ʟ'��*V;o5Z��\z���<m+_z�oS�'���ߦl����{���g~(����6e{��-3�J�w�ܔ�9��dS���CY��­)ۅ��~�=�_	     