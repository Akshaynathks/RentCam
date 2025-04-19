import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/authentication/view/auth_page.dart';
import 'package:rent_cam/features/authentication/view/forgot_password.dart';
import 'package:rent_cam/features/authentication/view/login.dart';
import 'package:rent_cam/features/authentication/view/signup.dart';
import 'package:rent_cam/features/home/bloc/cart_bloc/cart_bloc.dart';
import 'package:rent_cam/features/home/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/home/bloc/product_details/product_detail_bloc.dart';
import 'package:rent_cam/features/home/bloc/profile_photo/profile_image_bloc.dart';
import 'package:rent_cam/features/home/bloc/user_details/user_details_bloc.dart';
import 'package:rent_cam/features/home/services/cart_service.dart';
import 'package:rent_cam/features/home/services/product_detail_service.dart';
import 'package:rent_cam/features/home/services/product_service.dart';
import 'package:rent_cam/features/home/services/user_service.dart';
import 'package:rent_cam/features/home/view/add_studio.dart';
import 'package:rent_cam/features/home/view/all_brand.dart';
import 'package:rent_cam/features/home/view/all_categories.dart';
import 'package:rent_cam/features/home/view/cart.dart';
import 'package:rent_cam/features/home/view/main_home.dart';
import 'package:rent_cam/features/home/view/menu.dart';
import 'package:rent_cam/features/home/view/products.dart';
import 'package:rent_cam/features/home/view/studio.dart';
import 'package:rent_cam/features/home/view/wish_list.dart';
import 'package:rent_cam/features/splash/view/splash_screen.dart';
import 'package:rent_cam/features/splash/view/welcome.dart';
import 'package:rent_cam/firebase_options.dart';

void main() async {
  // ignore: deprecated_member_use
  CloudinaryContext.cloudinary =
      Cloudinary.fromCloudName(cloudName: "df9j5vwur");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileImageBloc()),
        BlocProvider(
          create: (context) => AuthBloc(authService: AuthService()),
        ),
        BlocProvider(
          create: (context) => UserDetailsBloc(userService: UserService()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(productService: ProductService())
            ..add(FetchProducts()),
        ),
        BlocProvider(
          create: (context) =>
              ProductDetailBloc(productDetailService: ProductDetailService()),
        ),
        BlocProvider(
          create: (context) => CartBloc(cartService: CartService()),
          child: Container(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const SplashPageWrapper(),
          '/auth': (context) => const MainAuthPage(),
          '/login': (context) => const LoginPageWrapper(),
          '/signup': (context) => const SignupPageWrapper(),
          '/forgotPassword': (context) => const ForgotPasswordPage(),
          '/home': (context) => const HomePageWrapper(),
          '/menu': (context) => const MenuPageWrapper(),
          '/welcome': (context) => const WelcomePage(),
          '/studio': (context) => const StudioPage(),
          '/products': (context) => const ProductsPage(),
          '/wishList': (context) => const WishlistPage(),
          '/cart': (context) => const CartPage(),
          '/all-categories': (context) => const AllCategoriesPage(),
          '/all-brands': (context) => const AllBrandsPage(),
          '/addStudio':(context)=>const AddStudio()
        },
        initialRoute: '/',
      ),
    );
  }
}
