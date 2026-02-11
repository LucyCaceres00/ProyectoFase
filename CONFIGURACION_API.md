# 🔧 Configuración del API - Solución de Problemas de Conexión

## ❌ Problema: "No hay conexión a internet" en Android

Cuando estás desarrollando en Android y tu API está en `localhost`, obtienes este error porque **Android no puede acceder a `localhost` de tu computadora**.

## ✅ Soluciones según tu caso:

### 1️⃣ Emulador de Android

**Usa `10.0.2.2` en lugar de `localhost`**

Ya está configurado automáticamente en [api_config.dart](lib/servicios/api_config.dart). El código detecta si estás en Android y usa `10.0.2.2` automáticamente.

```dart
// En Android usa: http://10.0.2.2:5209/api/
// En otras plataformas usa: http://localhost:5209/api/
```

### 2️⃣ Dispositivo Físico Android

**Necesitas usar la IP local de tu computadora**

#### Paso 1: Obtener tu IP local

**En Windows:**
```bash
ipconfig
```
Busca en "Adaptador de LAN inalámbrica Wi-Fi" o "Adaptador de Ethernet":
```
IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

**En Mac/Linux:**
```bash
ifconfig
```
o
```bash
ip addr show
```

#### Paso 2: Actualizar la configuración

Edita [lib/servicios/api_config.dart](lib/servicios/api_config.dart):

```dart
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Reemplaza 192.168.1.100 con TU IP local
      return 'http://192.168.1.100:5209/api/';
    }
    return 'http://localhost:5209/api/';
  }
  // ... resto del código
}
```

#### Paso 3: Verificar que tu API esté escuchando en todas las interfaces

Tu servidor .NET debe estar configurado para escuchar en `0.0.0.0` o en tu IP local, no solo en `localhost`.

En tu `Program.cs` o `launchSettings.json`:

```json
{
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "http://0.0.0.0:5209",  // Escucha en todas las interfaces
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

O en el código:

```csharp
builder.WebHost.UseUrls("http://0.0.0.0:5209");
```

#### Paso 4: Asegúrate de que ambos dispositivos estén en la misma red

- Tu computadora y tu celular deben estar conectados a la misma red WiFi
- Desactiva el firewall temporalmente o permite conexiones en el puerto 5209

### 3️⃣ iOS Simulator / Web / Desktop

Usa `localhost` normalmente. Ya está configurado automáticamente.

---

## 🔍 Verificar que el API esté funcionando

### 1. Desde tu navegador

Abre: `http://localhost:5209/api/Usuario/registrarUsuario`

Deberías ver una respuesta del servidor (aunque sea un error de método no permitido, eso significa que está funcionando).

### 2. Desde Postman o cualquier cliente HTTP

Haz una petición POST:

```http
POST http://localhost:5209/api/Usuario/registrarUsuario
Content-Type: application/json

{
  "Id": 0,
  "Nombre": "Prueba",
  "Contrasena": "test123",
  "Pais": "Perú",
  "Correo": "test@test.com",
  "Foto": "",
  "NivelExplorador": "",
  "TuriPuntos": 0,
  "Estado": "",
  "FechaCreacion": null
}
```

### 3. Desde tu dispositivo Android

Si estás usando `10.0.2.2` en el emulador, abre el navegador del emulador y ve a:
```
http://10.0.2.2:5209/api/
```

Si estás usando tu IP local en dispositivo físico:
```
http://192.168.1.100:5209/api/
```

---

## 🐛 Otros Problemas Comunes

### Error: "Connection refused" o "Failed to connect"

**Causas:**
- El servidor no está corriendo
- El servidor está corriendo en un puerto diferente
- El firewall está bloqueando la conexión
- CORS no está configurado en el API

**Solución:**
1. Verifica que tu servidor .NET esté corriendo
2. Verifica el puerto (debe ser 5209)
3. Configura CORS en tu API:

```csharp
// En Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Después de var app = builder.Build();
app.UseCors("AllowAll");
```

### Error: "Timeout"

**Causas:**
- El servidor tarda mucho en responder
- La conexión es muy lenta

**Solución:**
Aumenta el timeout en [api_config.dart](lib/servicios/api_config.dart):

```dart
static const Duration timeout = Duration(seconds: 60); // Aumentar a 60 segundos
```

### Error: "Certificate verification failed" (SSL)

**Causa:**
Estás usando `https` con un certificado autofirmado.

**Solución:**
Por ahora, usa `http` en desarrollo:
```dart
return 'http://10.0.2.2:5209/api/'; // http, no https
```

---

## 📱 Configuración Actual

Tu configuración actual en [api_config.dart](lib/servicios/api_config.dart) es:

- **Android**: `http://10.0.2.2:5209/api/`
- **Otras plataformas**: `http://localhost:5209/api/`

Si estás usando un **dispositivo físico Android**, necesitas cambiar a tu IP local.

---

## ✅ Checklist de Verificación

Antes de ejecutar la app, verifica:

- [ ] Tu servidor .NET está corriendo en el puerto 5209
- [ ] CORS está configurado en el API
- [ ] El firewall permite conexiones en el puerto 5209
- [ ] Si usas emulador Android, la URL es `http://10.0.2.2:5209/api/`
- [ ] Si usas dispositivo físico Android, la URL es `http://TU_IP_LOCAL:5209/api/`
- [ ] Ambos dispositivos están en la misma red (para dispositivo físico)
- [ ] El servidor está escuchando en `0.0.0.0` o en la IP local (para dispositivo físico)

---

## 🧪 Probar la Conexión

Para probar si la conexión funciona, puedes agregar este código temporal en tu pantalla de registro:

```dart
Future<void> _testConnection() async {
  try {
    final url = Uri.parse('http://10.0.2.2:5209/api/Usuario/registrarUsuario');
    print('Probando conexión a: $url');

    final response = await http.get(url).timeout(Duration(seconds: 5));

    print('Respuesta: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error de conexión: $e');
  }
}
```

Llama este método desde un botón y revisa los logs en la consola.

---

## 💡 Recomendación para Producción

En producción, tu API debería estar en un servidor con un dominio real:

```dart
static const String baseUrl = 'https://api.tuapp.com/api/';
```

Y configurar HTTPS correctamente con un certificado SSL válido.
