# Plugger 🌐

Prototipo inicial de una red social con feed unificado, desarrollado en Flutter.

## Incluye
- Feed con tarjetas de publicaciones de demostración y filtros por origen.
- Creación de publicaciones locales (solo en memoria).
- Botón de Me gusta local.
- Pestañas Inicio, Explorar, Avisos y Perfil.
- Pantallas preparadas para futuras integraciones.

> **Estado:** prototipo visual. No existe autenticación, base de datos, persistencia ni conexión real con plataformas externas. Las publicaciones de YouTube y X son ejemplos ficticios.

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
