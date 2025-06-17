from flask import request
from flask import Flask, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
from datetime import datetime
import win32com.client
import time
import pythoncom
import traceback


app = Flask(__name__)
CORS(app)

# Asignar valores a las variables para la conexion a la DB
app.config['MYSQL_HOST'] = "10.10.32.121"
app.config['MYSQL_USER'] = "root"
app.config['MYSQL_PASSWORD'] = "$F3rr0m3x18$"
app.config['MYSQL_DB'] = "tren_seguro"

mysql = MySQL(app)

# CONSULTA TRENES PENDIENTES

@app.route('/safe_train/train_pending', methods=['GET'])
def trainPending():
    try:
        trenId = request.args.get('Pending_Train_ID')

        if not trenId:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400

        consulta = mysql.connection.cursor()
        consulta.execute('SET @row_number = 0;')

        sql = '''
        SELECT 
            (@row_number:=@row_number + 1) AS row_num, 
            tp.*,
            pts.Validated_Train,
            pts.Validated_By,
            pts.Validated_Date,
            
            pts.Offered_Train,
            pts.Offered_By,
            pts.Offered_Date,
            
            pts.Authorized_Train,
            pts.Authorized_By,
            pts.Authorized_Date,

            pts.Called_Train,
            pts.Called_By,
            pts.Called_Date,

            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID
             AND 
                 LE_Status <> 'O') AS Total_Cars,
            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID 
             AND 
                 (LE_Status = 'E' OR LE_Status = 'W')) AS empty_cars,
            (SELECT COUNT(*) 
             FROM 
                 train_pending 
             WHERE 
                 Pending_Train_ID = tp.Pending_Train_ID 
             AND 
                 (LE_Status = 'L' OR LE_Status = 'LL' OR LE_Status = 'LE')) AS loaded_cars
        FROM 
            train_pending tp
        LEFT JOIN 
            permanent_train_status pts ON tp.Pending_Train_ID = pts.Pending_Train_ID
        WHERE 
            tp.Pending_Train_ID = %s
        ORDER BY 
            tp.Track_Train_Position DESC
        LIMIT 1;
        '''
        consulta.execute(sql, (trenId,))

        train_pending = consulta.fetchall()
        consulta.close()

        clave_train_pending = []
        for registro in train_pending:
            # Convertir las fechas a un formato legible y eliminar "GMT"
            fecha_validado = registro[30].strftime('%a, %d %b %Y\n%H:%M:%S') if registro[30] else ''
            fecha_ofrecido = registro[33].strftime('%a, %d %b %Y\n%H:%M:%S') if registro[33] else ''
            fecha_autorizado = registro[36].strftime('%a, %d %b %Y\n%H:%M:%S') if registro[36] else ''
            fecha_llamado = registro[39].strftime('%a, %d %b %Y\n %H:%M:%S') if registro[39] else ''

            clave_train_pending.append({
                'tren': registro[2] if registro[2] is not None else '',
                'origen': registro[10] if registro[10] is not None else '',
                'destino': registro[11] if registro[11] is not None else '',
                
                'fecha': registro[23] if registro[23] is not None else '',
                'carros': registro[40] if registro[40] is not None else 0,
                'cargados': registro[42] if registro[42] is not None else 0,
                'vacios': registro[41] if registro[41] is not None else 0,

                'validado': registro[28] if registro[28] is not None else '',
                'validado_por': registro[29] if registro[29] is not None else '',
                'fecha_validado': fecha_validado,

                'ofrecido': registro[31] if registro[31] is not None else '',
                'ofrecido_por': registro[32] if registro[32] is not None else '',
                'fecha_ofrecido': fecha_ofrecido,

                'autorizado': registro[34] if registro[34] is not None else '',
                'autorizado_por': registro[35] if registro[35] is not None else '',
                'fecha_autorizado': fecha_autorizado,

                'llamado': registro[37] if registro[37] is not None else '',
                'llamado_por': registro[38] if registro[38] is not None else '',
                'fecha_llamado': fecha_llamado,
            })

            print(f"Fecha validado ofrecido: '{fecha_validado}'")
        
        return jsonify({'data_train' : clave_train_pending})
    except Exception as e:
        print(f"Error: {str(e)}")
        print(traceback.format_exc())
        return jsonify({'error': str(e)}), 500


