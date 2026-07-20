import time
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache
from flask_httpauth import HTTPBasicAuth
from sqlalchemy.orm import joinedload
from celery import Celery

app = Flask(__name__)
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
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)

class OrdenServicio(db.Model):
    __tablename__ = 'ordenes'
    id = db.Column(db.Integer, primary_key=True)
    descripcion = db.Column(db.String(255), nullable=False)
    cliente_id = db.Column(db.Integer, db.ForeignKey('clientes.id'))
    cliente = db.relationship('Cliente', backref='ordenes')

# Tarea asíncrona
@celery.task(name='tarea_enviar_notificacion')
def tarea_enviar_notificacion(orden_id, email_cliente):
    time.sleep(10)
    return f"Notificación enviada para la orden {orden_id} a {email_cliente}"

# RUTAS CORREGIDAS PARA EL VIDEO
@app.route('/servicios', methods=['GET'])
@auth.login_required
@cache.cached(timeout=300)
def obtener_servicios():
    # Usamos joinedload para evitar el problema N+1
    ordenes = OrdenServicio.query.options(joinedload(OrdenServicio.cliente)).all()
    resultado = [{
        "id": o.id,
        "descripcion": o.descripcion,
        "cliente": o.cliente.nombre if o.cliente else "Sin cliente"
    } for o in ordenes]
    return jsonify(resultado)

@app.route('/crear-servicio', methods=['POST'])
@auth.login_required
def crear_servicio():
    # Enviar tarea asíncrona
    celery.send_task('tarea_enviar_notificacion', args=[999, "cliente@ejemplo.com"])
    return jsonify({"mensaje": "Servicio creado y notificación en cola"}), 201

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)