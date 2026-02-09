//buildscript {
//    ext.kotlin_version = '1.7.10'
//    repositories {
//        google()
//        mavenCentral()
//    }
//
//    dependencies {
//        classpath 'com.android.tools.build:gradle:7.4.2'
//        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
//        classpath 'com.google.gms:google-services:4.4.0'
//    }
//}
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//rootProject.buildDir = '../build'
//subprojects {
//    project.buildDir = "${rootProject.buildDir}/${project.name}"
//}
//subprojects {
//    project.evaluationDependsOn(':app')
//}
//
//tasks.register("clean", Delete) {
//    delete rootProject.buildDir
//}


allprojects {
    repositories {
        google()
        mavenCentral()
        mavenLocal()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()

subprojects {
    if (project.projectDir.absolutePath.startsWith(rootProject.projectDir.absolutePath)) {
        val subBuildDir = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(subBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