# CONSULTA PARA VALIDAR SI UN TREN ESTA VALIDADO
@app.route('/safe_train/check_train_validated', methods=['GET'])
def checkTrainValidate():
    try:
        train = request.args.get('Pending_Train_ID')

        if not train:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        
        consulta = mysql.connection.cursor()
        sql = '''
            SELECT Validated_Train
            FROM permanent_train_status 
            WHERE Pending_Train_ID = %s
        '''
        consulta.execute(sql, (train,))

        check_train = consulta.fetchone()
        consulta.close()

        if check_train:
            # Acceder al primer elemento de la tupla
            validated_train = check_train[0]
            if validated_train == 'OK':
                return jsonify({'status': 'already_validated', 'message': 'El tren ya está validado.'})
            else:
                return jsonify({'status': 'not_validated', 'message': 'El tren aún no está validado.'})
        else:
            return jsonify({'error': 'Train not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA VALIDAR SI UN TREN ESTA OFRECIDO
@app.route('/safe_train/check_train_offered', methods=['GET'])
def checkTrainOffered():

    try:
        train = request.args.get('Pending_Train_ID')

        if not train:
            return jsonify({'Error': 'Missing Pending_Train_ID parameter'}), 400
        
        consulta = mysql.connection.cursor()
        sql = '''
            SELECT Offered_Train
            FROM permanent_train_status
            WHERE Pending_Train_ID = %s
        '''

        # Pasar el parámetro como una tupla
        consulta.execute(sql, (train,))
        check_train = consulta.fetchone()
        consulta.close()

        if check_train:
            offered_train = check_train[0]
            if offered_train == 'OK':
                return jsonify({'status': 'already_offered', 'message': 'El tren ya está ofrecido.'})
            else:
                return jsonify({'status': 'not_offered', 'message': 'El tren aún no está ofrecido.'})
        else:
            return jsonify({'error': 'train not found'}), 404
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500



# CONSULTA INFORMACION DEL TREN
@app.route('/safe_train/info_train', methods=['GET'])
def infoTrain():
    try:
        trainPending = request.args.get('Pending_Train_ID')

        if not trainPending:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        # Consulta informacion de tren
        consulta = mysql.connection.cursor()
        sql = 'SELECT * FROM train_pending WHERE Pending_Train_ID = %s ORDER BY Track_Train_Position ASC'
        consulta.execute(sql, (trainPending,))
        #Obtener los resultados de la consulta
        info_train = consulta.fetchall()
        consulta.close()

        #Convertir los resultados en una lista 
        clave_info_train = [{'tren': registro[1] if registro[1] is not None else '',
                     'posicion': registro[5] if registro[5] is not None else 0,
                     'unidad': registro[3] if registro[3] is not None else '',
                     'estatus': registro[4] if registro[4] is not None else '',
                     'tipo_equipo': registro[6] if registro[6] is not None else '',
                     'articulados': registro[16] if registro[16] is not None else 0,
                     'lotearA': registro[17] if registro[17] is not None else '',
                     'producto': registro[18] if registro[18] is not None else '',
                     'peso': registro[14] if registro[14] is not None else 0,
                     'longitud': registro[13] if registro[13] is not None else 0}
                    for registro in info_train]

        # Devolver la lista de claves de info train como respuesta JSON
        return jsonify({'info_train' : clave_info_train})
    except Exception as e:
        return jsonify({'error: ' : str(e)}), 500
    

# CONSULTA INDICADORES DEL TREN
@app.route('/safe_train/indicator_train', methods=['GET'])
def indicatorTrain():
    try:
        trainPending = request.args.get('Pending_Train_ID')

        if not trainPending:
            return jsonify({'error': 'Missing Pending_Train_ID parameter'}), 400
        # Consulta informacion de tren
        consulta = mysql.connection.cursor()

        consulta.execute("SET @minTotalCars = 120;")
        consulta.execute("SET @minTotalWeight = 11000;")
        consulta.execute("SET @minTotalLength = 2200;")

        sql = '''
        SELECT
            (@row_number:=@row_number + 1) AS row_num, 
            tp.Pending_Train_Origin_Station AS Terminal,
            tp.Pending_Train_Origin_Station,
            tp.Pending_Train_Destination_Station,
            SUM(CASE WHEN tp.LE_Status = 'L' OR tp.LE_Status = 'LL' OR tp.LE_Status = 'LE' THEN 1 ELSE 0 END) AS Loaded_Cars,
            SUM(CASE WHEN tp.LE_Status = 'E' OR tp.LE_Status = 'W' THEN 1 ELSE 0 END) AS Empty_Cars,

            SUM(CASE WHEN tp.LE_Status <> 'O' THEN 1 ELSE 0 END) AS Total_Cars, 
            @minTotalCars AS Total_Min_Cars,
            (SUM(CASE WHEN tp.LE_Status <> 'O' THEN 1 ELSE 0 END) / @minTotalCars) * 100 AS Percentage_Cars,

            
            SUM(tp.Weight) AS Total_Weight, 
            @minTotalWeight AS Total_Min_Weight,
            (SUM(tp.Weight) / @minTotalWeight) * 100 AS Percentage_Weight,

            SUM(tp.`Length`) AS Total_Length,
            @minTotalLength AS Total_Min_Length,
            (SUM(tp.`Length`) / @minTotalLength) * 100 AS Percentage_Length,

            GROUP_CONCAT(
            IF(tp.Equipment_Kind = 'D', 
                CONCAT(REPLACE(tp.Track_Train_Position, ',', ''), REPLACE(tp.Equipment_Kind, ' ', ''), '/'),
                NULL
            )
            ORDER BY 
                tp.Track_Train_Position
            SEPARATOR ''
            ) AS Locomotora_Sequence


        FROM
            train_pending tp
        WHERE 
            tp.Pending_Train_ID = %s
        '''
        consulta.execute(sql, (trainPending,))
        #Obtener los resultados de la consulta
        indicator_train = consulta.fetchall()
        consulta.close()

        #Convertir los resultados en una lista 
        clave_indicator_train = [{'terminal': registro[1] if registro[1] is not None else '',
                     'origen': registro[2] if registro[2] is not None else '',
                     'destino': registro[3] if registro[3] is not None else '',
                     'cargados': registro[4] if registro[4] is not None else '',
                     'vacios': registro[5] if registro[5] is not None else '',

                     'totalcarros': registro[6] if registro[6] is not None else '',
                     'totalcarrosminimo': registro[7] if registro[7] is not None else '0',
                      'porcentajecarros': f"{int(round(registro[8]))} %" if registro[8] is not None else '0 %',

                     'totaltoneladas': registro[9] if registro[9] is not None else '',
                     'tonelajeminimo': registro[10] if registro[10] is not None else '',
                     'porcentajetoneladas': f"{int(round(registro[11]))} %" if registro[11] is not None else '0 %',
                     
                     'longitud': registro[12] if registro[12] is not None else '',
                     'longitudminima': registro[13] if registro[13] is not None else '',
                     'porcentajelongitud': f"{int(round(registro[14]))} %" if registro[14] is not None else '0 %',

                     'secuencialocomotoras': registro[15] if registro[15] is not None else '',
                     }
                    for registro in indicator_train]

        # Devolver la lista de claves de info train como respuesta JSON
        return jsonify({'indicator_train' : clave_indicator_train})
    except Exception as e:
        return jsonify({'error: ' : str(e)}), 500
    
    
# CONSULTA PARA INSERTAR LOS REGISTROS DE VALIDACION DEL TREN EN LA TABLA permanent_train_status
@app.route('/safe_train/insert_status_validated_train', methods = ['POST'])
def updateStatusValidated():
    try:
        data = request.get_json()

        Last_Station = data.get('Last_Station')

        Validated_Train = 'OK'
   
        Validated_By = data.get('Validated_By') 
    
        Validated_Date = data.get('Validated_Date')

        Pending_Train_ID = data.get('Pending_Train_ID')
        
        if not Pending_Train_ID:
            return jsonify({'Error: ': 'parametro de tren faltante'}), 400
        
        consulta = mysql.connection.cursor()

        sql = '''
        INSERT INTO permanent_train_status (
            Pending_Train_ID, Last_Station, Validated_Train, Validated_By, Validated_Date
        ) VALUES (%s,%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            Last_Station = VALUES(Last_Station),

            Validated_Train = VALUES(Validated_Train),
            
            Validated_By = VALUES(Validated_By),
            
            Validated_Date = VALUES(Validated_Date);
        '''

        consulta.execute(sql, (Pending_Train_ID, Last_Station, Validated_Train, Validated_By, Validated_Date))
        mysql.connection.commit()
        consulta.close()

        return jsonify({'message': 'registro exitoso/actualizacion completa'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA ACTUALIZAR LOS REGISTROS DE OFRECIMIENTO DEL TREN EN LA TABLA permanent_train_status
@app.route('/safe_train/update_offered_train', methods = ['POST'])
def updateStatusOffered():
    try:
        data = request.get_json()
        Offered_Train = 'OK'
        Offered_By = data.get('Offered_By')
        Offered_Date = data.get('Offered_Date')
        Pending_Train_ID = data.get('Pending_Train_ID')

        if not Pending_Train_ID:
            return jsonify({'Error: ': 'parametro de tren faltante'}), 400
        
        consulta = mysql.connection.cursor()

        
        #sql = '''
        #INSERT INTO permanent_train_status (
        #   Pending_Train_ID, Offered_Train, Offered_By, Offered_Date
        #) VALUES (%s, %s, %s, %s)
        #ON DUPLICATE KEY UPDATE
        #    Offered_Train = VALUES(Offered_Train),
        #    Offered_By = VALUES(Offered_By),
        #    Offered_Date = VALUES(Offered_Date);
        #'''
        sql = '''
        UPDATE permanent_train_status
        SET Offered_Train = %s, Offered_By = %s, Offered_Date = %s
        WHERE Pending_Train_ID = %s;
        '''


        consulta.execute(sql, (Offered_Train, Offered_By, Offered_Date, Pending_Train_ID))

        mysql.connection.commit()
        consulta.close()

        return jsonify({'message: ': 'actualizacion completa'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

    ##########################  CARROS TENDER  #############################
    
# CONSULTA PARA AGREGAR CARROS TENDER
@app.route('/safe_train/add_cars_tender', methods = ['POST'])
def addCarsTender():
    try:
        data = request.get_json()

        nameCar = data.get('name_car')
        description = data.get('description')
        createBy = data.get('created_by')
        recordDate = data.get('record_date')
        status = data.get('status', 1)


        if not nameCar or not description or not status:
            return jsonify({'Error ' : 'parametros faltantes'}), 400
        
        consulta = mysql.connection.cursor()

        sql = '''
        INSERT INTO carros_tender(
            name_car, description, created_by, record_date, status
        ) VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            status = VALUES(status)
        '''
        consulta.execute(sql, (nameCar, description, createBy, recordDate, status))
        mysql.connection.commit()
        consulta.close()

        return jsonify({'message' : 'registro exitoso/actualizacion completa'})
    except Exception as e:
        return jsonify({'Error' : str(e)}), 500
    
    
# CONSULTA PARA MOSTRAR LOS CARROS TENDER
@app.route('/safe_train/show_cars_tender', methods=['GET'])
def showCarsTender():
    try:
        consulta = mysql.connection.cursor()
        sql = """
        SELECT 
        carros_tender.id_car,
        carros_tender.name_car, 
        carros_tender.description, 
        cat_estatus_carros.descripcion_estatus 
        FROM 
        carros_tender 
        INNER JOIN 
        cat_estatus_carros ON 
        carros_tender.`status` = cat_estatus_carros.id_estatus   
        """
        consulta.execute(sql)

        # Obtener los resultados de la consulta
        showCar = consulta.fetchall()  # Corregido a fetchall()
        consulta.close()

        # Convertir los resultados en una lista
        clave_show_tender = [
            {
                'id': registro[0] if registro [0] is not None else 0,
                'carro': registro[1] if registro[1] is not None else '',
                'descripcion': registro[2] if registro[2] is not None else '',
                'estatus': registro[3] if registro[3] is not None else 0
            }
            for registro in showCar
        ]

        return jsonify({'show_cars': clave_show_tender})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    
# CONSULTA PARA ACTUALIZAR EL ESTATUS A INACTIVO DE CARRO TENDER
@app.route('/safe_train/update_toinactive_tender', methods=['POST'])
def updateCarTender():
    try:
        # Obtener los datos del cuerpo de la solicitud
        data = request.get_json()

        # Extraer el ID del carro y el nuevo estado
        id_car = data.get('id_car')
        new_status = data.get('status')
        update_by = data.get('update_by') 
        update_date = data.get('update_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S')) 

        if id_car is None or new_status is None or update_by is None:
            return jsonify({'error': 'id_car and status are required'}), 400

        # Crear el cursor para ejecutar la consulta
        cursor = mysql.connection.cursor()

        # Consulta UPDATE para modificar el registro
        sql = """
        UPDATE carros_tender
        SET status = %s,
            update_by = %s,
            update_date = %s
        WHERE id_car = %s
        """
        cursor.execute(sql, (new_status, update_by, update_date, id_car))

        # Confirmar los cambios en la base de datos
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'actualizacion exitosa'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA ACTUALIZAR EL ESTATUS A ACTIVO DE CARRO TENDER
@app.route('/safe_train/update_toactive_tender', methods=['POST'])
def updateCarActiveTender():
    try:
        # Obtener los datos del cuerpo de la solicitud
        data = request.get_json()

        # Extraer el ID del carro y el nuevo estado
        car_id = data.get('id_car')
        new_status = data.get('status')
        update_by = data.get('update_by') 
        update_date = data.get('update_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

        if car_id is None or new_status is None or update_by is None:
            return jsonify({'error': 'id_car and status are required'}), 400

        # Crear el cursor para ejecutar la consulta
        cursor = mysql.connection.cursor()

        # Consulta UPDATE para modificar el registro
        sql = """
        UPDATE carros_tender
        SET status = %s,
            update_by = %s,
            update_date = %s
        WHERE id_car = %s
        """
        cursor.execute(sql, (new_status, update_by, update_date, car_id))

        # Confirmar los cambios en la base de datos
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'actualizacion exitosa'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
    ##############################  CARROS ABIERTOS  ############################

# CONSULTA PARA AGREGAR CARROS ABIERTOS
@app.route('/safe_train/add_cars_open', methods = ['POST'])
def addCarsOpen():
    try:
        data = request.get_json()

        nameCar = data.get('name_car')
        description = data.get('description')
        createBy = data.get('created_by')
        recordDate = data.get('record_date')
        status = data.get('status', 1)


        if not nameCar or not description or not status:
            return jsonify({'Error ' : 'parametros faltantes'}), 400
        
        consulta = mysql.connection.cursor()

        sql = '''
        INSERT INTO carros_abiertos(
            name_car, description, created_by, record_date, status
        ) VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            status = VALUES(status)
        '''
        consulta.execute(sql, (nameCar, description, createBy, recordDate, status))
        mysql.connection.commit()
        consulta.close()

        return jsonify({'message' : 'registro exitoso/actualizacion completa'})
    except Exception as e:
        return jsonify({'Error' : str(e)}), 500
    

# CONSULTA PARA MOSTRAR LOS CARROS ABIERTOS
@app.route('/safe_train/show_cars_open', methods=['GET'])
def showCarsOpen():
    try:
        consulta = mysql.connection.cursor()
        sql = """
        SELECT 
        carros_abiertos.id_car,
        carros_abiertos.name_car, 
        carros_abiertos.description, 
        cat_estatus_carros.descripcion_estatus 
        FROM 
        carros_abiertos
        INNER JOIN 
        cat_estatus_carros ON 
        carros_abiertos.`status` = cat_estatus_carros.id_estatus   
        """
        consulta.execute(sql)

        # Obtener los resultados de la consulta
        showCar = consulta.fetchall()  # Corregido a fetchall()
        consulta.close()

        # Convertir los resultados en una lista
        clave_show_tender = [
            {
                'id': registro[0] if registro [0] is not None else 0,
                'carro': registro[1] if registro[1] is not None else '',
                'descripcion': registro[2] if registro[2] is not None else '',
                'estatus': registro[3] if registro[3] is not None else 0
            }
            for registro in showCar
        ]

        return jsonify({'show_cars': clave_show_tender})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA ACTUALIZAR EL ESTATUS A INACTIVO DE CARRO ABIERTO
@app.route('/safe_train/update_toinactive_open', methods=['POST'])
def updateCarOpen():
    try:
        # Obtener los datos del cuerpo de la solicitud
        data = request.get_json()

        # Extraer el ID del carro y el nuevo estado
        id_car = data.get('id_car')
        new_status = data.get('status')
        update_by = data.get('update_by') 
        update_date = data.get('update_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S')) 

        if id_car is None or new_status is None or update_by is None:
            return jsonify({'error': 'id_car and status are required'}), 400

        # Crear el cursor para ejecutar la consulta
        cursor = mysql.connection.cursor()

        # Consulta UPDATE para modificar el registro
        sql = """
        UPDATE carros_abiertos
        SET status = %s,
            update_by = %s,
            update_date = %s
        WHERE id_car = %s
        """
        cursor.execute(sql, (new_status, update_by, update_date, id_car))

        # Confirmar los cambios en la base de datos
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'actualizacion exitosa'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

# CONSULTA PARA ACTUALIZAR EL ESTATUS A ACTIVO DE CARRO ABIERTO
@app.route('/safe_train/update_toactive_open', methods=['POST'])
def updateCarActiveOpen():
    try:
        # Obtener los datos del cuerpo de la solicitud
        data = request.get_json()

        # Extraer el ID del carro y el nuevo estado
        car_id = data.get('id_car')
        new_status = data.get('status')
        update_by = data.get('update_by') 
        update_date = data.get('update_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

        if car_id is None or new_status is None or update_by is None:
            return jsonify({'error': 'id_car and status are required'}), 400

        # Crear el cursor para ejecutar la consulta
        cursor = mysql.connection.cursor()

        # Consulta UPDATE para modificar el registro
        sql = """
        UPDATE carros_abiertos
        SET status = %s,
            update_by = %s,
            update_date = %s
        WHERE id_car = %s
        """
        cursor.execute(sql, (new_status, update_by, update_date, car_id))

        # Confirmar los cambios en la base de datos
        mysql.connection.commit()
        cursor.close()

        return jsonify({'message': 'actualizacion exitosa'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


####################################  DISTRITOS  #######################################

# CONSULTA PARA VER LOS DISTRITOS Y LA DIVISION A LA QUE PERTENECEN
@app.route('/safe_train/show_districts', methods=['GET'])
def showDistricts():
    try:
        consulta = mysql.connection.cursor()
        sql = """
        SELECT 
            tdis.descripcion_distrito, 
            tdis.limite_pb, 
            tdiv.descripcion_division
        FROM 
            cat_distritos tdis
        INNER JOIN 
            cat_divisiones tdiv 
        ON
	        tdis.division = tdiv.id_division   
        """
        consulta.execute(sql)

        # Obtener los resultados de la consulta
        showDistricts = consulta.fetchall()  # Corregido a fetchall()
        consulta.close()

        # Convertir los resultados en una lista
        clave_show_district = [
            {
                'distrito': registro[0] if registro [0] is not None else '',
                'limite_pb': registro[1] if registro[1] is not None else 0,
                'division': registro[2] if registro[2] is not None else '',
                
            }
            for registro in showDistricts
        ]

        return jsonify({'show_districts': clave_show_district})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    



################################### LOGIN IN EXTRA ATTACHMENT ####################################

def login_to_extra(username, password):
    try:
        # Inicializa COM
        pythoncom.CoInitialize()
        
        # Crear el objeto System de Extra
        system = win32com.client.Dispatch("EXTRA.System")

        # Obtener la sesión activa
        session = system.ActiveSession

        # Obtener la pantalla del terminal
        screen = session.Screen

        # Ingresar credenciales
        screen.SendKeys(username)
        screen.SendKeys("<Tab>")
        time.sleep(1)  # Espera corta para asegurar que el cursor se mueva
        screen.SendKeys(password)
        screen.SendKeys("<Enter>")
        time.sleep(2)  # Espera para permitir el procesamiento del login

        screen.MoveTo(7,2)
        
        # Verificar la posición del cursor después de que la pantalla se actualiza
        if screen.Row == 7 and screen.Col == 2:
            screen.SendKeys("1")
            screen.SendKeys("<Enter>")
            #time.sleep(2)  # Espera adicional para procesar el comando

            screen.sendKeys("1")
            screen.SendKeys("<Enter>")
            #time.sleep(2)

            screen.sendKeys("1")
            screen.SendKeys("<Enter>")
            #time.sleep(2)

        # Verificar si la autenticación fue exitosa
        auth_success_text = screen.GetString(1, 1, 5)
        if "ERROR" not in auth_success_text:
            return True
        else:
            return False

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

@app.route('/safe_train/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if login_to_extra(username, password):
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "failure"}), 401


# DESCONECTAR LA SESION DE EXTRA
def disconnect_extra():
    try:
        # Inicializa COM
        pythoncom.CoInitialize()

        # Crear el objeto System de Extra
        system = win32com.client.Dispatch("EXTRA.System")

        # Obtener la sesión activa
        session = system.ActiveSession

        # Desconectar la sesión
        session.Close()

        print("Sesión desconectada exitosamente.")

    except Exception as e:
        print(f"Error al desconectar la sesión: {e}")


@app.route('/safe_train/disconnect', methods=['POST'])
def disconnect():
    disconnect_extra()
    return jsonify({"status": "disconnected"}), 200



if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)