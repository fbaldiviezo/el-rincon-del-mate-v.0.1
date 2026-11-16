# Mapeo de Pantallas Frontend: Catálogo y Vista de Cliente
## El Rincón del Mate — Especificación para App Móvil Flutter

Este documento contiene el levantamiento completo, estructurado y detallado de todas las pantallas, componentes, flujos de navegación, reglas de negocio y modelos de datos del área pública y de clientes del frontend web (Angular), preparado como guía técnica para el desarrollo de la aplicación móvil en **Flutter**.

---

## 1. Resumen Ejecutivo y Tabla de Pantallas

| N° | Pantalla / Módulo | Ruta Web Original | Componente Angular | Rol y Equivalente en Flutter |
|---|---|---|---|---|
| **1** | **Inicio (Home)** | `/` | `HomeFeatureComponent` | Pantalla principal con carrusel, colecciones destacadas y beneficios |
| **2** | **Catálogo de Productos** | `/productos` | `ProductsFeatureComponent` | Explorador general de productos con buscador y selector de categorías |
| **3** | **Detalle de Producto** | `/productos/:slug` | `ProductDetailFeatureComponent` | Ficha técnica con carrusel de imágenes, selector de cantidad y compra |
| **4** | **Categorías (Colecciones)** | `/categorias` y `/categorias/:slug` | `CategoriesFeatureComponent` | Vista dual: directorio de categorías y vista filtrada por categoría |
| **5** | **Carrito de Compras** | `/carrito` | `CartFeatureComponent` | Gestión de artículos seleccionados, control de cantidades y total |
| **6** | **Checkout - Paso 1: Datos de Envío** | `/checkout` | `CheckoutDataFeatureComponent` | Formulario de datos personales, teléfono, departamento y dirección |
| **7** | **Checkout - Paso 2: Pago QR** | `/checkout/pago` | `CheckoutPaymentFeatureComponent` | Visualización del QR bancario, instrucciones y carga de comprobante |
| **8** | **Confirmación y Estado de Pedido** | `/pedido/:orderNumber` | `OrderDetailFeatureComponent` | Resumen de compra y sondeo reactivo en vivo del estado del pago |

---

## 2. Arquitectura de Navegación Recomendada para Flutter

En la web existe un layout global (`PublicLayoutComponent`) con una barra superior, navbar y menú móvil tipo drawer. Para una experiencia móvil nativa en Flutter, se recomienda la siguiente arquitectura:

### A. Navegación Principal (`BottomNavigationBar` o `NavigationBar`)
* **Tab 1: Inicio (`HomeScreen`)**
  * Icono: `Icons.home_outlined` / `Icons.home`
* **Tab 2: Catálogo (`CatalogScreen`)**
  * Icono: `Icons.local_cafe_outlined` / `Icons.local_cafe` (o icono de mate)
* **Tab 3: Categorías (`CategoriesScreen`)**
  * Icono: `Icons.category_outlined` / `Icons.category`
* **Tab 4: Carrito (`CartScreen`)**
  * Icono: `Icons.shopping_bag_outlined` / `Icons.shopping_bag`
  * **Badge reactivo:** Muestra el número total de unidades agregadas (`totalItems`).

### B. Rutas Modales / Flujo de Navegación en Stack (`Navigator.push` / `go_router`)
* **Detalle de Producto (`ProductDetailScreen`):** Se empuja sobre la pila al tocar cualquier producto.
* **Productos por Categoría (`CategoryProductsScreen`):** Al tocar una categoría en la pestaña de categorías o inicio.
* **Flujo de Checkout (Stepped Flow):**
  * Paso 1: `CheckoutAddressScreen`
  * Paso 2: `CheckoutPaymentQrScreen`
* **Comprobante y Seguimiento:**
  * `OrderTrackingScreen`: Acceso inmediato tras completar la compra o mediante consulta directa por código de orden.

---

## 3. Especificación Detallada Pantalla por Pantalla

---

### Pantalla 1: Inicio (`HomeScreen`)
* **Ruta original:** `/`
* **Archivo web de referencia:** `frontend/src/app/features/home/`

#### Propósito:
Fidelizar al usuario con la identidad visual artesanal de la marca, destacar promociones e impulsar la exploración del catálogo.

