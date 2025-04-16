# LABHOUSE - TEST - FERNANDO LUCA DE TENA


1.- Para hacer funcionar la app solo hay que correr en el terminal la configuracion de Firebase una vez que se tenga acceso a el.  
2.- Seguir las instrucciones y dar enter a todo. Solo hay que configurar android.

## Comando:
- flutterfire configure -p labhouse-test -a com.rated.ai

## Funcionalidades:
- La app permite la creacion de cualquier ranking que se le solicite. No importa la categoria o el tipo.
- De forma inicial solicita al usuario que escoja 4 categorías para popular la app con algunos resultados.
  = En caso de que la generación de alguno de estos rankings falle, se cargan el resto y reporta el error a Crashlytics
- Se pueden marcar opciones de los rankings como favoritos

## Errores y mejoras conocidos:
- La autentificación ahora mismo solo es anonima, habría que acabar de conectar Google y Apple
- El icono del corazon no cambia al ponerlo como favorito, aunque si funciona
- Gemini no proporciona urls imagenes correctamente y a veces tiene fallos en la generacion de algunos textos. Esto se puede mejorar moviendo la generación a "Functions" y usando Genkit que esta más avanzado que la API de Flutter.