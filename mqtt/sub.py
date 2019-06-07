import paho.mqtt.client as mqtt
import psycopg2
import json
import random

# Conectarse a la base de datos PostgreSQL
conn = psycopg2.connect(host='localhost', user='postgres', password='ronaldo', dbname='sambil')
cursor = conn.cursor()

# Crear instancia de cliente de MQTT
client = mqtt.Client()

sql_ops = {
    0: 'registrar_acceso',
    1: 'registrar_recorrido',
    2: 'registrar_tienda',
    3: 'registrar_mesa'
}

# Ejecutar query de inserción con el mensaje enviado
def exe_sql(payload):
    try:
        cursor.callproc(sql_ops[payload['sql_op']], payload['args'])
        conn.commit()
        print(payload['message'])
    except psycopg2.errors.InFailedSqlTransaction as e:
        pass
    except psycopg2.errors.NotNullValidation as e:
        pass

# Se ejecuta cuando la conexion se realiza
def on_connect(client, userdata, flags, rc):
    print ("Subscriptor activado :" + str(rc))

# Se ejecuta cuando llega un mensaje
def on_message(client, userdata, message):
    msg = json.loads(message.payload)
    exe_sql(msg)

# Al conectarse, ejecutar funcion on_connected
client.on_connect = on_connect

# Al recibir mensaje, ejecutar funcion on_message
client.on_message = on_message

# Establecer usuario y contraseña (broker remoto)
# client.username_pw_set("", "")

# Establecer conexion
client.connect("localhost", 1883, 60)
# Subscribirse a un topico
client.subscribe("Actividades")
# Poner al broker a la escucha de nuevos mensajes
client.loop_forever()