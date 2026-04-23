allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔥 INI YANG PENTING (FIX UTAMA)
subprojects {
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.12.0")
        }
    }
}

// (punya kamu tetap)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}