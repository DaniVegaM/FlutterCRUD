# 🛠️ **CRUD con Flutter y Django Rest Framework**

---

## 📌 **Descripción del Proyecto**

Este es un proyecto completo que implementa un sistema CRUD (Crear, Leer, Actualizar, Eliminar) con autenticación JWT, desarrollado con:
- **Backend:** Django Rest Framework (DRF)  
- **Frontend:** Flutter  

### ✅ **Características:**
- Autenticación con JWT para usuarios administradores y normales.  
- Sistema de registro con carga de imagen de perfil almacenada localmente.  
- Pantalla de administración donde el admin puede ver, editar y eliminar usuarios.  
- Pantalla de perfil para usuarios normales, con la posibilidad de modificar su información.  
- Almacenamiento local de imágenes en Flutter para optimizar el manejo.  

---

## ⚙️ **Estructura del Proyecto**

/API                  # Backend (Django Rest Framework)
├── api              # Lógica de la API, modelos, serializers, views, etc.
├── db.sqlite3       # Base de datos SQLite (local)
├── manage.py        # Comando para ejecutar el servidor
├── requirements.txt # Dependencias de Python
├── settings.py      # Configuración de DRF
└── urls.py          # Rutas del servidor

/crud_flutter          # Frontend (Flutter)
├── lib
│     ├── main.dart           # Entrada principal de Flutter
│     ├── screens             # Pantallas de la app
│     │       ├── login.dart  # Pantalla de inicio de sesión
│     │       ├── register.dart # Pantalla de registro
│     │       ├── profile.dart # Perfil del usuario
│     │       ├── admin.dart   # Pantalla del administrador
│     └── models               # Modelos de usuario
├── images                     # Carpeta para almacenar imágenes locales
├── pubspec.yaml               # Dependencias de Flutter
└── README.md                   # Este archivo

---

## 🚀 **Instalación y Ejecución**

### 🐍 **Backend (Django)**
1. **Instalar dependencias:**
   - Asegúrate de estar en la carpeta `/API`
   ```bash
   cd API
   python -m venv venv   # Crear entorno virtual
   source venv/bin/activate  # Activar entorno en Linux/Mac
   venv\Scripts\activate      # Activar entorno en Windows
   pip install -r requirements.txt

python manage.py makemigrations
python manage.py migrate

python manage.py createsuperuser

python manage.py runserver


cd crud_flutter
flutter pub get

