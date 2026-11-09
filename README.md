# Plugger 🌐

Prototipo inicial de una red social con feed unificado, desarrollado en Flutter.

## Incluye
- Feed con tarjetas de publicaciones de demostración y filtros por origen.
- Creación de publicaciones locales (solo en memoria).
- Botón de Me gusta local.
- Pestañas Inicio, Explorar, Avisos, Mensajes y Perfil.
- Perfil, mensajes y contactos con almacenamiento local.
- Pantallas preparadas para futuras integraciones.

> **Estado:** prototipo visual. La autenticación, el servidor y la conexión con plataformas externas están pendientes. Las publicaciones de YouTube y X son ejemplos ficticios.

## Arquitectura modular de Zaskar

| Ruta | Responsabilidad |
| --- | --- |
| `lib/main.dart` | Punto de entrada de Flutter. |
| `lib/app/` | Ensamblaje de la aplicación y navegación principal. |
| `lib/features/feed/` | Publicaciones, filtros y editor de publicaciones. |
| `lib/features/explore/` y `lib/features/notifications/` | Explorar y Avisos. |
| `lib/features/messages/` | Chats, contactos, conversación y almacenamiento local. |
| `lib/features/profile/` | Perfil, edición, apariencia y almacenamiento local. |
| `lib/shared/` | Paleta y componentes reutilizados entre módulos. |
| `assets/` | Recursos agrupados por función. |
| `test/app/` | Pruebas de navegación y flujos entre módulos. |
| `.github/` | Compilación, verificación de firma y publicación Android. |

Cada función mantiene sus pantallas, modelos y almacenamiento en su módulo
cuando los necesita. La capa `app` conecta los módulos mediante sus pantallas
públicas y callbacks. Los archivos `part` agrupan piezas internas de una misma
función sin exponer sus tipos privados a otras funciones.

## Ejecutar

Requiere [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.

```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

El comando `flutter create` genera los archivos de plataforma que todavía no están incluidos en el repositorio. Para iOS se necesita macOS con Xcode.

## Próximos pasos
Diseñar autenticación, persistencia, API de contenido y conexiones autorizadas con servicios externos.

## Firma fija de los APK

Configura la firma una sola vez. Android reconoce las actualizaciones por el
ID de aplicación y el certificado. Para cada nueva publicación, incrementa
el número después de `+` en `pubspec.yaml`.

Genera la clave en una carpeta privada fuera del repositorio, con Java instalado:

```bash
umask 077
keytool -genkeypair -storetype PKCS12 -keystore plugger-android.p12 \
  -alias plugger -keyalg RSA -keysize 3072 -validity 10000 -dname "CN=Plugger"
keytool -list -v -storetype PKCS12 -keystore plugger-android.p12 -alias plugger
```

En GitHub, abre **Settings → Secrets and variables → Actions**:

- En **Secrets**, crea `PLUGGER_ANDROID_KEYSTORE_BASE64` con la salida de
  `base64 -w 0 plugger-android.p12` (Linux) y
  `PLUGGER_ANDROID_KEYSTORE_PASSWORD` con la contraseña elegida.
- En **Variables**, crea `PLUGGER_ANDROID_CERT_SHA256` con el SHA-256 del
  certificado que muestra `keytool -list -v`.

Conserva una copia privada del archivo y la contraseña. Después de configurar
los valores, ejecuta **Build Android APK and publish preview release** en
**Actions → Run workflow**, sobre `main`. El workflow verifica el certificado
y publica el APK firmado en Releases.
