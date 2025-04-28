plugins {
    id("com.android.application")  // ✅ Android plugin first
    id("kotlin-android")           // ✅ Kotlin plugin next
    id("dev.flutter.flutter-gradle-plugin") // ✅ Flutter plugin LAST
    id("com.google.gms.google-services") // ✅ Google services (after android plugin)
}


android {
    namespace = "com.example.flutter_application5"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application5"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")

        // Firebase BoM
        implementation(platform("com.google.firebase:firebase-bom:33.12.0"))

        // Firebase SDKs
        implementation("com.google.firebase:firebase-analytics")
        implementation("com.google.firebase:firebase-firestore")
        implementation("com.google.firebase:firebase-auth")
// Optional, use only if you need it
    }



    flutter {
        source = "../.."
    }
}