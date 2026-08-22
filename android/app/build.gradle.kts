//def localProperties = new Properties()
//def localPropertiesFile = rootProject.file('local.properties')
//if (localPropertiesFile.exists()) {
//    localPropertiesFile.withReader('UTF-8') { reader ->
//        localProperties.load(reader)
//    }
//}
//
//def flutterRoot = localProperties.getProperty('flutter.sdk')
//if (flutterRoot == null) {
//    throw new RuntimeException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
//}
//
//def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
//if (flutterVersionCode == null) {
//    flutterVersionCode = '1'
//}
//
//def flutterVersionName = localProperties.getProperty('flutter.versionName')
//if (flutterVersionName == null) {
//    flutterVersionName = '1.0'
//}
//
//apply plugin: 'com.android.application'
//apply plugin: 'com.google.gms.google-services'
//apply plugin: 'kotlin-android'
//apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
//
//android {
//    compileSdkVersion 35
//    ndkVersion flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility JavaVersion.VERSION_1_8
//        targetCompatibility JavaVersion.VERSION_1_8
//    }
//
//    kotlinOptions {
//        jvmTarget = '1.8'
//    }
//
//    sourceSets {
//        main.java.srcDirs += 'src/main/kotlin'
//    }
//
//    signingConfigs {
//        release {
//            keyAlias 'skillogic-refer-app'
//            keyPassword 'skillogic#'
//            storeFile file('key.jks')
//            storePassword 'skillogic#'
//        }
//    }
//
//    defaultConfig {
//        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//        applicationId "com.slogicrefer.mobile"
//        // You can update the following values to match your application needs.
//        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-build-configuration.
//        minSdkVersion 26
//        targetSdkVersion 35
//        versionCode flutterVersionCode.toInteger()
//        versionName flutterVersionName
//        multiDexEnabled true
//    }
//
////    buildTypes {
////        release {
////            // TODO: Add your own signing config for the release build.
////            // Signing with the debug keys for now, so `flutter run --release` works.
////            signingConfig signingConfigs.debug
////        }
////    }
//
//    buildTypes {
//        release {
//            signingConfig signingConfigs.release
//        }
//    }
//}
//
//flutter {
//    source '../..'
//}
//
//dependencies {
//    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
//    implementation 'com.android.support:multidex:1.0.3'
//    implementation platform('com.google.firebase:firebase-bom:32.3.1')
//    implementation 'com.google.firebase:firebase-analytics'
//    implementation 'com.google.firebase:firebase-core:21.1.1'
//}


import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val flutterVersionCode = project.findProperty("flutter.versionCode")?.toString()?.toInt() ?: 15
val flutterVersionName = project.findProperty("flutter.versionName")?.toString() ?: "15.0.0"

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")}

android {
    namespace = "com.slogicrefer.mobile"
    compileSdk = 36
    ndkVersion = "29.0.13846066"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.slogicrefer.mobile"
        minSdk = 24
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
        //missingDimensionStrategy("photo_picker", "androidx")
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // ndk.debugSymbolLevel = "Full"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
configurations.all {
    resolutionStrategy {
        force("com.google.android.recaptcha:recaptcha:18.4.0")
    }
}