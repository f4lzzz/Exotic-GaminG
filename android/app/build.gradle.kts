plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.apk"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    buildToolsVersion = "36.0.0"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.apk"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Fix: copy APK ke path yang Flutter tool harapkan
afterEvaluate {
    tasks.named("assembleDebug") {
        doLast {
            val apkSource = file("${buildDir}/outputs/apk/debug/app-debug.apk")
            val apkTarget = file("${rootDir}/../build/app/outputs/flutter-apk/app-debug.apk")
            if (apkSource.exists()) {
                apkTarget.parentFile.mkdirs()
                apkSource.copyTo(apkTarget, overwrite = true)
                println("APK copied to Flutter output path: ${apkTarget.absolutePath}")
            }
        }
    }
}