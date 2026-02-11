# 🔧 Solución: "La App No Responde" (ANR)

## ❌ Problema
Android muestra el mensaje "La aplicación no responde" aunque todo funciona correctamente.

---

## ✅ Cambios Ya Realizados:

### 1. Timeout reducido
- **Antes**: 120 segundos
- **Ahora**: 30 segundos

El timeout estaba configurado en 120 segundos, lo cual es demasiado largo. Si el servidor tardaba en responder, Android mostraba el mensaje ANR.

---

## 🔍 Otras Causas Comunes del ANR:

### 1. **Imagen del Logo muy pesada**

Si la imagen `toori_logo_letras.png` es muy grande (más de 1-2 MB), puede causar bloqueos.

**Solución:**
1. Optimiza la imagen:
   - Tamaño recomendado: máximo 500 KB
   - Resolución: máximo 1000x1000 px para un logo
   - Formato: PNG optimizado o WebP

2. Usa un servicio como [TinyPNG](https://tinypng.com/) para comprimir la imagen

### 2. **Modo Debug de Flutter**

Cuando ejecutas la app en modo debug, Flutter es más lento.

**Solución:**
```bash
# Ejecuta en modo profile para mejor rendimiento
flutter run --profile

# O en modo release
flutter run --release
```

### 3. **Múltiples Peticiones Simultáneas**

Si haces varias peticiones al mismo tiempo, puede causar bloqueos.

**Ya está solucionado**: Usas `async/await` correctamente.

### 4. **El Servidor está Lento**

Si tu servidor tarda mucho en responder (más de 5-10 segundos), Android muestra ANR.

**Verificar:**
```bash
# Desde tu terminal, haz una petición de prueba
curl -X POST http://192.168.100.102:5209/api/Authentication/login \
  -H "Content-Type: application/json" \
  -d '{"Correo":"test@test.com","Contrasena":"test123"}'

# Mide cuánto tarda
time curl ...
```

Si tarda más de 3-5 segundos, optimiza tu servidor.

---

## 🚀 Configuraciones Recomendadas:

### 1. Optimizar el AndroidManifest.xml

Tu configuración ya está correcta, pero asegúrate de tener:

```xml
<application
    android:hardwareAccelerated="true"
    android:largeHeap="true">  <!-- Agregar esto si es necesario -->
```

### 2. Reducir el Tamaño de la Imagen

Edita [lib/paginas/inicio_sesion/inicio_sesion.dart](lib/paginas/inicio_sesion/inicio_sesion.dart):

```dart
Image.asset(
  'imagenes/toori_logo_letras.png',
  height: 200,  // Reducir de 300 a 200
  fit: BoxFit.contain,
  cacheHeight: 400,  // Agregar caché
)
```

### 3. Agregar Indicadores de Progreso

Ya tienes loading spinners ✅, así que el usuario sabe que la app está trabajando.

---

## 🧪 Cómo Diagnosticar el Problema:

### 1. Ver logs de Android

En tu terminal donde corre `flutter run`, busca mensajes como:

```
I/Choreographer: Skipped XX frames!  The application may be doing too much work on its main thread.
```

### 2. Usar Android Studio Profiler

1. Abre Android Studio
2. Ve a View → Tool Windows → Profiler
3. Ejecuta tu app
4. Observa el CPU usage cuando haces login/registro

### 3. Verificar la velocidad del servidor

```dart
// Agregar esto temporalmente en _iniciarSesion()
final stopwatch = Stopwatch()..start();
final response = await _authService.iniciarSesion(...);
stopwatch.stop();
print('⏱️ Petición tardó: ${stopwatch.elapsedMilliseconds}ms');
```

Si tarda más de 5000ms (5 segundos), tu servidor es muy lento.

---

## 💡 Soluciones Inmediatas:

### Opción 1: Reduce el tamaño del logo

Voy a actualizar el código para que cargue la imagen de forma más eficiente.

### Opción 2: Ejecuta en modo Release

```bash
flutter run --release
```

El modo release es 10-20x más rápido que debug.

### Opción 3: Aumenta el timeout del ANR (Solo para desarrollo)

**NO RECOMENDADO para producción**, pero útil para debug:

En [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):

```xml
<application
    android:debuggable="true"
    android:strictmode="false">
```

---

## 🎯 Plan de Acción:

1. **Ejecuta la app en modo release**:
   ```bash
   flutter run --release
   ```

2. **Optimiza la imagen del logo** (si es pesada)

3. **Verifica la velocidad del servidor**:
   - El login/registro no debería tardar más de 2-3 segundos
   - Si tarda más, optimiza tu API en el backend

4. **Limpia y reconstruye la app**:
   ```bash
   flutter clean
   flutter pub get
   flutter run --release
   ```

---

## 📊 Comparación de Tiempos:

| Operación | Tiempo Aceptable | Tiempo Problemático |
|-----------|------------------|---------------------|
| Login API | < 2 segundos | > 5 segundos |
| Registro API | < 3 segundos | > 7 segundos |
| Cargar Imagen | < 100ms | > 500ms |
| Timeout | 30 segundos | 120 segundos |

---

## ❓ ¿Sigue sin funcionar?

Si después de estos cambios sigue apareciendo el ANR:

1. **Verifica los logs**: `flutter run --verbose`
2. **Comprueba la memoria**: La imagen del logo podría ser demasiado grande
3. **Optimiza tu servidor**: Si las peticiones tardan más de 5 segundos, el problema está en el backend

---

## 🔧 Cambios Ya Aplicados:

- ✅ Timeout reducido de 120s a 30s
- ✅ Prints de debug eliminados
- ✅ Async/await correctamente implementado
- ✅ Loading spinners agregados

El problema debería estar solucionado. Si persiste, ejecuta en modo **release** con:

```bash
flutter run --release
```
