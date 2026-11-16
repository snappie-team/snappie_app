allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ganti folder build agar Flutter dan Gradle bisa sharing hasil kompilasi
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Force namespace for plugins that don't have one (required by AGP 8.0+)
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            val currentSdk = android.compileSdkVersion?.replace("android-", "")?.toIntOrNull() ?: 0
            if (currentSdk < 31) {
                android.compileSdkVersion(36)
            }
            if (android.namespace == null) {
                android.namespace = project.group.toString().ifEmpty { "com.snappie.${project.name.replace("-", "_")}" }
            }
        }
    }

    project.evaluationDependsOn(":app")
}

// Task untuk membersihkan project
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