#### Componentes Visuales:
1. **Hero Banner Slider (Carrusel Artesanal):**
   * Desplazamiento automático cada **5 segundos**.
   * Diapositivas destacando modelos insignia:
     * *Mate Imperial Premium:* Calabaza brasilera con virola de alpaca cincelada.
     * *Mate Camionero Tradicional:* Cuero vacuno legítimo con costura reforzada a mano.
     * *Mate Torpedo Uruguayo:* Formato estilizado con base de cuatro patas de máxima estabilidad.
     * *Mate Imperial Guarda Especial:* Detalles ornamentales con acabado en plata y bronce.
   * Controles del carrusel: Indicadores de puntos (*dots*), contador (`01 / 04`) y botones táctiles de anterior/siguiente.
2. **Acciones Rápidas (CTA):**
   * Botón destacado: "Explorar Catálogo" (lleva a la pestaña de productos).
   * Botón secundario: "Ver Categorías" (lleva a la pestaña de categorías).
3. **Sección "Categorías Principales":**
   * Muestra las 3 categorías más importantes en tarjetas con imagen oficial, nombre, descripción y flecha de exploración.
4. **Sección "Productos Destacados" (Lo Más Vendido):**
   * Muestra hasta 4 productos destacados con:
     * Fotografía del producto centrada con caída de sombra.
     * Badge de precio en Bolivianos (`Bs. XX.XX`).
     * Tag de estado de inventario: "En Stock".
     * Categoría superior en mayúsculas pequeñas.
     * Título y descripción breve (máximo 2 líneas).
     * Botón rápido: **"Agregar"** (con feedback "¡Agregado!" durante 1.5s).
     * Botón para abrir el detalle completo.
5. **Sección de Confianza / Valor ("Por qué elegirnos"):**
   * *Envíos a toda Bolivia:* Embalaje protegido a los 9 departamentos.
   * *Pago seguro por QR:* Directo desde la app bancaria sin recargos.
   * *Garantía Artesanal:* Calabaza gruesa y cuero de curtido premium.

#### Endpoints / Datos requeridos:
* `GET /api/categories` (toma las primeras 3).
* `GET /api/products?activeOnly=true` (toma los primeros 4 ordenados por relevancia).

---

### Pantalla 2: Catálogo de Productos (`CatalogScreen`)
* **Ruta original:** `/productos`
* **Archivo web de referencia:** `frontend/src/app/features/products/products.component.ts`

#### Propósito:
Permitir la exploración completa de productos con búsqueda instantánea y filtros dinámicos.

#### Componentes Visuales:
1. **Cabecera del Catálogo:** Título ("Colección de Mates & Accesorios") y descripción.
2. **Barra de Búsqueda y Filtros:**
   * Campo de texto con icono de lupa para búsqueda por nombre o descripción.
   * Selector desplegable (`DropdownButton` / `BottomSheet`) con las categorías cargadas desde el backend ("Todas las Categorías" + categorías activas).
3. **Grilla de Productos:**
   * Cuadrícula de 2 columnas (ideal para smartphones) con tarjetas de producto.
   * Cada tarjeta incluye:
     * Imagen del producto.
     * Badge de precio (`Bs. XX.XX`).
     * Badge de stock: "En Stock" (verde) o "Agotado" (rojo).
     * Nombre y categoría.
     * Botón "Agregar al Carrito" (deshabilitado si `stock <= 0`).
     * Botón de vista a detalle.
4. **Manejo de Estados:**
   * *Cargando:* Skeletons o indicadores de progreso circulares.
   * *Sin Resultados:* Ilustración de caja vacía, mensaje "No se encontraron productos" y botón **"Restablecer Filtros"** para limpiar la búsqueda y la categoría seleccionada.

#### Endpoints / Datos requeridos:
* `GET /api/categories`
* `GET /api/products?search={texto}&categoryId={id}&activeOnly=true`

---

### Pantalla 3: Detalle del Producto (`ProductDetailScreen`)
* **Ruta original:** `/productos/:slug`
* **Archivo web de referencia:** `frontend/src/app/features/products/product-detail.component.ts`

#### Propósito:
Mostrar toda la información técnica y visual de un artículo específico para incentivar la conversión.

