plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // ⚙️ Plugin Flutter phải nằm cuối
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.minhhai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.minhhai"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Hỗ trợ nhiều thư viện lớn
    }

    // ✅ Dùng Java 21 LTS để tận dụng các tính năng mới nhất
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    buildTypes {
        release {
            // Tạm thời dùng debug key nếu chưa ký release key
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        // 🧩 Loại bỏ các file trùng META-INF khi build
        resources.excludes.add("META-INF/DEPENDENCIES")
        resources.excludes.add("META-INF/LICENSE")
        resources.excludes.add("META-INF/LICENSE.txt")
        resources.excludes.add("META-INF/license.txt")
        resources.excludes.add("META-INF/NOTICE")
        resources.excludes.add("META-INF/NOTICE.txt")
        resources.excludes.add("META-INF/notice.txt")
        resources.excludes.add("META-INF/ASL2.0")
    }
}

flutter {
    source = "../.."
}
