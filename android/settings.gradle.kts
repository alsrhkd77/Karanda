pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    // 플러그인 모듈은 앱의 KGP로 컴파일되므로, 컴파일러가 플러그인이 끌어오는 stdlib보다 낮으면
    // "newer version of Kotlin" 오류가 난다(share_plus는 stdlib 2.2를 요구). 최소치에 맞추면 같은 문제가
    // 반복되므로 최신 안정 버전을 쓴다.
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
}

include(":app")