#### Componentes Visuales:
1. **Navegación / Barra Superior:** Título del producto o botón atrás con breadcrumb descriptivo.
2. **Galería Fotográfica:**
   * Imagen principal con proporción adecuada y soporte para múltiples ángulos.
   * Flechas o gestos swipe (izquierda/derecha) para cambiar de foto.
   * Badge de contador de imagen (`1 / N`).
   * Tira horizontal de miniaturas (*thumbnails*) en la parte inferior para seleccionar la foto deseada.
3. **Información y Ficha Técnica:**
   * Tag de Categoría.
   * Nombre del producto en gran tamaño.
   * Precio destacado en Bolivianos (`Bs.`).
   * Badge de disponibilidad: `Stock Disponible (X)` en verde o `Agotado` en rojo.
   * Descripción completa del producto (materiales, cuidados, características).
4. **Selector de Cantidad y Compra:**
   * Control con botones `+` y `-` para elegir la cantidad de unidades (validado entre `1` y el `stock` disponible).
   * Botón principal de compra: **"Agregar al Carrito de Compras"** (con feedback "¡Agregado al Carrito!" por 1.8 segundos). Si no hay stock disponible, el botón permanece deshabilitado.

#### Endpoints / Datos requeridos:
* `GET /api/products/{slug}`

---

### Pantalla 4: Directorio y Filtrado por Categorías (`CategoriesScreen`)
* **Ruta original:** `/categorias` y `/categorias/:slug`
* **Archivo web de referencia:** `frontend/src/app/features/categories/categories.component.ts`

#### Propósito:
Organizar el catálogo por familias de productos (ej. Mates Imperiales, Mates Camioneros, Termos, Bombillas, Yerba Mate).

#### Componentes Visuales:
1. **Vista General de Categorías:**
   * Cuadrícula o lista de tarjetas de categorías.
   * Cada tarjeta cuenta con: Imagen ilustrativa oficial de la colección, nombre, descripción y botón "Explorar categoría".
2. **Vista Filtrada por Categoría (al seleccionar una categoría):**
   * Encabezado con el nombre de la categoría, descripción y botón para "Ver Todas las Categorías".
   * Grilla con todos los productos pertenecientes a esa categoría.
   * Botón para agregar directamente al carrito en cada tarjeta de producto.
   * Estado de categoría vacía con mensaje "No hay productos en esta categoría".

#### Endpoints / Datos requeridos:
* `GET /api/categories` (para la lista completa).
* `GET /api/categories/{slug}` (para obtener los productos asociados a la categoría).

---

### Pantalla 5: Carrito de Compras (`CartScreen`)
* **Ruta original:** `/carrito`
* **Archivo web de referencia:** `frontend/src/app/features/cart/cart.component.ts`

#### Propósito:
Revisar el pedido actual, ajustar cantidades y calcular el monto final antes de iniciar el checkout.

#### Componentes Visuales:
1. **Lista de Artículos en el Carrito:**
   * Tarjeta para cada producto:
     * Imagen en miniatura.
     * Nombre y precio unitario (`Bs.`).
     * Control numérico interactivo de cantidad (`+` / `-`). Si la cantidad llega a 0, se remueve automáticamente.
     * Subtotal calculado por producto (`precio * cantidad`).
     * Botón de eliminación directa (icono de basurero).
2. **Card de Resumen de Compra:**
   * Cantidad total de items (`totalItems`).
   * Subtotal recalculado (`totalPrice`).
   * Costo de envío: Destacado como **"¡GRATIS!"** a toda Bolivia.
   * **Total a Pagar:** Importe final destacado en Bolivianos (`Bs. XX.XX`).
   * Botón de acción principal: **"Continuar con Datos de Envío"** (abre la pantalla de checkout).
3. **Estado de Carrito Vacío:**
   * Icono de bolsa de compras vacía, mensaje motivador y botón **"Explorar Catálogo"** para retornar a la tienda.

#### Persistencia:
* Debe almacenarse localmente (en Flutter con `SharedPreferences`, `Hive` o `Isar`) para que el usuario no pierda su carrito al cerrar la aplicación.

---

