# 🔧 Solución de Errores del API - Guía Rápida

## ❌ Error: "Future not completed" o Timeout

Este error significa que tu app Flutter no puede conectarse al servidor .NET.

---

## 🚀 SOLUCIÓN RÁPIDA (Paso a Paso)

### ✅ Paso 1: Verifica que tu servidor .NET esté corriendo

Abre tu terminal/CMD y navega a tu proyecto de API .NET, luego:

```bash
dotnet run
```

Deberías ver algo como:
```
Now listening on: http://localhost:5209
Application started. Press Ctrl+C to shut down.
```

**Si no funciona:**
- Asegúrate de estar en la carpeta correcta de tu proyecto .NET
- Verifica que el puerto 5209 esté libre

---

### ✅ Paso 2: Verifica la URL en tu navegador

Abre tu navegador y ve a:
```
http://localhost:5209/api/
```

Deberías ver alguna respuesta del servidor (incluso si es un error 404, eso significa que el servidor está funcionando).

---

### ✅ Paso 3: Configura CORS en tu API .NET

Edita tu archivo `Program.cs` y agrega esto **ANTES** de `var app = builder.Build();`:

```csharp
// Agregar CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});
```

Y **DESPUÉS** de `var app = builder.Build();`:

```csharp
// Usar CORS
app.UseCors("AllowAll");
```

**Ejemplo completo:**

```csharp
var builder = WebApplication.CreateBuilder(args);

// Agregar servicios
builder.Services.AddControllers();

// ⭐ AGREGAR CORS AQUÍ
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// ⭐ USAR CORS AQUÍ (ANTES de UseHttpsRedirection)
app.UseCors("AllowAll");

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

**Reinicia tu servidor después de hacer los cambios.**

---

### ✅ Paso 4: Configura el servidor para escuchar en todas las interfaces

En tu archivo `Program.cs`, agrega esta línea **ANTES** de `builder.Build()`:

```csharp
// Escuchar en todas las interfaces (no solo localhost)
builder.WebHost.UseUrls("http://0.0.0.0:5209");
```

O edita tu `launchSettings.json`:

```json
{
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "http://0.0.0.0:5209",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

---

### ✅ Paso 5: Verifica la configuración en Flutter

#### Para Emulador de Android:

El archivo [lib/servicios/api_config.dart](lib/servicios/api_config.dart) ya está configurado para usar `http://10.0.2.2:5209/api/`

**Verifica que esté así:**

```dart
if (Platform.isAndroid) {
  return 'http://10.0.2.2:5209/api/';
}
```

#### Para Dispositivo Físico Android:

1. **Obtén tu IP local:**

   ```bash
   # En Windows:
   ipconfig

   # En Mac/Linux:
   ifconfig
   ```

   Busca algo como: `192.168.1.100` o `192.168.0.100`

2. **Actualiza la configuración:**

   Edita [lib/servicios/api_config.dart](lib/servicios/api_config.dart):

   ```dart
   if (Platform.isAndroid) {
     return 'http://192.168.1.100:5209/api/';  // TU IP AQUÍ
   }
   ```

3. **Asegúrate de que ambos estén en la misma WiFi**

---

### ✅ Paso 6: Desactiva el Firewall temporalmente

**Windows:**
1. Presiona `Win + R`
2. Escribe `firewall.cpl` y Enter
3. Click en "Desactivar Firewall de Windows" (solo para probar)

O agrega una excepción para el puerto 5209.

---

### ✅ Paso 7: Limpia y reconstruye la app Flutter

```bash
flutter clean
flutter pub get
flutter run
```

---

### ✅ Paso 8: Verifica los logs

Cuando ejecutes la app, revisa la consola de Flutter. Deberías ver:

```
🌐 POST Request:
   URL: http://10.0.2.2:5209/api/Usuario/registrarUsuario
   Headers: {Content-Type: application/json, Accept: application/json}
   Body: {...}
```

Si ves esto, la petición se está enviando correctamente.

---

## 🧪 Probar la Conexión Manualmente

Puedes usar el archivo de prueba que creé. Agrega este botón temporalmente en tu pantalla de registro:

```dart
// Al inicio de la clase
import '../../servicios/test_connection.dart';

// Dentro del build, agrega un botón:
ElevatedButton(
  onPressed: () async {
    final result = await TestConnection.testServerConnection();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  },
  child: Text('Probar Conexión'),
),
```

---

## 📊 Verificar con Postman

Antes de probar desde Flutter, verifica que tu API funcione con Postman:

1. Abre Postman
2. Crea una petición POST
3. URL: `http://localhost:5209/api/Usuario/registrarUsuario`
4. Headers: `Content-Type: application/json`
5. Body (raw JSON):

```json
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

6. Click en "Send"

Si funciona en Postman, entonces el problema es de configuración de red entre Flutter y el servidor.

---

## 🔍 Checklist Final

Antes de intentar de nuevo, verifica:

- [ ] Servidor .NET corriendo en puerto 5209
- [ ] CORS configurado en el servidor
- [ ] Servidor escuchando en `0.0.0.0` (no solo `localhost`)
- [ ] Firewall permite conexiones en puerto 5209
- [ ] URL correcta en Flutter:
  - Emulador Android: `http://10.0.2.2:5209/api/`
  - Dispositivo físico: `http://TU_IP_LOCAL:5209/api/`
  - Desktop/Web: `http://localhost:5209/api/`
- [ ] Ambos dispositivos en la misma WiFi (para dispositivo físico)
- [ ] `android:usesCleartextTraffic="true"` en AndroidManifest.xml
- [ ] App Flutter limpia y reconstruida

---

## 💡 Soluciones Alternativas

### Si nada funciona con el emulador:

**Opción 1: Usa un dispositivo físico**
- Conecta tu celular por USB
- Activa "Depuración USB"
- Usa tu IP local en lugar de `10.0.2.2`

**Opción 2: Usa ngrok**
```bash
ngrok http 5209
```
Esto te dará una URL pública como `https://abc123.ngrok.io` que puedes usar en Flutter.

**Opción 3: Prueba en Windows/Web**
```bash
flutter run -d windows
# o
flutter run -d chrome
```
En estos casos, `localhost` funcionará directamente.

---

## 📞 ¿Aún no funciona?

Revisa estos puntos:

1. **Puerto incorrecto**: Verifica que tu servidor use 5209
2. **Antivirus bloqueando**: Desactiva temporalmente el antivirus
3. **VPN activa**: Desactiva la VPN si tienes una
4. **Proxy configurado**: Verifica la configuración de proxy de tu red
5. **Versión de .NET**: Asegúrate de tener .NET 6+ instalado

---

## 📸 Logs esperados cuando funciona:

```
🌐 POST Request:
   URL: http://10.0.2.2:5209/api/Usuario/registrarUsuario
   Headers: {Content-Type: application/json, Accept: application/json}
   Body: {"Id":0,"Nombre":"Lucy","Contrasena":"***","Pais":"Perú"...}
✅ Response: 200
   Body: {"statusCode":200,"message":"Usuario registrado exitosamente"...}
```

Si ves esto, todo está funcionando correctamente.
