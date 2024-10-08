// import 'package:animated_movies_app/constants/route_animation.dart';
// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:animated_movies_app/data/movies_data.dart';
// import 'package:animated_movies_app/screens/detail_screen/detail_screen.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/animated_stack.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/filters_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/header_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/movies_cover_widget.dart';
// import 'package:animated_movies_app/screens/home_screen/widgets/search_field_widget.dart';
// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:flutter/material.dart';

// class HomeContent extends StatefulWidget {
//   final LoginModelApi userData;
//   const HomeContent({super.key, required this.userData});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     return Container(
//       height: size.height,
//       width: size.width,
//       decoration: UiConstants.backgroundGradient,
//       child: SingleChildScrollView(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(
//                       top: size.height * 0.09,
//                       left: 24,
//                       right: 24,
//                     ),
//                     // child: HeaderWidget(size: size, userData: null,),
//                     child: HeaderWidget(
//                       size: size,
//                       userData: widget.userData,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: 28,
//                     ),
//                     child: SearchField(
//                       size: size,
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.only(top: 20),
//                     child: FiltersWidget(),
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 32, top: 14),
//                       child: RichText(
//                         text: const TextSpan(
//                           text: "Apache ",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24,
//                             color: Colors.white,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: "Teams",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 24,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: size.height * 0.4,
//                     padding: const EdgeInsets.all(38),
//                     child: AnimatedStackWidget(
//                       itemCount: MoviesData.movies.length,
//                       itemBuilder: (context, index) => GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(
//                             zoomNavigation(
//                               DetailScreen(
//                                 movieName: MoviesData.movies[index].name,
//                                 movieTypeAndEpisode: MoviesData
//                                     .movies[index].movieTypeAndEpisode,
//                                 plot: MoviesData.movies[index].plot,
//                                 movieImage: MoviesData.movies[index].coverImage,
//                                 rating: MoviesData.movies[index].rating,
//                               ),
//                             ),
//                           );
//                         },
//                         child: MagazineCoverImage(
//                             movies: MoviesData.movies[index]),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Positioned(
//             //   top: size.height * 0.04,
//             //   left: 16,
//             //   child: IconButton(
//             //     icon: Icon(Icons.arrow_back, color: Colors.white),
//             //     onPressed: () {
//             //       Navigator.pop(context);
//             //     },
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:animated_movies_app/constants/route_animation.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/data/movies_data.dart';
import 'package:animated_movies_app/screens/detail_screen/detail_screen.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/animated_stack.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/filters_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/header_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/movies_cover_widget.dart';
import 'package:animated_movies_app/screens/home_screen/widgets/search_field_widget.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeContent extends StatefulWidget {
  final LoginModelApi userData;

  const HomeContent({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // checkForUpdates(); // Call update check on initialization
  }


  Future<void> checkForUpdates() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    final url = Uri.parse(
        'http://10.3.0.70:9042/api/HR/check-update?appVersion=$currentVersion');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null &&
            data.containsKey('latestVersion') &&
            data.containsKey('apkFileData')) {
          String latestVersion = data['latestVersion'];
          String apkFileData =
              data['apkFileData']; // Base64 encoded APK file data

          if (currentVersion != latestVersion) {
            _showUpdateDialog(latestVersion, apkFileData);
          } else {
            // _showNoUpdateDialog();
          }
        } else {
          print(
              'Invalid response: latestVersion or apkFileData key not found.');
        }
      } else if (response.statusCode == 404) {
        // Handle the case when no update is available
        if (response.body == "No update available") {
          // _showNoUpdateDialog();
        } else {
          print('Unexpected response body: ${response.body}');
        }
      } else {
        print(
            'Failed to check for updates: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error while checking for updates: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _showUpdateDialog(String latestVersion, String apkFileData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text(
              "A new version ($latestVersion) is available. Please update the app."),
          actions: <Widget>[
            TextButton(
              child: Text("Later"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Update Now"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                try {
                  // Start downloading the APK file
                  await _downloadAndInstallApk(apkFileData);
                } catch (e) {
                  print('Failed to download or install APK: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _downloadAndInstallApk(String apkFileData) async {
    try {
      // Decode the base64 APK data and save to a local file
      final bytes = base64Decode(apkFileData);
      final directory =
          await getExternalStorageDirectory(); // Use external storage
      if (directory == null) {
        throw Exception("External storage directory is null");
      }
      final filePath = '${directory.path}/update.apk';
      final file = File(filePath);
      print('File Path: $filePath');

      await file.writeAsBytes(bytes);
      print('APK file written successfully.');

      // Install the APK using install_plugin
      final result = await InstallPlugin.installApk(filePath,
          appId: 'com.example.animated_movies_app');
      print('Install result: $result');

      // if (result == true) {
      //   // Assuming the result indicates success
      //   _showRestartDialog();
      // }
    } catch (e) {
      print('Failed to download or install APK: $e');
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Restart Required"),
          content: Text("The app needs to be restarted to apply the updates."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Restart the app (this could also be done by closing the app)
                SystemNavigator.pop(); // or use your method to restart the app
              },
            ),
          ],
        );
      },
    );
  }

  // void _showNoUpdateDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("No Update Available"),
  //         content: Text("Your app is up-to-date!"),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("OK"),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height,
      width: size.width,
      decoration: UiConstants.backgroundGradient,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            // _isLoading // Show loading indicator if loading
            //     ? Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     :
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.09,
                      left: 24,
                      right: 24,
                    ),
                    child: HeaderWidget(
                      size: size,
                      userData: widget.userData,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: SearchField(size: size),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FiltersWidget(userData: widget.userData),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32, top: 14),
                      child: RichText(
                        text: const TextSpan(
                          text: "Apache ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: "Teams",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // _isLoading // Show loading indicator if loading
                  //     ? Center(
                  //         child: CircularProgressIndicator(),
                  //       )
                  //     :
                       Container(
                          height: size.height * 0.4,
                          padding: const EdgeInsets.all(38),
                          child: AnimatedStackWidget(
                            itemCount: MoviesData.movies.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  zoomNavigation(
                                    DetailScreen(
                                      movieName: MoviesData.movies[index].name,
                                      movieTypeAndEpisode: MoviesData
                                          .movies[index].movieTypeAndEpisode,
                                      plot: MoviesData.movies[index].plot,
                                      movieImage:
                                          MoviesData.movies[index].coverImage,
                                      rating: MoviesData.movies[index].rating,
                                    ),
                                  ),
                                );
                              },
                              child: MagazineCoverImage(
                                  movies: MoviesData.movies[index]),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            // Center the loading indicator over the content
            // if (_isLoading) // Show loading indicator if loading
            //   Center(
            //     child: CircularProgressIndicator(),
            //   ),
          ],
        ),
      ),
    );
  }
}