### Pantalla 6: Checkout - Paso 1: Datos del Cliente y Envío (`CheckoutAddressScreen`)
* **Ruta original:** `/checkout`
* **Archivo web de referencia:** `frontend/src/app/features/checkout/checkout.component.ts`

#### Propósito:
Registrar los datos de contacto y la dirección de entrega en Bolivia antes del pago.

#### Componentes Visuales:
1. **Indicador de Progreso (*Stepper*):**
   * Paso 1: *Datos del Cliente* (Estado: Activo).
   * Paso 2: *Pago QR y Comprobante* (Estado: Pendiente).
2. **Formulario Estructurado en 4 Secciones:**
   * **Sección 1: Información Personal**
     * `Nombre(s)` *(obligatorio)*
     * `Apellido Paterno` *(obligatorio)*
     * `Apellido Materno` *(opcional)*
   * **Sección 2: Contacto e Identificación**
     * `Correo Electrónico` *(obligatorio, validación sintáctica de email)*
     * `Teléfono / WhatsApp` *(obligatorio, restricción estricta a solo dígitos numéricos)*
     * `CI / NIT` *(opcional, solo dígitos numéricos)*
   * **Sección 3: Lugar de Entrega**
     * `Departamento` *(selector obligatorio con los 9 departamentos oficiales de Bolivia: Beni, Chuquisaca, Cochabamba, La Paz, Oruro, Pando, Potosí, Santa Cruz, Tarija)*
     * `Ciudad / Localidad` *(obligatorio, ej. Tarija, El Alto, Sacaba, etc.)*
     * `Dirección de Entrega` *(obligatorio: calle, número de puerta, barrio o referencia)*
   * **Sección 4: Indicaciones Adicionales**
     * `Notas Especiales` *(opcional, campo multilínea para instrucciones de entrega)*
3. **Acciones y Navegación:**
   * Botón "Volver al Carrito".
   * Botón **"Continuar al Pago por QR"**: Solo se habilita cuando todos los campos requeridos han sido completados válidamente. Al presionar, guarda temporalmente los datos y navega al Paso 2.

---

### Pantalla 7: Checkout - Paso 2: Pago por QR y Subida de Comprobante (`CheckoutPaymentQrScreen`)
* **Ruta original:** `/checkout/pago`
* **Archivo web de referencia:** `frontend/src/app/features/checkout/checkout-payment.component.ts`

#### Propósito:
Facilitar el pago inmediato mostrando el código QR bancario del propietario de la tienda y recolectar la foto o captura del comprobante bancario (requisito obligatorio para crear el pedido).

#### Componentes Visuales:
1. **Indicador de Progreso (*Stepper*):**
   * Paso 1: *Datos del Cliente* (Completado con marca de verificación ✓).
   * Paso 2: *Pago QR y Comprobante* (Estado: Activo).
2. **Monto Total a Transferir:**
   * Presentación destacada del valor total a pagar en Bolivianos (`Bs. XX.XX`).
3. **Visor de Código QR Bancario Oficial:**
   * Tarjeta con marco donde se renderiza la imagen del código QR bancario activo del dueño (obtenido mediante API).
   * Indicador visual: "QR Bancario Oficial del Dueño".
4. **Instrucciones de Pago (5 Pasos Claros):**
   1. Escanear el código QR con cualquier app bancaria de Bolivia (Simple, GanaMóvil, BCP, Banco Unión, etc.).
   2. Transferir el monto exacto mostrado.
   3. Capturar o descargar el comprobante bancario.
   4. Adjuntar la foto del comprobante en la app.
   5. Presionar el botón "Enviar Pedido".
5. **Selector de Comprobante de Pago (Obligatorio):**
   * Botón para **Tomar Foto con Cámara** o **Seleccionar de Galería** (formatos permitidos: PNG, JPG, JPEG, WEBP; límite máximo de 5 MB).
   * Vista previa de la imagen cargada con:
     * Miniatura de la imagen.
     * Nombre del archivo y peso en MB.
     * Indicador de confirmación: "Comprobante adjuntado listo".
     * Botón para cambiar imagen o eliminarla.
6. **Manejo de Errores y Envío:**
   * Banner de alerta en caso de fallos de red o comprobante faltante.
   * Botón "Volver a Datos".
   * Botón principal: **"Enviar Pedido"** (con spinner de carga mientras se sube).
   * Al finalizar con éxito: Limpia el carrito local y redirige a la pantalla de confirmación.

