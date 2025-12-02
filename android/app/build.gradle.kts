plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rhythora"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.rhythora"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ========================================================
        // <--- TAMBAHAN PENTING (WAJIB ADA UNTUK SPOTIFY SDK)
        // ========================================================
        manifestPlaceholders["redirectSchemeName"] = "com.example.rhythora"
        manifestPlaceholders["redirectHostName"] = "callback"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true // Ini mengaktifkan R8
            isShrinkResources = true 
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro" // <-- Ini memanggil file langkah 2
            )
        }
    }

    // Tambahan agar tidak error jika ada peringatan kecil (Lint)
    lintOptions {
        isCheckReleaseBuilds = false
        isAbortOnError = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Bagian ini sudah BENAR
    implementation(project(":spotify-app-remote"))
    implementation("com.fasterxml.jackson.core:jackson-core:2.13.4")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.13.4")
    implementation("com.fasterxml.jackson.core:jackson-annotations:2.13.4")
    implementation("com.google.code.gson:gson:2.10.1") // Jaga-jaga butuh Gson juga
}