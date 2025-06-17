import win32com.client
import time

def login_to_extra(username, password):
    try:
        # Crear el objeto System de Extra
        system = win32com.client.Dispatch("EXTRA.System")

        # Obtener la sesión activa
        session = system.ActiveSession

        # Obtener la pantalla del terminal
        screen = session.Screen

        # Ingresar credenciales
        screen.SendKeys("FXE9IVM")
        screen.SendKeys("<Tab>")  

        screen.SendKeys("TANQUE40")
        screen.SendKeys("<Enter>") 

        # Esperar un momento para permitir que el login procese
        time.sleep(5)

        # Verificar si la autenticación fue exitosa
        # Nota: Ajusta las coordenadas y el tamaño del string según tu aplicación
        auth_success_text = screen.GetString(1, 1, 5)
        if "ERROR" not in auth_success_text:
            print("Login Success")
            return 0
        else:
            print("Login Failed")
            return 1

    except Exception as e:
        print(f"An error occurred: {e}")
        return 1

if __name__ == "__main__":
    # Aquí puedes cambiar los valores de usuario y contraseña según sea necesario
    username = "FXE9IVM"
    password = "TANQUE40"
    result = login_to_extra(username, password)
    exit(result)