#### Endpoints / Datos requeridos:
* `GET /api/payment-qr/active` (obtiene la imagen del QR bancario).
* `POST /api/orders` (petición `multipart/form-data` con los campos del cliente, el array JSON de items `[{ productId, quantity }]` y el archivo del comprobante `paymentProof`).

---

### Pantalla 8: Confirmación y Seguimiento del Pedido (`OrderTrackingScreen`)
* **Ruta original:** `/pedido/:orderNumber`
* **Archivo web de referencia:** `frontend/src/app/features/orders/order-detail.component.ts`

#### Propósito:
Servir de recibo digital al cliente y proporcionar actualización en tiempo real del estado de verificación de su pago.

#### Componentes Visuales:
1. **Cabecera del Pedido:**
   * Número identificador del pedido (`#PED-XXXXXX`).
   * Fecha y hora exacta de registro.
2. **Insignia del Estado del Pago (`paymentStatus`):**
   * `PENDING_VERIFICATION`: Badge ámbar con texto *"Pendiente de verificación"* y pulso animado *"En vivo"*.
   * `APPROVED`: Badge verde con texto *"Pagado y Verificado"*.
   * `REJECTED`: Badge rojo con texto *"Pago Rechazado"*.
   * Botón manual de actualización (icono de recarga con rotación animada).
3. **Banners Informativos Dinámicos:**
   * *Si está en revisión:* "Tu comprobante de pago fue recibido y está siendo verificado por el equipo administrativo. Esta pantalla se actualizará automáticamente."
   * *Si fue rechazado:* Muestra el motivo exacto de rechazo configurado por el administrador (ej. *"El monto no coincide"* o *"Comprobante ilegible"*).
4. **Sondeo en Tiempo Real (Live Polling):**
   * En Angular realiza un sondeo cada **4 segundos** mediante `interval` mientras el estado sea `PENDING_VERIFICATION`.
   * En Flutter: Puede implementarse con un `Timer.periodic(const Duration(seconds: 4), ...)` o WebSockets, cancelándose automáticamente en cuanto el estado cambie a `APPROVED` o `REJECTED`.
5. **Detalle de Productos Adquiridos:**
   * Lista de productos con nombre, cantidad, precio unitario y subtotal.
6. **Desglose Económico:**
   * Subtotal de la orden.
   * Total general en Bolivianos (`Bs. XX.XX`).
7. **Navegación:**
   * Botón para "Volver al Inicio" de la tienda.

#### Endpoints / Datos requeridos:
* `GET /api/orders/{orderNumber}`

---

## 4. Contactos y Sucursales Transversales

En la aplicación móvil es recomendable incluir un botón flotante de WhatsApp o una sección de contacto con las sucursales oficiales de la tienda:
* **Sucursal Tarija:** Enlace directo de WhatsApp al número `+591 69891494`.
* **Sucursal La Paz:** Enlace directo de WhatsApp al número `+591 64014507`.
* **Redes Oficiales:**
  * TikTok: `@rincon_delmate_tarija`
  * Instagram: `@rincon_delmate_bolivia`

---

## 5. Modelos de Datos Relevantes (TypeScript a Dart)

### Modelo de Producto (`Product`)
```dart
class Product {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final List<String> images;
  final bool active;
  final Category? category;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.images = const [],
    required this.active,
    this.category,
  });
}
```

### Modelo de Categoría (`Category`)
```dart
class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
  });
}
```

### Modelo de Ítem de Carrito (`CartItem`)
```dart
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}
```

### Modelo de Pedido (`Order`)
```dart
class Order {
  final String id;
  final String orderNumber;
  final double subtotal;
  final double total;
  final String status;
  final String paymentStatus; // 'PENDING_VERIFICATION' | 'APPROVED' | 'REJECTED'
  final String address;
  final String city;
  final String phone;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;
  final Payment? payment;

  Order({
    required this.id,
    required this.orderNumber,
    required this.subtotal,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.address,
    required this.city,
    required this.phone,
    this.notes,
    required this.createdAt,
    required this.items,
    this.payment,
  });
}
```
