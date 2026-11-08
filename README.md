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
