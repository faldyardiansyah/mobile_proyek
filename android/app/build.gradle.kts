plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.appkonkos_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.appkonkos_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val isCI = System.getenv("GITHUB_ACTIONS") == "true"
            if (isCI) {
                // Konfigurasi otomatis untuk server GitHub Actions
                storeFile = file("appkonkos-release.jks")
                storePassword = System.getenv("KEYSTORE_PASSWORD")
                keyAlias = System.getenv("KEY_ALIAS")
                keyPassword = System.getenv("KEYSTORE_PASSWORD")
            } else {
                // Konfigurasi kalau kamu build/run lewat laptop sendiri
                storeFile = file("appkonkos-release.jks")
                storePassword = "password_terminal_kamu" // <-- GANTI dengan password keystore kamu
                keyAlias = "appkonkos_alias"
                keyPassword = "password_terminal_kamu"   // <-- GANTI dengan password keystore kamu
            }
        }
    }

    buildTypes {
        release {
            // Menggunakan stempel resmi release, bukan debug lagi
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}