import time
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache
from flask_httpauth import HTTPBasicAuth
from sqlalchemy.orm import joinedload
from celery import Celery
from flask_cors import CORS
import mysql.connector
from datetime import date

app = Flask(__name__)
CORS(app)

# Configuración de base de datos
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/celactive_db'
app.config['SQLALCHEMY_ECHO'] = True
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

auth = HTTPBasicAuth()
cache = Cache(app, config={'CACHE_TYPE': 'SimpleCache', 'CACHE_DEFAULT_TIMEOUT': 300})
db = SQLAlchemy(app)

users = {"admin": "celactive123"}

@auth.verify_password
def verify_password(username, password):
    if username in users and users.get(username) == password:
        return username
    return None

def make_celery(app):
    celery = Celery(
        app.import_name,
        broker='sqla+sqlite:///celery_tasks.db',
        backend='db+sqlite:///celery_tasks.db'
    )
    celery.conf.update(app.config)
    return celery

celery = make_celery(app)

# Modelos
class Cliente(db.Model):
    __tablename__ = 'clientes'
    id_cliente = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    telefono = db.Column(db.String(20))
    correo = db.Column(db.String(100), unique=True, nullable=False)
    contraseña = db.Column(db.String(255), nullable=False)

class Servicio(db.Model):
    __tablename__ = 'servicios'
    id_servicio = db.Column(db.Integer, primary_key=True)
    nombre_servicio = db.Column(db.String(100), nullable=False)
    costo_base = db.Column(db.Numeric(10,2), nullable=False)
    tipo = db.Column(db.String(50), nullable=False)

class OrdenServicio(db.Model):
    __tablename__ = 'ordenes'
    id_orden = db.Column(db.Integer, primary_key=True)
    fecha = db.Column(db.Date, nullable=False, default=date.today)
    estado = db.Column(db.String(50), default='pendiente')
    descripcion = db.Column(db.String(255), nullable=False)
    costo = db.Column(db.Numeric(10,2), nullable=False)
    cliente_id = db.Column(db.Integer, db.ForeignKey('clientes.id_cliente'))
    servicio_id = db.Column(db.Integer, db.ForeignKey('servicios.id_servicio'))
    cliente = db.relationship('Cliente', backref='ordenes')
    servicio = db.relationship('Servicio', backref='ordenes')

# Tarea asíncrona
@celery.task(name='tarea_enviar_notificacion')
def tarea_enviar_notificacion(orden_id, email_cliente):
    time.sleep(10)
    return f"Notificación enviada para la orden {orden_id} a {email_cliente}"

# Conexión directa a MySQL para consultas personalizadas
conexion = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="celactive_db"
)

# RUTAS
@app.route('/servicios', methods=['GET'])
def obtener_servicios():
    servicios = Servicio.query.all()
    resultado = [{
        "id_servicio": s.id_servicio,
        "nombre_servicio": s.nombre_servicio,
        "costo_base": str(s.costo_base),
        "tipo": s.tipo
    } for s in servicios]
    return jsonify(resultado)

@app.route('/ordenes', methods=['GET'])
def obtener_ordenes():
    ordenes = OrdenServicio.query.options(joinedload(OrdenServicio.cliente), joinedload(OrdenServicio.servicio)).all()
    resultado = [{
        "id_orden": o.id_orden,
        "fecha": str(o.fecha),
        "estado": o.estado,
        "descripcion": o.descripcion,
        "costo": str(o.costo),
        "cliente": o.cliente.nombre if o.cliente else "Sin cliente",
        "servicio": o.servicio.nombre_servicio if o.servicio else "Sin servicio"
    } for o in ordenes]
    return jsonify(resultado)

@app.route('/historial/<int:id_cliente>', methods=['GET'])
def historial_cliente(id_cliente):
    cursor = conexion.cursor(dictionary=True)
    cursor.execute("""
        SELECT o.id_orden, s.nombre_servicio, o.estado, o.fecha, o.costo
        FROM ordenes o
        JOIN servicios s ON o.servicio_id = s.id_servicio
        WHERE o.cliente_id = %s
    """, (id_cliente,))
    resultado = cursor.fetchall()
    cursor.close()
    return jsonify(resultado)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return jsonify({'status': 'error', 'message': 'No se recibieron datos JSON'}), 400

    correo = data.get('correo')
    contraseña = data.get('contrasena') or data.get('contraseña')

    if not correo or not contraseña:
        return jsonify({'status': 'error', 'message': 'Faltan datos'}), 400

    cliente = Cliente.query.filter_by(correo=correo).first()
    if cliente and cliente.contraseña == contraseña:
        return jsonify({'status': 'ok', 'user': cliente.nombre, 'id_cliente': cliente.id_cliente})
    else:
        return jsonify({'status': 'error', 'message': 'Credenciales inválidas'}), 401

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, debug=True)
