import sys
import paho.mqtt.client as mqtt
import psycopg2
import json
import random
import math
sys.path.insert(0, '../env')

import personas_info

# Conectarse a la base de datos PostgreSQL
conn = psycopg2.connect(host='localhost', user='postgres', password='ronaldo', dbname='sambil')
cursor = conn.cursor()

# Crear instancia de cliente de MQTT
client = mqtt.Client()

# O conectar con broker local
client.connect("localhost", 1883, 60)

# Dejamos disponible el broker para recibir mensajes
client.loop_start()

predicciones = []

# Para nodos con dimension 5x5
entrada_nodo = {
    1: 1,
    2: 5,
    3: 16
}

def IA_make_prediction(persona):
    prediccion = {'edad': None, 'sexo': None}
    if(random.random() > 0.1):
        prediccion['sexo'] = persona.sexo
    
    else:
        prediccion['sexo'] = persona.sexo_contrario()
    
    min_age = math.floor(persona.edad * 0.9)
    max_age = math.ceil(persona.edad * 1.1)
    prediccion['edad'] = random.randint(min_age, max_age)

    predicciones.append(prediccion)
    return prediccion
    

class Persona:
    
    def __init__(self, nombre, ci, edad, sexo, mac):
        self.ci = ci
        self.nombre = nombre
        self.edad = edad
        self.sexo = sexo
        self.mac = mac
        self.io = False # In -> True | Out -> False
        self.io_tienda = False
        self.io_mesa = False
        self.tiempo_tienda = None
        self.nodo_actual = None
        self.nodo_anterior = None
        self.num_recorridos = 0
        self.acaba_de_comprar = 2
        self.tienda_actual = None
        self.mesa_actual = None

    def acceso(self, entrada):
        msg = None
        AI_pred = {'edad': None, 'sexo': None}
        if((self.io == False) & (random.random() > 0.05)): # La IA tiene 95% de probabilidad de poder hacer una prediccion
            # Cuando la persona entra, la IA se activa
            AI_pred = IA_make_prediction(self)

        #cursor.callproc('registrar_acceso', [entrada, not self.io, self.mac, AI_pred['sexo'], AI_pred['edad']])
        #conn.commit()
        self.io = not self.io
        if(self.io ==  True):
            self.nodo_actual = entrada_nodo[entrada]
            self.nodo_anterior = entrada_nodo[entrada]
        else:
            num_recorridos = 0
        if(self.io):
            #print("{} ha entrado al Sambil".format(self.mac))
            msg = "{} ha entrado al Sambil".format(self.mac)
        else:
            #print("{} ha salido del Sambil".format(self.mac))
            msg = "{} ha salido del Sambil".format(self.mac)

        msg_dict = {
            'message': msg,
            'sql_op': 0,
            'args': [entrada, self.io, self.mac, AI_pred['sexo'], AI_pred['edad']]
        }
        client.publish("Actividades", json.dumps(msg_dict), qos=0)
    
    def decision(self, probabilidad):
        return random.random() < probabilidad

    def update(self):   # Se ejecuta por cada persona. Arbol de comportamiento

        if(self.io_tienda == True):
            if(self.decision(0.5)): # 50% de probabilidad de comprar
                self.comprar(self.tienda_actual, random.randrange(5000, 1000000))
            self.tienda(self.tienda_actual)
            self.moverse()
            return None

        if(self.io_mesa == True):
            if(self.decision(0.5)):
                self.mesa(self.mesa_actual)
                self.moverse()
                return None
        
        if(self.nodo_actual != None):
            if(self.nodo_actual % 2 == 0):
                if(self.decision(0.65)):
                    self.tienda_actual = int(self.nodo_actual / 2)
                    self.tienda(self.tienda_actual)
                else:
                    self.moverse()
                return None
            elif(self.nodo_actual % 5 == 0):
                if(self.decision(0.3)):
                    self.mesa_actual = int(self.nodo_actual / 5)
                    self.mesa(self.mesa_actual)
                    return None
                else:
                    self.moverse()
        
        if(self.io == False):
            self.acceso(random.choice([1,2,3]))
            return None
        elif((self.nodo_actual == 1) | (self.nodo_actual == 5) | (self.nodo_actual == 16)):
            if(self.decision(0.2)):
                self.acceso(list(entrada_nodo.keys())[list(entrada_nodo.values()).index(self.nodo_actual)])
                return None
            else:
                self.moverse()
                return None
            
        self.moverse()

    def moverse(self):
        self.nodo_anterior = self.nodo_actual
        nodo_nuevo = self.nodo_actual + random.choice([1,4,5,6,-1,-4,-5,-6])
        while(not (1 <= nodo_nuevo <= 20)):
            nodo_nuevo = self.nodo_actual + random.choice([1,4,5,6,-1,-4,-5,-6])
        self.nodo_actual = nodo_nuevo
        #print("{} se ha movido de {} a {}".format(self.mac, self.nodo_anterior, self.nodo_actual))
        msg = "{} se ha movido de {} a {}".format(self.mac, self.nodo_anterior, self.nodo_actual)
        #try:
        msg_dict = {
            'message': msg,
            'sql_op': 1,
            'args': [self.nodo_actual, self.mac]
        }
        client.publish("Actividades", json.dumps(msg_dict), qos=0)
            #cursor.callproc('registrar_recorrido', [self.nodo_actual, self.mac])
            #conn.commit()
        #except psycopg2.errors.InFailedSqlTransaction as e:
            #pass
        
    
    def comprar(self, id_tienda, monto):
        try:
            cursor.callproc('compra', [self.ci, self.nombre, id_tienda, monto, self.mac])
            conn.commit()
        except psycopg2.errors.RaiseException as e:
            print('Se ha tratado de comprar con una MAC que no está en el centro comercial')
        
        print("{} ha comprado por un monto de {} en la tienda {}".format(self.mac, monto, id_tienda))

    def tienda(self, id_tienda):
        msg = None
        #try:
            #cursor.callproc('registrar_tienda', [id_tienda, not self.io_tienda, self.mac])
            #conn.commit()
        #except psycopg2.errors.NotNullViolation as e:
            #print("ERROR DE MAC: {} EN TIENDA: {}".format(self.mac, self.tienda_actual))
        self.io_tienda = not self.io_tienda
        if(self.io_tienda == False):
            self.tienda_actual = None
            #print("{} ha salido de la tienda {}".format(self.mac, id_tienda))
            msg = "{} ha salido de la tienda {}".format(self.mac, id_tienda)
        else:
            #print("{} ha entrado a la tienda {}".format(self.mac, id_tienda))
            msg = "{} ha entrado a la tienda {}".format(self.mac, id_tienda)
        
        msg_dict = {
            'message': msg,
            'sql_op': 2,
            'args': [id_tienda, not self.io_tienda, self.mac]
        }
        client.publish("Actividades", json.dumps(msg_dict), qos=1)
    
    def mesa(self, id_mesa):
        msg = None
        #cursor.callproc('registrar_mesa', [id_mesa, not self.io_mesa, self.mac])
        #conn.commit()
        self.io_mesa = not self.io_mesa
        if(self.io_mesa == False):
            self.mesa_actual = None
            #print("{} se ha parado de la mesa {}".format(self.mac, id_mesa))
            msg = "{} se ha parado de la mesa {}".format(self.mac, id_mesa)
        else:
            #print("{} se ha sentado en la mesa {}".format(self.mac, id_mesa))
            msg = "{} se ha sentado en la mesa {}".format(self.mac, id_mesa)

        msg_dict = {
            'message': msg,
            'sql_op': 3,
            'args': [id_mesa, not self.io_mesa, self.mac]
        }
        client.publish("Actividades", json.dumps(msg_dict), qos = 2)


    def sexo_contrario(self):
        if(self.sexo == "M"):
            return "F"

        return "M"

personas_data = personas_info.payload

personas = []

for info in personas_data:
    personas.append(Persona(info["nombre"], info["cedula"], info["edad"], info["sexo"], info["mac"]))

def simular(iteraciones):
    for i in range(1, iteraciones):
        for persona in personas:
            persona.update()
        input("Siguiente iteracion: ")
        print("------------------------ITERACION {}------------------------".format(i))

simular(10)

""" count = 0
for i in range(1,100):
    if(IA_make_prediction(Persona("Marco", 123, 24, "M", "123"))["sexo"] == "F"):
        count += 1 """

    
