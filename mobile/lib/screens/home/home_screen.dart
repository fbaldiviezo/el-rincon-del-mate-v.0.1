import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/cart_provider.dart';
import '../product_detail/product_detail_screen.dart';
import '../categories/category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _activeHeroIndex = 0;
  Timer? _heroTimer;

  // 4 Diapositivas de Mates Artesanales Oficiales
  final List<Map<String, String>> _heroSlides = [
    {
      'title': 'Mate Imperial Premium',
      'subtitle': 'Calabaza brasilera con virola de alpaca cincelada a mano',
      'badge': 'Artesanía Premium',
      'image': 'assets/producto_mate_16.svg',
    },
    {
      'title': 'Mate Camionero Tradicional',
      'subtitle': 'Cuero vacuno legítimo con costura reforzada a mano',
      'badge': 'Tradición Gaucha',
      'image': 'assets/producto_mate_18.svg',
    },
    {
      'title': 'Mate Torpedo Uruguayo',
      'subtitle': 'Formato estilizado con base de cuatro patas de máxima estabilidad',
      'badge': 'Diseño Clásico',
      'image': 'assets/producto_mate_27.svg',
    },
    {
      'title': 'Imperial Guarda Especial',
      'subtitle': 'Detalles ornamentales cincelados con acabado en plata y bronce',
      'badge': 'Edición Exclusiva',
      'image': 'assets/producto_mate_31.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startHeroAutoSlide();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startHeroAutoSlide() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final next = (_activeHeroIndex + 1) % _heroSlides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showSucursalesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sucursales y Atención',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppTheme.textMuted),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSucursalTile(
                city: 'Sucursal Tarija',
                phone: '+591 69891494',
                message: 'Hola El Rincón del Mate Tarija, quisiera consultar sobre sus productos.',
              ),
              const SizedBox(height: 12),
              _buildSucursalTile(
                city: 'Sucursal La Paz',
                phone: '+591 64014507',
                message: 'Hola El Rincón del Mate La Paz, quisiera consultar sobre sus productos.',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSucursalTile({
    required String city,
    required String phone,
    required String message,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.phone, color: AppTheme.success, size: 20),
        ),
        title: Text(
          city,
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textLight, fontSize: 14),
        ),
        subtitle: Text(
          phone,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(90, 48), // Regla UX 3
            backgroundColor: AppTheme.woodPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => Helpers.openWhatsApp(phone: phone, message: message),
          child: const Text('Contactar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = Provider.of<CatalogProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.coffee, color: AppTheme.woodLight, size: 20),
            SizedBox(width: 8),
            Text('EL RINCÓN DEL MATE'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phoneCall),
            tooltip: 'Sucursales WhatsApp',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Regla UX 3
            onPressed: () => _showSucursalesSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              color: AppTheme.woodPrimary,
              onRefresh: () => catalog.init(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HERO SLIDER BANNER (CARRUSEL)
                    _buildHeroBanner(),

                    const SizedBox(height: 24),

                    // 2. ACCIONES RÁPIDAS (CTA)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(LucideIcons.shoppingBag, size: 18),
                              label: const Text('Catálogo Completo'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48), // Regla UX 3
                              ),
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(1); // Ir a pestaña catálogo
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(LucideIcons.layers, size: 18),
                              label: const Text('Colecciones'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48), // Regla UX 3
                              ),
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(2); // Ir a pestaña categorías
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 3. CATEGORÍAS PRINCIPALES (TOP 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Colecciones Destacadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textLight,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                            onPressed: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(2);
                              }
                            },
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoriesHorizontal(catalog.categories),

                    const SizedBox(height: 28),

                    // 4. PRODUCTOS DESTACADOS ("LO MÁS VENDIDO")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Lo Más Vendido',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Mates artesanales con envío a toda Bolivia',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                            onPressed: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(1);
                              }
                            },
                            child: const Text('Ver más'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFeaturedProductsGrid(catalog.featuredProducts, cart),

                    const SizedBox(height: 28),

                    // 5. SECCIÓN DE BENEFICIOS Y CONFIANZA
                    _buildTrustSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _activeHeroIndex = idx),
            itemCount: _heroSlides.length,
            itemBuilder: (context, index) {
              final slide = _heroSlides[index];
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Textos a la izquierda
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.woodPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              slide['badge']!,
                              style: const TextStyle(
                                color: AppTheme.woodLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textLight,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Imagen a la derecha
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Image.network(
                          ApiConfig.resolveImageUrl(slide['image']),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(LucideIcons.package, size: 54, color: AppTheme.woodLight),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Puntos indicadores y contador inferior
          Positioned(
            bottom: 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(_heroSlides.length, (idx) {
                    final isActive = idx == _activeHeroIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.woodLight : AppTheme.surfaceBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                Text(
                  '0${_activeHeroIndex + 1} / 0${_heroSlides.length}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHorizontal(List<Category> categories) {
    if (categories.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: AppTheme.woodPrimary)));
    }

    final top3 = categories.take(3).toList();
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: top3.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = top3[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: cat)),
              );
            },
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.layers, size: 16, color: AppTheme.woodLight),
                      ),
                      const Icon(LucideIcons.arrowRight, size: 14, color: AppTheme.woodLight),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ver modelos',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductsGrid(List<Product> products, CartProvider cart) {
    if (products.isEmpty) {
      return const SizedBox(height: 140, child: Center(child: Text('Cargando destacados...', style: TextStyle(color: AppTheme.textMuted))));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isAvailable = product.stock > 0;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.network(
                            ApiConfig.resolveImageUrl(product.imageUrl),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(LucideIcons.package, color: AppTheme.woodLight, size: 36),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Helpers.formatCurrency(product.price),
                              style: const TextStyle(
                                color: AppTheme.woodLight,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 48, // Regla UX 3
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor: isAvailable ? AppTheme.woodPrimary : AppTheme.surface,
                                foregroundColor: isAvailable ? Colors.white : AppTheme.textMuted,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isAvailable
                                  ? () {
                                      cart.addItem(product);
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('"${product.name}" agregado al carrito'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isAvailable ? LucideIcons.shoppingBag : LucideIcons.x, size: 16),
                                  const SizedBox(width: 6),
                                  Text(isAvailable ? 'Agregar' : 'Sin Stock', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrustSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildTrustCard(
            icon: LucideIcons.truck,
            title: 'Envíos a toda Bolivia',
            description: 'Despachos protegidos a La Paz, Santa Cruz, Cochabamba, Tarija y todo el país.',
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            icon: LucideIcons.qrCode,
            title: 'Pago seguro por QR',
            description: 'Paga al instante escaneando el código QR desde tu app bancaria favorita.',
          ),
          const SizedBox(height: 12),
          _buildTrustCard(
            icon: LucideIcons.shieldCheck,
            title: 'Garantía Artesanal',
            description: 'Calabaza gruesa brasilera con virola de alpaca cincelada y cuero genuino.',
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.woodPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.woodLight, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
